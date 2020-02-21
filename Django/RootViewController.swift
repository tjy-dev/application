//
//  RootViewController.swift
//  Alamofire
//
//  Created by YUKITO on 2020/01/26.
//

import Foundation
import UIKit

/// - Tag: RootView
class ViewController:UIViewController {
    override func viewDidLoad() {
        if UserDefaults.standard.string(forKey: "username") != nil{
            configureViews()
            configureButtons()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(hide(_:)), name: .hide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(show(_:)), name: .show, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideFooter(_:)), name: .hifo, object: nil)
        //UserDefaults.standard.set(nil, forKey: "username")
    }
    override func viewDidLayoutSubviews() {
        if view.safeAreaInsets.bottom == 0{
            footer.frame = CGRect(x: 10, y: view.frame.height - 80, width: view.frame.width - 20, height: 70)
        }else{
            footer.frame = CGRect(x: 10, y: view.frame.height - view.safeAreaInsets.bottom - 70, width: view.frame.width - 20, height: 70)
        }
        if footerStyle == .hidden {
            footer.center.y += 120
        }
        footerShadowDark.frame = footer.frame
        footerShadowWhite.frame = footer.frame
        
        button1.center = CGPoint(x: 8 * footer.frame.width / 60, y: footer.frame.height / 2)
        button2.center = CGPoint(x: 19 * footer.frame.width / 60, y: footer.frame.height / 2)
        button3.center = CGPoint(x: 30 * footer.frame.width / 60, y: footer.frame.height / 2)
        button4.center = CGPoint(x: 41 * footer.frame.width / 60, y: footer.frame.height / 2)
        button5.center = CGPoint(x: 52 * footer.frame.width / 60, y: footer.frame.height / 2)
        
        button1shadowd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button2shadowd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button3shadowd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button4shadowd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button5shadowd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button1shadowd.center = CGPoint(x: button1.center.x + 5, y: button1.center.y + 5)
        button2shadowd.center = CGPoint(x: button2.center.x + 5, y: button2.center.y + 5)
        button3shadowd.center = CGPoint(x: button3.center.x + 5, y: button3.center.y + 5)
        button4shadowd.center = CGPoint(x: button4.center.x + 5, y: button4.center.y + 5)
        button5shadowd.center = CGPoint(x: button5.center.x + 5, y: button5.center.y + 5)
        button1shadow.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button2shadow.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button3shadow.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button4shadow.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button5shadow.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button1shadow.center = CGPoint(x: button1.center.x - 5, y: button1.center.y - 5)
        button2shadow.center = CGPoint(x: button2.center.x - 5, y: button2.center.y - 5)
        button3shadow.center = CGPoint(x: button3.center.x - 5, y: button3.center.y - 5)
        button4shadow.center = CGPoint(x: button4.center.x - 5, y: button4.center.y - 5)
        button5shadow.center = CGPoint(x: button5.center.x - 5, y: button5.center.y - 5)


    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if UserDefaults.standard.string(forKey: "username") == nil{
            let vc = LoginView()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }else{
            if !view.contains(nv1) {
                configureViews()
                configureButtons()
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        if footerStyle == .hidden {
            return true
        }
        return false
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    let footer = UIView()
    let footerShadowDark = UIView()
    let footerShadowWhite = UIView()
    
    let button5 = FooterButton()
    let button4 = FooterButton()
    let button3 = FooterButton()
    let button2 = FooterButton()
    let button1 = FooterButton()
    let button5shadow = UIView()
    let button4shadow = UIView()
    let button3shadow = UIView()
    let button2shadow = UIView()
    let button1shadow = UIView()
    let button5shadowd = UIView()
    let button4shadowd = UIView()
    let button3shadowd = UIView()
    let button2shadowd = UIView()
    let button1shadowd = UIView()
    
    let nv1 = UINavigationController()
    let nv2 = UINavigationController()
    let nv3 = UINavigationController()
    let nv4 = UINavigationController()
    
    enum footerType {
        case hidden
        case appear
    }
    enum buttonType {
        case home
        case search
        case notification
        case user
    }
    var currentButtonType: buttonType = .home
    var footerStyle: footerType = .appear
    
    func configureViews() {
        //挿入するレイヤーを指定する場合は以下のように書く
        //view.insertSubview(vc.view, at: 0)
        
        let vc = ViewController2()
        nv1.addChild(vc)
        addChild(nv1)
        view.addSubview(nv1.view)
        nv1.didMove(toParent: self)
        
        let vc2 = UserViewController(string: UserDefaults.standard.string(forKey: "username")!,
                                     userid: UserDefaults.standard.integer(forKey: "userid"),
                                     profpath: UserDefaults.standard.string(forKey: "profilePath") ?? "")
        nv2.addChild(vc2)
        addChild(nv2)
        view.addSubview(nv2.view)
        nv2.didMove(toParent: self)
        nv2.isNavigationBarHidden = true
        nv2.view.isHidden = true
        
        let vc3 = SearchViewController()
        nv3.addChild(vc3)
        addChild(nv3)
        view.addSubview(nv3.view)
        nv3.didMove(toParent: self)
        nv3.isNavigationBarHidden = true
        nv3.view.isHidden = true
        
        
        let vc4 = NotificationViewController()
        nv4.addChild(vc4)
        addChild(nv4)
        view.addSubview(nv4.view)
        nv4.didMove(toParent: self)
        nv4.isNavigationBarHidden = true
        nv4.view.isHidden = true
    }
    func configureButtons() {
        view.addSubview(footerShadowWhite)
        footerShadowWhite.backgroundColor = .footerColor
        footerShadowWhite.layer.masksToBounds = false
        footerShadowWhite.layer.cornerRadius = 30
        footerShadowWhite.layer.cornerCurve = .continuous
        footerShadowWhite.layer.shadowColor = UIColor.black.cgColor
        footerShadowWhite.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        footerShadowWhite.layer.shadowRadius = 4.0
        footerShadowWhite.layer.shadowOpacity = 0.2
        
        //view.addSubview(footerShadowDark)
        footerShadowDark.backgroundColor = .footerColor
        footerShadowDark.layer.masksToBounds = false
        footerShadowDark.layer.cornerRadius = 30
        footerShadowDark.layer.cornerCurve = .continuous
        footerShadowDark.layer.shadowColor = UIColor.white.cgColor
        footerShadowDark.layer.shadowOffset = CGSize(width: -2.0, height: -2.0)
        footerShadowDark.layer.shadowRadius = 4.0
        footerShadowDark.layer.shadowOpacity = 0.2
        
        view.addSubview(footer)
        footer.layer.cornerRadius = 30
        footer.layer.cornerCurve = .continuous
        footer.backgroundColor = .footerColor
        
        button5.addTarget(self, action: #selector(user(_:)), for: .touchUpInside)
        button4.addTarget(self, action: #selector(bell(_:)), for: .touchUpInside)
        button3.addTarget(self, action: #selector(addPost(_:)), for: .touchUpInside)
        button2.addTarget(self, action: #selector(find(_:)), for: .touchUpInside)
        button1.addTarget(self, action: #selector(home(_:)), for: .touchUpInside)
        
        let shadows = [button1shadow,button2shadow,button3shadow,button4shadow,button5shadow]
        for shadow in shadows {
            shadow.backgroundColor = .footerColor
            shadow.layer.cornerRadius = 10
            shadow.layer.cornerCurve = .continuous
            footer.addSubview(shadow)
        }
        
        let shadowsd = [button1shadowd,button2shadowd,button3shadowd,button4shadowd,button5shadowd]
        for shadow in shadowsd {
            shadow.backgroundColor = .footerColor
            shadow.layer.cornerRadius = 15
            shadow.layer.cornerCurve = .continuous
            footer.addSubview(shadow)
        }
        
        let buttons = [button1,button2,button3,button4,button5]
        for i in 0..<buttons.count{
            buttons[i].layer.masksToBounds = true
            buttons[i].tintColor = .secondaryLabel
            buttons[i].backgroundColor = .footerColor
            footer.addSubview(buttons[i])
        }
        
        
        setButton(buttonType: .home)

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setButton(buttonType: self.currentButtonType)
    }
    
    func setButton(buttonType:buttonType) {
        let image1 = UIImage(systemName: "house", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold))
        let image2 = UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold))
        let image3 = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold))
        let image4 = UIImage(systemName: "bell", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold))
        let image5 = UIImage(systemName: "person", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold))
        let image1f = UIImage(systemName: "house", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy))
        let image2f = UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy))
        let image4f = UIImage(systemName: "bell.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy))
        let image5f = UIImage(systemName: "person.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy))
        
        button1.setImage(image1, for: .normal)
        button2.setImage(image2, for: .normal)
        button3.setImage(image3, for: .normal)
        button4.setImage(image4, for: .normal)
        button5.setImage(image5, for: .normal)
        
        let shadows = [button1shadow,button2shadow,button3shadow,button4shadow,button5shadow]
        for shadow in shadows{
            shadow.layer.shadowColor = UIColor.white.cgColor
            shadow.layer.shadowOffset = CGSize(width: -2.0, height: -2.0)
            shadow.layer.shadowRadius = 8.0
            switch UITraitCollection.isDarkMode {
            case true:
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                    shadow.layer.shadowOpacity = 0.08
                }, completion: nil)
            case false:
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                    shadow.layer.shadowOpacity = 0.8
                }, completion: nil)
            }
        }
        
        let shadowsd = [button1shadowd,button2shadowd,button3shadowd,button4shadowd,button5shadowd]
        for shadow in shadowsd{
            shadow.layer.shadowColor = UIColor.black.cgColor
            shadow.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            shadow.layer.shadowRadius = 5.0
            switch UITraitCollection.isDarkMode {
            case true:
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                    shadow.layer.shadowOpacity = 0.8
                }, completion: nil)
            case false:
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                    shadow.layer.shadowOpacity = 0.2
                }, completion: nil)
            }
        }
        
        let buttons = [button1,button2,button3,button4,button5]
        for button in buttons {
            button.innerlayer1.shadowOpacity = 0
            button.innerlayer2.shadowOpacity = 0
        }
        
        switch buttonType {
        case .home:
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                self.button1shadow.layer.shadowOpacity = 0
                self.button1shadowd.layer.shadowOpacity = 0
                self.button1.innerlayer1.shadowOpacity = 0.1
                self.button1.innerlayer2.shadowOpacity = 0.1
                self.button1.setImage(image1f, for: .normal)
            }, completion: nil)
        case .search:
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                self.button2shadow.layer.shadowOpacity = 0
                self.button2shadowd.layer.shadowOpacity = 0
                self.button2.innerlayer1.shadowOpacity = 0.1
                self.button2.innerlayer2.shadowOpacity = 0.1
                self.button2.setImage(image2f, for: .normal)
            }, completion: nil)
        case .notification:
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                self.button4shadow.layer.shadowOpacity = 0
                self.button4shadowd.layer.shadowOpacity = 0
                self.button4.innerlayer1.shadowOpacity = 0.1
                self.button4.innerlayer2.shadowOpacity = 0.1
                self.button4.setImage(image4f, for: .normal)
            }, completion: nil)
        case .user:
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                self.button5shadow.layer.shadowOpacity = 0
                self.button5shadowd.layer.shadowOpacity = 0
                self.button5.innerlayer1.shadowOpacity = 0.1
                self.button5.innerlayer2.shadowOpacity = 0.1
                self.button5.setImage(image5f, for: .normal)
            }, completion: nil)
        }
        
        currentButtonType = buttonType
    }
    
    @objc func home(_ sender: UIButton) {
        if nv1.view.isHidden{
            nv4.view.isHidden = true
            nv3.view.isHidden = true
            nv2.view.isHidden = true
            nv1.view.isHidden = false
            setButton(buttonType: .home)
        }else{
            NotificationCenter.default.post(name: .home, object: nil)
        }
    }
    
    @objc func addPost(_ sender: UIButton) {
        let vc = NewPostViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func user(_ sender: UIButton) {
        if nv2.view.isHidden{
            nv4.view.isHidden = true
            nv3.view.isHidden = true
            nv2.view.isHidden = false
            nv1.view.isHidden = true
            setButton(buttonType: .user)
        }else{
            NotificationCenter.default.post(name: .user, object: nil)
        }
    }
    
    @objc func bell(_ sender: UIButton){
        if nv4.view.isHidden{
            nv4.view.isHidden = false
            nv3.view.isHidden = true
            nv2.view.isHidden = true
            nv1.view.isHidden = true
            setButton(buttonType: .notification)
        }else{
            NotificationCenter.default.post(name: .bell, object: nil)
        }
    }
    
    @objc func find(_ sender: UIButton){
        if nv3.view.isHidden{
            nv4.view.isHidden = true
            nv3.view.isHidden = false
            nv2.view.isHidden = true
            nv1.view.isHidden = true
            setButton(buttonType: .search)
        }else{
            NotificationCenter.default.post(name: .find, object: nil)
        }
    }
    
    
    //MARK: -Bar Animation
    //Hide Footer Only
    @objc func hideFooter(_ sender: Notification) {
        if footerStyle == .appear {
            self.footerStyle = .hidden
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
                self.footer.center.y += 120
                self.footerShadowWhite.center.y += 120
                self.footerShadowDark.center.y += 120
            }, completion: nil)
        }
    }
    
    //Hide Footer and Status Bar
    @objc func hide(_ sender: Notification) {
        if footerStyle == .appear {
            self.footerStyle = .hidden
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
                self.footer.center.y += 120
                self.footerShadowWhite.center.y += 120
                self.footerShadowDark.center.y += 120
            }, completion: nil)
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
                self.setNeedsStatusBarAppearanceUpdate()
            }, completion: nil)
        }
    }
    
    @objc func show(_ sender: Notification) {
        if footerStyle == .hidden{
            self.footerStyle = .appear
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveLinear, animations: {
                self.setNeedsStatusBarAppearanceUpdate()
                self.footer.center.y -= 120
                self.footerShadowWhite.center.y -= 120
                self.footerShadowDark.center.y -= 120
            }, completion: nil)
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    
}
extension UITraitCollection {
    public static var isDarkMode: Bool {
        if current.userInterfaceStyle == .dark {
            return true
        }
        return false
    }

}

