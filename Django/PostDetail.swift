//
//  PostDetail.swift
//  Django
//
//  Created by YUKITO on 2020/01/19.
//  Copyright © 2020 TJ-Tech. All rights reserved.
//

//  FIXME: viewDidLayoutSubviews で宣言していないので改変を頼みます。

import Foundation
import UIKit

/// - Tag: PostDetail
class PostDetail:UIViewController,UINavigationControllerDelegate,UIGestureRecognizerDelegate,UICollectionViewDelegate,UITextFieldDelegate,UIScrollViewDelegate{
    //MARK: -Setup
    
    // Wheter to allow interactive pop delegate or not
    enum interactivePop {
        case eneble
        case disable
    }
    
    override func viewDidLoad() {
        configureObserver()
        configure()

        view.clipsToBounds = true
        view.backgroundColor = .systemBackground
        
        server.delegate = self
        
        configureCollection()
        configureAgain()
        
        
        if pop == .disable{
            let pan = UIPanGestureRecognizer(target: self, action: #selector(dismissPan(_:)))
            self.view.addGestureRecognizer(pan)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(home(_:)), name: .home, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(popToRoot(_:)), name: .user, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(popToRoot(_:)), name: .find, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: .hide, object: nil)
        
        if pop == .disable{
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            guard let vcCount = navigationController?.viewControllers.count else{
                return
            }
            let num = vcCount - 2
            let vcA = self.navigationController?.viewControllers[num]
            if let vc = vcA{
                self.parent?.view.insertSubview(vc.view, at: 0)
            }
        }else{
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
        
        var server = ServerStruct()
        server.delegate = self
        server.getComment(pk: post_id)
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: .show, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: .show, object: nil)
        self.view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        bottomInsets = view.safeAreaInsets.bottom
        textField.frame = CGRect(x: 10, y: view.bounds.height - textField.frame.height - view.safeAreaInsets.bottom, width: view.bounds.width - 20, height: 50)
        textField.frame.origin.y = view.bounds.height - textField.frame.height - bottomInsets
    }
    
    init(image:String?,profile:String?,post_id:Int,user_id:Int,text:String?,interactivePop:interactivePop) {
        self.imagePath = image
        self.profilePath = profile
        self.post_id = post_id
        self.user_id = user_id
        self.text = text
        self.pop = interactivePop
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var bottomInsets:CGFloat!
    var imagePath:String!
    var profilePath:String!
    let user_id:Int!
    var post_id: Int!
    var text: String?
    var pop:interactivePop!
    
    //MARK: -Server
    var server = ServerStruct()
    
    //MARK: -Transition Components
    var imageView = UIImageView()
    var profileImage = UIImageView()
    let topBackground = UIView()
    let bottomBackground = UIView()
    
    //MARK: -Collection
    var comment:Array<String> = []
    var comment_id: Array<Int> = []
    var profile_pic:Array<String?> = []
    var username:Array<String> = []
    
    var collection : UICollectionView!
    
    //MARK: -Components
    let textLabel = UILabel()
    var placeHolderImage = UIImage()
    var usernamelabel = UILabel()
    let usernameButton = UIButton()
    let textField = UITextField()
    
    func configureCollection() {
        let screenWidth = view.frame.width
        let screenHeight = view.frame.height
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth - 10, height: 100)
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: imageView.bounds.height + 30, left: 5, bottom: 80, right: 5)
        collection = UICollectionView(frame: CGRect(x: 0, y: 100 , width: screenWidth, height: screenHeight - 100 ), collectionViewLayout: layout)
        collection.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: "cocell") // クラスの取得は、さっくりselfでOK
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        collection.dragInteractionEnabled = true
        collection.showsVerticalScrollIndicator = false
        collection.alwaysBounceVertical = true
        view.addSubview(collection)
    }
    func configure() {
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height:  view.frame.width)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        
        
        if let image = URL(string: imagePath){
            imageView.af_setImage(withURL: image, placeholderImage: placeHolderImage, filter: .none, progress: .none, progressQueue: .main, imageTransition: .noTransition, runImageTransitionIfCached: false, completion: nil)
        }
        
        bottomBackground.frame = view.frame
        bottomBackground.backgroundColor = .systemBackground
        
        topBackground.backgroundColor = .systemBackground
        topBackground.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        topBackground.layer.cornerRadius = 30
        topBackground.layer.cornerCurve = .continuous
        
        let ges = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(ges)
        
        view.addSubview(bottomBackground)
        view.addSubview(imageView)
        view.addSubview(topBackground)
    }
    func configureAgain() {
        profileImage.frame = CGRect(x: 10, y: imageView.bounds.height - 100 + 10, width: 40, height: 40)
        profileImage.layer.cornerRadius = 20
        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true
        
        usernamelabel.frame = CGRect(x: 60, y: imageView.bounds.height - 100 + 10, width: 140, height: 40)
        
        usernameButton.frame = CGRect(x: 10, y: imageView.bounds.height - 100 + 10, width: 180, height: 40)
        usernameButton.addTarget(self, action: #selector(getUser(_:)), for: .touchUpInside)
        
        collection.addSubview(usernameButton)
        collection.addSubview(usernamelabel)
        collection.addSubview(profileImage)
        
        if let image = URL(string: profilePath){
            profileImage.af_setImage(withURL: image, placeholderImage: placeHolderImage, filter: .none, progress: .none, progressQueue: .main, imageTransition: .noTransition, runImageTransitionIfCached: false, completion: nil)
        }
        
        textLabel.text = text
        textLabel.numberOfLines = 0
        textLabel.frame = CGRect(x: 30, y: imageView.bounds.height - 100 + 60, width: view.bounds.width-30, height: 50)
        
        collection.addSubview(textLabel)
        
        textField.placeholder = "type something..."
        textField.delegate = self
        view.addSubview(textField)
    }
    
    let transition = TransitionCoordinator()
    
    //MARK: -Action
    func configureObserver() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                 name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                 name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(_ notification: Notification?){
        guard let userInfo = notification?.userInfo as? [String: Any] else {
            return
        }
        guard let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardSize = keyboardInfo.cgRectValue.size
        
        textField.frame.origin.y = view.bounds.height - keyboardSize.height - textField.frame.height
    }
    @objc func keyboardWillHide(_ notification: Notification?){
        textField.frame.origin.y = view.bounds.height - textField.frame.height - bottomInsets
    }
    //Action when keyboard moved
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = collection.contentOffset.y
        
        var height = view.frame.width
        if y < 0{
            height = view.frame.width - y
        }else if y < view.frame.width - 100{
            height = view.frame.width - y
        }else{
            height = 100
        }
        imageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: CGFloat(height))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        
        guard let text = textField.text else {
            textField.text = ""
            return true
        }
        if text != ""{
            server.comment(text: text,pk:post_id)
            textField.text = ""
        }
        return true
    }
    @objc func tap(){
        view.endEditing(true)
    }
    
    @objc func popToRoot(_ notification:Notification) {
        if navigationController?.visibleViewController?.view == view && !(navigationController?.view.isHidden)!{
            self.navigationController?.delegate = self
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc func home(_ notification:Notification) {
        if navigationController?.visibleViewController?.view == view && !(navigationController?.view.isHidden)!{
            self.navigationController?.delegate = self//transition
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc func getUser(_ sender: UIButton) {
        NotificationCenter.default.post(name: .show, object: nil)
        let vc = UserViewController(string: usernameView.text!, userid: user_id, profpath: profilePath)
        navigationController?.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func dismissPan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began{
            self.view.endEditing(true)
        }
        if sender.state == .changed{
            if sender.translation(in: parent?.view).x > 80{
                self.navigationController?.delegate = transition
                self.navigationController?.popViewController(animated: true)
            }
            else if sender.translation(in: parent?.view).x > 0{
                
                UIView.animate(withDuration: 0.1, delay: 0.05, options: .curveLinear, animations: {
                    let scale = sender.translation(in: self.parent?.view).x / 800
                    self.view.transform = CGAffineTransform(scaleX: 1 - scale, y: 1 - scale)
                    
                    self.view.layer.cornerRadius = 20
                    self.view.layer.cornerCurve = .continuous
                }, completion: nil)
            }else{
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                    self.view.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.view.layer.cornerRadius = 0
                }, completion: nil)
            }
        }else if sender.state == .ended || sender.state == .cancelled{
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                self.view.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.view.layer.cornerRadius = 0
            }, completion: nil)
        }
    }
}

