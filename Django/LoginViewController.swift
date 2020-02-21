//
//  ViewController.swift
//  Django
//
//  Created by YUKITO on 2020/01/12.
//  Copyright © 2020 TJ-Tech. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

/// - Tag: LoginView
class LoginView: UIViewController, UITextFieldDelegate{
    
    //MARK: -Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    override func viewWillLayoutSubviews() {
        let width = view.frame.width
        userFeild.frame = CGRect(x: 25, y: view.safeAreaInsets.top + 150, width: width-50, height: 50)
        passFeild.frame = CGRect(x: 25, y: userFeild.frame.maxY + 30, width: width-50, height: 50)
        userLabel.frame = CGRect(x: userFeild.frame.minX, y: userFeild.frame.minY - 30, width: 100, height: 30)
        passLabel.frame = CGRect(x: userFeild.frame.minX, y: passFeild.frame.minY - 30, width: 100, height: 30)
        button1.frame = CGRect(x: 25, y: passFeild.frame.maxY + 40, width: width-50, height: 50)
        line.frame = CGRect(x: passFeild.frame.minX, y: button1.frame.maxY + 20, width: view.frame.width - 50, height: 0.5)
        button2.frame = CGRect(x: 25, y: line.frame.maxY + 20, width: width-50, height: 50)
    }
    
    //MARK: -Components
    let userLabel = UILabel()
    let passLabel = UILabel()
    
    let button1 = LoginButton()
    let button2 = UIButton()
    
    let userFeild = UITextField()
    let passFeild = UITextField()
    let imageView = UIImageView()
    
    let line = UIView()
    
    func configure() {
        self.view.backgroundColor = .white
        imageView.frame = view.frame
        imageView.image = UIImage(named: "login.jpeg")
        imageView.contentMode = .scaleAspectFill
        
        button1.setTitle("Login", for: .normal)
        button1.setTitleColor(.white, for: .normal)
        button1.layer.cornerRadius = 10
        button1.layer.cornerCurve = .continuous
        button1.backgroundColor = .black
        button1.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)
        
        button2.setTitle("create an account", for: .normal)
        button2.setTitleColor(.systemGray, for: .normal)
        button2.layer.cornerRadius = 10
        button2.addTarget(self, action: #selector(create(_:)), for: .touchUpInside)
        
        userFeild.textContentType = .username
        userFeild.returnKeyType = .next
        
        passFeild.textContentType = .password
        passFeild.returnKeyType = .done
        passFeild.isSecureTextEntry = true
        
        let feilds = [userFeild,passFeild]
        for feild in feilds{
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
            paddingView.backgroundColor = .clear
            feild.leftView = paddingView
            feild.leftViewMode = .always
            
            feild.layer.cornerCurve = .continuous
            feild.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.2)
            feild.autocorrectionType = .no
            feild.autocapitalizationType = .none
            feild.delegate = self
        }
        
        userLabel.text = "username:"
        passLabel.text = "password:"
        userLabel.textColor = .systemGray
        passLabel.textColor = .systemGray
        
        line.backgroundColor = .black
        
        view.addSubview(imageView)
        view.addSubview(button1)
//        view.addSubview(button2)
        view.addSubview(line)
        view.addSubview(userLabel)
        view.addSubview(passLabel)
        view.addSubview(userFeild)
        view.addSubview(passFeild)
    }
    
    //MARK: -Actions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userFeild{
            passFeild.becomeFirstResponder()
        }else if textField == passFeild{
            self.view.endEditing(true)
        }
        return true
    }
    
    @objc func login(_ sender:UIButton) {
        getToken(username: userFeild.text!, password: passFeild.text!)
    }
    
    @objc func create(_ sender:UIButton) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: -Server
    func getToken(username:String,password:String){
        let params: [String: Any?] = [
            "username" : username,
            "password": password,
        ]
        let url = client + "api/obtain_token/"
        let headers: HTTPHeaders = [
            "Contenttype": "application/json",
        ]
        
        Alamofire.request(url, method: .post, parameters: params as Parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let result = response.result.value as? [String: Any] {
                print(result)
                if let resultToken = result["token"]{
                    var token = "token "
                    token.append(resultToken as! String)
                    UserDefaults.standard.set(username, forKey: "username")
                    UserDefaults.standard.set(password, forKey: "password")
                    UserDefaults.standard.set(token, forKey: "token")
                    print(token)
                    self.getUser(name: username)
                }else{
                    self.userFeild.backgroundColor = UIColor(red: 0.5, green: 0.1, blue: 0.1, alpha: 0.2)
                    self.passFeild.backgroundColor = UIColor(red: 0.5, green: 0.1, blue: 0.1, alpha: 0.2)
                }
            }
        }
    }
    func getUser(name:String){
        let headers: HTTPHeaders = [
            "Contenttype": "application/json",
            "Authorization": tokenn,
        ]
        
        Alamofire.request(client + "api/users/?username=" + name, method: .get, parameters:nil, encoding: JSONEncoding.default, headers: headers).responseJSON {response in
            if let data = response.data, let _ = String(data: data, encoding: .utf8) {
                let responseData = response.result.value as! NSDictionary
                for postData in responseData["results"] as! NSArray{
                    let dict = postData as! NSDictionary
                    
                    if let path = dict["profile_pic"] as? String{
                        UserDefaults.standard.set(path, forKey: "profilePath")
                    }
                    if let uid = dict["id"] as? Int{
                        UserDefaults.standard.set(uid, forKey: "userid")
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
}
class LoginButton:UIButton{
    override var isHighlighted: Bool{
        didSet{
            if self.isHighlighted{
                self.backgroundColor = .darkGray
            }else{
                self.backgroundColor = .black
            }
        }
    }
}