class FooterButton: UIButton{
    let innerlayer1 = CALayer()
    let innerlayer2 = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.tintColor = .systemGray
        self.layer.cornerRadius = 15
        self.layer.cornerCurve = .continuous
        
        let path = UIBezierPath(rect: CGRect(x: -5.0, y: -10.0, width: self.bounds.size.width + 5.0, height: 10.0 ))
        innerlayer1.frame = self.bounds
        innerlayer1.masksToBounds = true
        innerlayer1.shadowColor = UIColor.black.cgColor
        innerlayer1.shadowOffset = CGSize(width: 5.0, height: 5.0)
        innerlayer1.shadowOpacity = 0.1
        innerlayer1.shadowPath = path.cgPath
        
        let path2 = UIBezierPath(rect: CGRect(x: -10.0, y: -5.0, width: 10, height: self.bounds.size.height + 5.0 ))
        innerlayer2.frame = self.bounds
        innerlayer2.masksToBounds = true
        innerlayer2.shadowColor = UIColor.black.cgColor
        innerlayer2.shadowOffset = CGSize(width: 5.0, height: 5.0)
        innerlayer2.shadowOpacity = 0.1
        innerlayer2.shadowPath = path2.cgPath
        
        self.layer.addSublayer(innerlayer1)
        self.layer.addSublayer(innerlayer2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Notification.Name {
    static let home = Notification.Name("home")
    static let user = Notification.Name("user")
    static let find = Notification.Name("find")
    static let bell = Notification.Name("bell")
    static let hide = Notification.Name("hide")
    static let show = Notification.Name("show")
    static let hifo = Notification.Name("hifo")
}
