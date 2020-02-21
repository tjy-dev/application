//
//  SearchViewController.swift
//  Django
//
//  Created by YUKITO on 2020/01/28.
//  Copyright © 2020 TJ-Tech. All rights reserved.
//

import Foundation
import UIKit

/// - Tag: Search
class SearchViewController :UIViewController,UITextFieldDelegate,UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate,UIGestureRecognizerDelegate{
    
    //MARK: -Setup
    override func viewDidLoad() {
        server.delegate = self
        configureCollection()
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        let screenWidth = view.frame.width
        topView.frame = CGRect(x: 0, y: -20, width: view.frame.width, height: view.safeAreaInsets.top + 85)
        searchField.frame = CGRect(x: 15, y: view.safeAreaInsets.top + 30, width: screenWidth - 30, height: 40)
        collection.frame = view.frame
    }
    
    //MARK: -Components
    let searchField = UITextField()
    let topView = UIView()
    var collection: UICollectionView!
    var server = ServerStruct()
    
    var user_id:Array<Int> = []
    var profilePath:Array<String?> = []
    var username:Array<String> = []
    var text:Array<String?> = []
    
    func configure(){
        view.backgroundColor = .systemBackground
        
        topView.backgroundColor = .systemBackground
        topView.layer.cornerRadius = 20
        topView.layer.cornerCurve = .continuous
        topView.layer.shadowOpacity = 0.1
        topView.layer.shadowOffset = CGSize(width: 4, height: 4)
        topView.layer.shadowColor = UIColor.black.cgColor
        topView.layer.shadowRadius = 10
        view.addSubview(topView)

        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        paddingView.backgroundColor = .clear
        searchField.leftView = paddingView
        searchField.leftViewMode = .always
        searchField.clearButtonMode = .whileEditing
        searchField.autocapitalizationType = .none
        
        searchField.attributedPlaceholder = NSAttributedString(string: "Search")
        searchField.backgroundColor = .systemGray6
        searchField.layer.cornerRadius = 12
        searchField.layer.cornerCurve = .continuous
        searchField.delegate = self
        searchField.returnKeyType = .search
        topView.addSubview(searchField)
        
    }
    
    func configureCollection(){
        // UICollectionViewCellのマージン等の設定
        let flowLayout: UICollectionViewFlowLayout! = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: view.frame.width - 20, height: 100)
        flowLayout.sectionInset = UIEdgeInsets(top: 100, left: 10, bottom: 0, right: 10)
        flowLayout.minimumInteritemSpacing = 0   //Horisantle
        flowLayout.minimumLineSpacing = 30       //Vertical
        
        collection = UICollectionView(frame: view.frame,collectionViewLayout: flowLayout)
        collection.backgroundColor = .clear
        collection.dataSource = self
        collection.delegate = self
        collection.register(UserSearchCell.self, forCellWithReuseIdentifier: "userSearchCell")
        
        collection.alwaysBounceVertical = true
        
        //gesture to dismiss Keyboard
        let ges = UITapGestureRecognizer(target: self, action: #selector(dismissKey(_:)))
        ges.delegate = self
        view.addGestureRecognizer(ges)
        
        view.addSubview(collection)
    }
    
    //MARK: -Action
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if self.collection.indexPathForItem(at: touch.location(in: self.collection)) != nil {
            return false
        }
        return true
    }
    
    @objc func dismissKey(_ sender: UITapGestureRecognizer){
        if searchField.text ?? "" != ""{
            server.getUserByName(name: searchField.text!)
        }else{
            user_id = []
            profilePath = []
            username = []
            text = []
            self.collection.reloadData()
        }
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text ?? "" != ""{
            server.getUserByName(name: textField.text!)
        }else{
            user_id = []
            profilePath = []
            username = []
            text = []
            self.collection.reloadData()
            server.getUserByName(name: textField.text ?? "")
        }
        self.view.endEditing(true)
        return true
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user_id.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userSearchCell", for: indexPath) as! UserSearchCell // 表示するセルを登録(先程命名した"Cell")
        cell.content(username: username[indexPath.row], text: text[indexPath.row] ?? "", image: profilePath[indexPath.row] ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UserViewController(string: username[indexPath.row], userid: user_id[indexPath.row], profpath: profilePath[indexPath.row] ?? "")
        self.view.endEditing(true)
        navigationController?.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension SearchViewController: ServerClassDelegate{
    func searchResult(user_id: Array<Int>, profilePath: Array<String?>, username: Array<String>, text: Array<String?>) {
        self.user_id = user_id
        self.profilePath = profilePath
        self.username = username
        self.text = text
        self.collection.reloadData()
    }
}

class UserSearchCell: UICollectionViewCell {
    var textLabel: UILabel!
    var profImage: UIImageView!
    var usernameL: UILabel!
    var cellBackground:UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        profImage = UIImageView(frame: CGRect(x: 15, y: 10, width: 30, height: 30))
        profImage.layer.cornerRadius = 15
        profImage.clipsToBounds = true
        
        usernameL = UILabel(frame: CGRect(x: 55, y: 10, width: frame.size.width - 60, height: 30))
        usernameL.textColor = .label
        
        textLabel = UILabel()
        textLabel.frame = CGRect(x: 15, y: frame.size.height - 40, width: frame.width - 20, height: 30)
        textLabel.textColor = .label
        textLabel.font = UIFont.systemFont(ofSize: 18)
        textLabel.textAlignment = .left
        
        cellBackground = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        cellBackground.clipsToBounds = true
        cellBackground.backgroundColor = .systemBackground
        cellBackground.layer.cornerCurve = .continuous
        cellBackground.layer.cornerRadius = 20
        cellBackground.layer.shadowColor = UIColor.black.cgColor
        cellBackground.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        cellBackground.layer.shadowRadius = 8.0
        cellBackground.layer.shadowOpacity = 0.2
        
        self.contentView.backgroundColor = .systemBackground
        
        self.contentView.layer.cornerCurve = .continuous
        self.contentView.layer.cornerRadius = 20
        
        self.contentView.layer.shadowColor = UIColor.black.cgColor
        self.contentView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.contentView.layer.shadowRadius = 8.0
        self.contentView.layer.shadowOpacity = 0.1
        
        self.contentView.addSubview(cellBackground)
        self.contentView.addSubview(usernameL)
        self.contentView.addSubview(textLabel)
        self.contentView.addSubview(profImage)
        
    }
    
    // Storyboardを使用しなくても、このイニシアライザを定義してないと、ビルドを通らない。
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func content(username:String, text:String, image:String){
        
        usernameL.text = username
        
        if let path = URL(string: image.addThubnail){
            self.profImage.af_setImage(withURL: path)
            self.textLabel.text = text
        }else{
            self.textLabel.text = text
            self.profImage.image = UIImage()
        }
    }
    
}