extension PostDetail: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.comment.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cocell", for: indexPath) as! CommentCollectionViewCell
        
        cell.content(text: comment[indexPath.row],profpic: profile_pic[indexPath.row],username: username[indexPath.row])
        
        cell.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveLinear, animations: {
            cell.alpha = 1
        }, completion: nil)
        return cell
    }
    
}

// MARK: - Protocol for Transition
extension PostDetail : animTransitionable {
    var usernameView: UILabel {
        return usernamelabel
    }
    
    var profileImageView: UIImageView {
        return profileImage
    }
    
    var cellImageView: UIImageView {
        return imageView
    }
    
    var backgroundColor: UIView {
        return topBackground
    }
    
    var cellBackground: UIView {
        return bottomBackground
    }
    
}

// MARK: - Protocol for Comments
extension PostDetail: ServerClassDelegate {
    func onSuccessGetComment(comment: Array<String>, profilePath: Array<String?>, username: Array<String>,comment_id:Array<Int>) {
        self.comment = comment
        self.profile_pic = profilePath
        self.username = username
        self.comment_id = comment_id
        self.collection.reloadData()
    }
        
    func onSuccessComment() {
        server.getComment(pk: post_id)
    }
}

class CommentCollectionViewCell: UICollectionViewCell {
    var textLabel: UILabel!
    var profImage: UIImageView!
    var usernameL: UILabel!
    var cellBackground:UIView!
    var bar: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textLabel = UILabel()
        textLabel.frame = CGRect(x: 50, y: frame.size.height - 40, width: frame.width - 50, height: 30)
        textLabel.textColor = .label
        textLabel.font = UIFont.systemFont(ofSize: 15)
        textLabel.textAlignment = .left
        
        profImage = UIImageView(frame: CGRect(x: 40, y: 10, width: 30, height: 30))
        profImage.layer.cornerRadius = 15
        profImage.clipsToBounds = true
        
        usernameL = UILabel(frame: CGRect(x: 80, y: 10, width: frame.size.width - 60, height: 30))
        usernameL.textColor = .label
        
        cellBackground = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        cellBackground.clipsToBounds = false
        cellBackground.backgroundColor = .clear
        
        bar = UIView(frame: CGRect(x: 20, y: 5, width: 5, height: frame.height - 10))
        bar.backgroundColor = .systemGray5
        bar.layer.cornerRadius = 2.5
        
        self.contentView.backgroundColor = .clear
        
        self.contentView.addSubview(cellBackground)
        self.contentView.addSubview(textLabel)
        self.contentView.addSubview(profImage)
        self.contentView.addSubview(usernameL)
        self.contentView.addSubview(bar)
    }
    
    // Storyboardを使用しなくても、このイニシアライザを定義してないと、ビルドを通らない。
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func content(text:String,profpic:String?,username:String){
        textLabel.text = text
        usernameL.text = username
        if let prof = profpic {
            profImage.af_setImage(withURL: URL(string: prof.addThubnail)!)

        }
    }
    
}
