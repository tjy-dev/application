//
//  UserViewController.swift
//  Django
//
//  Created by YUKITO on 2020/01/18.
//  Copyright © 2020 TJ-Tech. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

/// - Tag: UserDetail
class UserViewController:UIViewController, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate{
    
    //MARK: -Setup
    override func viewWillLayoutSubviews() {
        profImage.frame = CGRect(x: 30, y: 60, width: 100, height: 100)
        profImage.center.x = view.center.x
        borderView.frame = CGRect(x: 0, y: 0, width: 110, height: 110)
        borderView.center = profImage.center
        
        usernameLabel.frame = CGRect(x: 20, y: profImage.frame.maxY + 40, width: 100, height: 25)
        
        followButton.frame = CGRect(x: view.frame.width-120, y: 0, width: 100, height: 40)
        followButton.center.y = usernameLabel.center.y
        
        //bioLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        bioLabel.frame = CGRect(x: 20, y: usernameLabel.frame.maxY + 20, width: view.frame.width-40, height: 80)
        
        collection.frame = view.frame
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollection()
        self.navigationItem.title = titleName
        self.view.backgroundColor = .systemBackground
        
        
        server.delegate = self
        
        server.getPost(pk: user_id)
        
        configureComponents()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(popToRoot(_:)), name: .home, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(popToRoot(_:)), name: .user, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(popToRoot(_:)), name: .find, object: nil)
    }
    
    init(string:String,userid:Int,profpath:String) {
        self.titleName = string
        self.user_id = userid
        self.profpath = profpath
        //FIXME: ImagePath = nil
        if URL(string: profpath) != nil{
            self.profImage.af_setImage(withURL: URL(string: profpath)!)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -Components
    let profImage = UIImageView()
    let titleName: String
    let user_id:Int
    let profpath:String
    
    var collection : UICollectionView!
    
    var image:Array<String?> = []
    var text:Array<String?> = []
    var post_id:Array<Int> = []
    
    let followButton = MyButton()
    let usernameLabel = UILabel()
    let bioLabel = UILabel()
    let borderView = UIView()
    
    func configureComponents(){
        if UserDefaults.standard.integer(forKey: "userid") != user_id{
            followButton.backgroundColor = .systemGreen
            followButton.layer.cornerRadius = 10
            followButton.layer.cornerCurve = .continuous
            followButton.addTarget(self, action: #selector(follow(_:)), for: .touchUpInside)
            collection.addSubview(followButton)
        }
        
        server.userDtail(pk: user_id)
        
        borderView.layer.cornerRadius = 55
        borderView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1).cgColor
        borderView.layer.borderWidth = 2
        collection.addSubview(borderView)
        
        collection.addSubview(profImage)
        profImage.layer.cornerRadius = 50
        profImage.clipsToBounds = true
        profImage.contentMode = .scaleAspectFill
        
        usernameLabel.text = titleName
        usernameLabel.textAlignment = .left
        usernameLabel.font = UIFont.systemFont(ofSize: 23, weight: .medium)
        usernameLabel.textColor = .label
        
        bioLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        bioLabel.numberOfLines = 0
        bioLabel.textColor = .label
        
        collection.addSubview(bioLabel)
        collection.addSubview(usernameLabel)
    }
    
    func configureCollection(){
        let screenWidth = view.frame.width
        _ = view.frame.height
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth/3 - 40/3, height: screenWidth/3 - 40/3)
        layout.minimumLineSpacing = 10        //Vertical
        layout.minimumInteritemSpacing = 0    //Horisantle
        layout.sectionInset = UIEdgeInsets(top: 350, left: 10, bottom: 100, right: 10)
        collection = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collection.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: "user") // クラスの取得は、さっくりselfでOK
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        collection.dragInteractionEnabled = true
        collection.alwaysBounceVertical = true
        view.addSubview(collection)
    }
    
    func setbutton(following:Bool){
        if following{
            self.followButton.setTitle("following", for: .normal)
        }else{
            self.followButton.setTitle("follow", for: .normal)
        }
    }
    
    //MARK: -Server
    var server = ServerStruct()
    
    //MARK: -Action
    @objc func popToRoot(_ notification:Notification){
        if navigationController?.visibleViewController?.view == view && !(navigationController?.view.isHidden)!{
            self.navigationController?.delegate = self
            self.navigationController?.popToRootViewController(animated: true)
        }
        else{
            server.getPost(pk: user_id)
        }
    }
    
    @objc func follow(_ sender:UIButton){
        server.followUser(pk: user_id)
    }
}

extension UserViewController: ServerClassDelegate {
    func onSuccessFollow(follow: Bool) {
        setbutton(following: follow)
    }
    
    func onSuccessGetUserDetail(follow: Bool?, bio: String?) {
        if let follow = follow{
            setbutton(following: follow)
        }
        bioLabel.text = bio ?? ""
    }
    
    func onSuccessGetPost(post_id: Array<Int>, text: Array<String?>, username: Array<String>, user_id: Array<Int>, imagePath: Array<String?>, profilePath: Array<String?>) {
        self.image = imagePath
        self.post_id = post_id
        self.text = text
        self.collection.reloadData()
    }
}

extension UserViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post_id.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "user", for: indexPath) as! UserCollectionViewCell // 表示するセルを登録(先程命名した"Cell")
        cell.content(image: self.image[indexPath.row], id: self.post_id[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PostDetail(image: image[indexPath.row], profile: profpath, post_id: post_id[indexPath.row], user_id: user_id,text: text[indexPath.row], interactivePop: .eneble)
        vc.usernamelabel.text = usernameLabel.text!
        NotificationCenter.default.post(name: .hifo, object: nil)//Hide Footer
        navigationController?.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}



class UserCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    let shadow = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.cornerCurve = .continuous
        
        //self.contentView.addSubview(shadow)
        shadow.frame = imageView.frame
        shadow.backgroundColor = .black
        shadow.layer.cornerRadius = 20
        shadow.layer.cornerCurve = .continuous
        shadow.layer.masksToBounds = false
        shadow.layer.shadowRadius = 8
        shadow.layer.shadowOpacity = 0.2
        shadow.layer.shadowOffset = CGSize(width: 1, height: 1)
        shadow.layer.shadowColor = UIColor.black.cgColor
        
        self.contentView.backgroundColor = .systemBackground
        
        self.contentView.addSubview(imageView)
    }
    
    // Storyboardを使用しなくても、このイニシアライザを定義してないと、ビルドを通らない。
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func content(image:String?,id:Int){
        if let image = image{
            self.imageView.af_setImage(withURL: URL(string: image.addThubnail)!)
        }else{
            self.imageView.image = UIImage()//明示的に宣言しないと再利用されたと気に困る
        }
    }
}

class MyButton: UIButton{
    override var isHighlighted: Bool{
        didSet{
            if self.isHighlighted{
                self.tintColor = .darkGray
                self.backgroundColor = .systemGray2
            }else{
                self.tintColor = .white
                self.backgroundColor = .systemGreen
            }
        }
    }
}
