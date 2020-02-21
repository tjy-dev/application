//
//  ViewController.swift
//  Django
//
//  Created by YUKITO on 2020/01/12.
//  Copyright © 2020 TJ-Tech. All rights reserved.
//

import UIKit
import AlamofireImage
import Foundation

/// - Tag: PostList
class ViewController2: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate {
    
    //MARK: -Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        backgroundView = UIView()
        backgroundView.backgroundColor = .systemBackground
        view.addSubview(backgroundColor)
        
        configureCollectionView()
        configureComponents()
        
        server.delegate = self
        navigationItem.title = "Django"
        navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(home(_:)), name: .home, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if let col = collection{
            let cells = col.visibleCells
            for cell in cells{
                cell.alpha = 1
            }
        }
        
        if let image = UserDefaults.standard.array(forKey: "imageCache") {
            imagePath = image as! Array<String>
        }
        if let user = UserDefaults.standard.array(forKey: "usernameCache") {
            username = user as! Array<String>
        }
        if let post_id = UserDefaults.standard.array(forKey: "postidCache") {
            self.post_id = post_id as! Array<Int>
        }
        if let text = UserDefaults.standard.array(forKey: "textCache") {
            self.text = text as! Array<String>
        }
        if let user_id = UserDefaults.standard.array(forKey: "useridCache") {
            self.user_id = user_id as! Array<Int>
        }
        if let profilePath = UserDefaults.standard.array(forKey: "profileImageCache") {
            self.profilePath = profilePath as! Array<String>
            collection.reloadData()
        }
        
        NotificationCenter.default.post(name: .show, object: nil)
        
        server.getPost()
    }
    
    //MARK: -SetFrame
    override func viewDidLayoutSubviews() {
        backgroundView.frame = view.frame
        collection.frame = view.frame
        topView.frame = CGRect(x: -1, y: -1, width: view.frame.width+2, height: 100)
        
    }
    
    //MARK: -Components
    var backgroundView: UIView!
    let refreshControl = UIRefreshControl()
    var collection: UICollectionView!
    
    func configureCollectionView() {
        let screenWidth = view.frame.width
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth - 10, height: (screenWidth - 10) * 0.9)
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 120, left: 5, bottom: 100, right: 5)
        collection = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collection.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell") // クラスの取得は、さっくりselfでOK
        collection.backgroundColor = .systemBackground
        collection.delegate = self
        collection.dataSource = self
        collection.dragInteractionEnabled = true
        view.addSubview(collection)
        
        collection.refreshControl = refreshControl
        refreshControl.backgroundColor = .systemBackground
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
    }
    
    let topView = UIScrollView()
    
    func configureComponents() {
        topView.alwaysBounceHorizontal = true
        topView.backgroundColor = .systemBackground
        collection.addSubview(topView)
        
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.af_setImage(withURL: URL(string: UserDefaults.standard.string(forKey: "profilePath")!)!)
        imageView.frame = CGRect(x: 20, y: 30, width: 60, height: 60)
        imageView.layer.cornerRadius = 30
        topView.addSubview(imageView)
        
        let plusImageView = UIImageView()
        plusImageView.layer.masksToBounds = false
        plusImageView.clipsToBounds = true
        plusImageView.backgroundColor = .systemBackground
        plusImageView.image = UIImage(systemName: "plus.circle.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .bold))
        plusImageView.tintColor = .systemTeal
        plusImageView.frame = CGRect(x: 40, y: 50, width: 20, height: 20)
        plusImageView.layer.cornerRadius = 10
        plusImageView.center = CGPoint(x: imageView.center.x + 20, y: plusImageView.center.y + 20)
        topView.addSubview(plusImageView)
    }
    
    //MARK: -Database
    var server = ServerStruct()
    var post_id:Array<Int> = []
    var text:Array<String?> = []
    var username:Array<String> = []
    var user_id:Array<Int> = []
    var imagePath:Array<String?> = []
    var profilePath:Array<String?> = []
    
    //MARK: -Actions
    var selectedIndexPath:IndexPath!
    
    @objc func refresh(_ sender: UIRefreshControl) {
        server.getPost()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        
        let detailView = PostDetail(image: imagePath[indexPath.row], profile: profilePath[indexPath.row], post_id: post_id[indexPath.row],user_id: user_id[indexPath.row],text: text[indexPath.row],interactivePop: .disable)
        
        let cell = collection.cellForItem(at: indexPath) as! CollectionViewCell
        detailView.placeHolderImage = cell.imageView.image ?? UIImage()
        detailView.usernamelabel.text = cell.usernameL.text!
        
        cell.alpha = 0
        
        NotificationCenter.default.post(name: .hide, object: nil)
        
        let transition = TransitionCoordinator()
        self.navigationController?.delegate = transition
        self.navigationController?.pushViewController(detailView, animated: true)
    }
    
    @objc func home(_ sender: Notification) {
        if navigationController?.visibleViewController?.view == view && !(navigationController?.view.isHidden)!{
            collection.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: true)
        }
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "Delete", style: .destructive, handler: {
            (action: UIAlertAction!) in
            self.server.deletePost(pk: sender.tag)
            NotificationCenter.default.post(name: .show, object: nil)
        })
        let action2 = UIAlertAction(title: "cancel", style: .cancel, handler: {
            (action: UIAlertAction!) in
            NotificationCenter.default.post(name: .show, object: nil)
        })
        
        // アクションを追加.
        alertSheet.addAction(action1)
        alertSheet.addAction(action2)
        alertSheet.popoverPresentationController?.sourceView = view
        alertSheet.popoverPresentationController?.sourceRect = sender.frame
        self.present(alertSheet, animated: true, completion: nil)
        NotificationCenter.default.post(name: .hide, object: nil)
    }
    @objc func getUser(_ sender: UIButton) {
        let vc = UserViewController(string: username[sender.tag],userid: user_id[sender.tag],profpath: profilePath[sender.tag]!)
        navigationController?.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc func userLogin(_ sender: UIButton) {
        let vc = LoginView()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}


//MARK: -Cell Settings
class CollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var textLabel: UILabel!
    var profImage: UIImageView!
    var usernameL: UILabel!
    var cellBackground:UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 50, width: frame.size.width - 0, height: frame.size.height - 50))
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerCurve = .continuous
        imageView.layer.cornerRadius = 20
        
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
        self.contentView.layer.shadowOpacity = 0.2
        
        self.contentView.addSubview(cellBackground)
        self.contentView.addSubview(usernameL)
        self.cellBackground.addSubview(imageView)
        self.contentView.addSubview(textLabel)
        self.contentView.addSubview(profImage)
        
    }
    
    // Storyboardを使用しなくても、このイニシアライザを定義してないと、ビルドを通らない。
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func content(username:String, text:String?, image:String?, pimage:String?, post_id:Int){
        if let path = URL(string: pimage?.addThubnail ?? ""){
            profImage.af_setImage(withURL: path)
        }
        
        usernameL.text = username
        
        if let path = URL(string: image?.addThubnail ?? ""){
            self.imageView.af_setImage(withURL: path)
            self.textLabel.text = ""
        }else{
            self.textLabel.text = text
            self.imageView.image = UIImage()
        }
    }
    
}

// MARK: - Protocol for Transition
extension ViewController2 : animTransitionable {
    var usernameView: UILabel {
        if let indexPath = selectedIndexPath {
            let cell = collection.cellForItem(at: indexPath) as! CollectionViewCell
            return cell.usernameL
        }
        return UILabel()
    }
    
    var profileImageView: UIImageView {
        if let indexPath = selectedIndexPath {
            let cell = collection.cellForItem(at: indexPath) as! CollectionViewCell
            return cell.profImage
        }
        return UIImageView()
    }
    
    var cellImageView: UIImageView {
        if let indexPath = selectedIndexPath {
            if let cell = collection.cellForItem(at: indexPath) {
                return (cell as! CollectionViewCell).imageView
            }
            return UIImageView()
        }
        return UIImageView()
    }
    
    var backgroundColor: UIView {
        return backgroundView
    }
    
    var cellBackground: UIView {
        if let indexPath = selectedIndexPath {
            let cell = collection.cellForItem(at: indexPath) as! CollectionViewCell
            return cell.cellBackground
        }
        return UIView()
    }
    
}

//MARK: -Server Delegate
extension ViewController2 : ServerClassDelegate {
    func onSuccessPost() {
        server.getPost()
    }
    func onSuccessDelete() {
        server.getPost()
    }
    func onSuccessGetPost(post_id:Array<Int>,text:Array<String?>,username:Array<String>,user_id:Array<Int>,imagePath:Array<String?>,profilePath:Array<String?>) {
        self.post_id = post_id
        self.text = text
        self.username = username
        self.user_id = user_id
        self.imagePath = imagePath
        self.profilePath = profilePath
        self.collection.reloadData()
        if self.refreshControl.isRefreshing == true{
            self.refreshControl.endRefreshing()
        }
        UserDefaults.standard.set(username, forKey: "usernameCache")
        UserDefaults.standard.set(imagePath, forKey: "imageCache")
        UserDefaults.standard.set(post_id, forKey: "postidCache")
        UserDefaults.standard.set(text, forKey: "textCache")
        UserDefaults.standard.set(user_id, forKey: "useridCache")
        UserDefaults.standard.set(profilePath, forKey: "profileImageCache")
    }
    
}

extension ViewController2 : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return username.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell // 表示するセルを登録(先程命名した"Cell")
        
        let button = UIButton(frame: CGRect(x: cell.frame.width - 45, y: 10, width: 30, height: 30))
        button.setImage(UIImage(systemName: "ellipsis",withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)), for: .normal)
        button.tintColor = .systemGray2
        button.tag = self.post_id[indexPath.row]
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        
        cell.addSubview(button)
        
        let button2 = UIButton(frame: CGRect(x: 15, y: 10, width: cell.frame.width - 70, height: 30))
        button2.tag = indexPath.row
        button2.addTarget(self, action: #selector(getUser(_:)), for: .touchUpInside)
        
        cell.addSubview(button2)
        
        let path = imagePath[indexPath.row]
        let proPath = profilePath[indexPath.row]
        let postid = post_id[indexPath.row]
        let ptext = text[indexPath.row]
        
        cell.content(username: username[indexPath.row], text: ptext, image: path, pimage: proPath,post_id: postid)
        return cell
    }
}


