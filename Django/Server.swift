//
//  Server.swift
//  Django
//
//  Created by YUKITO on 2020/01/26.
//  Copyright © 2020 TJ-Tech. All rights reserved.
//

import Foundation
import Alamofire

#if targetEnvironment(simulator)
public let client = "http://127.0.0.1:8000/"
public let tokenn = "token 8e038cecfe174f43035b650bfc5b0fad14cb1625"
#else
public let client = "http://118.27.25.245:8000/"
public let tokenn = "token cf89456e3f21b8b4d269a7275871d0c3c058f829"
#endif

struct ServerStruct {
    
    var delegate: ServerClassDelegate?
    
    func likePost(pk:Int) {
        let params: [String: Any?] = [
            "id" : String(pk),
            "like": "true",
            "request_user_id" : UserDefaults.standard.string(forKey: "userid")!,
        ]
        let url = client + "api/posts/like/"
        let headers: HTTPHeaders = [
            "Contenttype": "application/json",
            "Authorization": UserDefaults.standard.string(forKey: "token")!,
        ]
        Alamofire.request(url, method: .post, parameters: params as Parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let result = response.result.value as? [String: Any] {
                print(result)
                guard let like = result["Like"] else {
                    return
                }
                if like as! String == "True"{
                    self.delegate?.onSuccessLike(like: true)
                }else{
                    self.delegate?.onSuccessLike(like: false)
                }
            }
        }
    }
    
    func deletePost(pk:Int) {
        let params: [String: Any?] = [
            "id" : String(pk),
            "delete": "true",
            "request_user_id" : UserDefaults.standard.string(forKey: "userid")!,
        ]
        let url = client + "api/posts/delete/"
        let headers: HTTPHeaders = [
            "Contenttype": "application/json",
            "Authorization": UserDefaults.standard.string(forKey: "token")!,
        ]
        Alamofire.request(url, method: .post, parameters: params as Parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let result = response.result.value as? [String: Any] {
                print(result)
                self.delegate?.onSuccessDelete()
            }
        }
    }
    
    func followUser(pk:Int) {
        let params: [String: Any?] = [
            "id" : String(pk),
            "request_user_id" : UserDefaults.standard.string(forKey: "userid")!,
        ]
        let url = client + "api/user/follow/"
        let headers: HTTPHeaders = [
            "Contenttype": "application/json",
            "Authorization": UserDefaults.standard.string(forKey: "token")!,
        ]
        Alamofire.request(url, method: .post, parameters: params as Parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let result = response.result.value as? [String: Any] {
                print(result)
                guard let follow = result["Follow"] else {
                    return
                }
                if follow as! String == "True"{
                    self.delegate?.onSuccessFollow(follow: true)
                }else{
                    self.delegate?.onSuccessFollow(follow: false)
                }
            }
        }
    }
    
    func userDtail(pk:Int) {
        let params: [String: Any?] = [
            "id" : String(pk),
            "request_user_id" : UserDefaults.standard.string(forKey: "userid")!,
        ]
        let url = client + "api/user/detail/"
        let headers: HTTPHeaders = [
            "Contenttype": "application/json",
            "Authorization": UserDefaults.standard.string(forKey: "token")!,
        ]
        Alamofire.request(url, method: .post, parameters: params as Parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let result = response.result.value as? [String: Any] {
                print(result)
                guard let following = result["Following"] else {
                    return
                }
                
                let bio = result["bio"] as? String
                
                if following as! String == "None"{
                    self.delegate?.onSuccessGetUserDetail(follow: nil,bio: bio)
                }
                if following as! String == "True"{
                    self.delegate?.onSuccessGetUserDetail(follow: true,bio: bio)
                }else{
                    self.delegate?.onSuccessGetUserDetail(follow: false,bio: bio)
                }
            }
        }
    }
    
    func post(pic: UIImage,text:String) {
        let url = client + "api/post/new/"
        
        let headers: HTTPHeaders = [
            "Contenttype": "application/json",
            "Authorization": UserDefaults.standard.string(forKey: "token")!,
        ]
        
        let pic = pic
        let data: NSData = pic.jpegData(compressionQuality: 1)! as NSData
        let data2: Data = data as Data
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(data2, withName: "picture", fileName: "Hello.jpg", mimeType: "image/jpeg")
            multipartFormData.append(UserDefaults.standard.string(forKey: "userid")!.data(using: .utf8)!, withName: "request_user_id")
            multipartFormData.append((text).data(using: .utf8)!, withName: "text")
        }, to: url, headers: headers, encodingCompletion: {encodingResult in
            switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseString { response in
                        let responseData = response
                        print(responseData)
                        self.delegate?.onSuccessPost()
                    }
                case .failure(let encodingError):
                    print(encodingError)
            }
        })
    }
    
    func comment(text:String,pk:Int) {
        let url = client + "api/comment/create/"
        
        let headers: HTTPHeaders = [
            "Contenttype": "application/json",
            "Authorization": UserDefaults.standard.string(forKey: "token")!,
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(UserDefaults.standard.string(forKey: "userid")!.data(using: .utf8)!, withName: "request_user_id")
            multipartFormData.append((text).data(using: .utf8)!, withName: "text")
            multipartFormData.append((String(pk)).data(using: .utf8)!, withName: "postid")
        }, to: url, headers: headers, encodingCompletion: {encodingResult in
            switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseString { response in
                        let responseData = response
                        print(responseData)
                        self.delegate?.onSuccessComment()
                    }
                case .failure(let encodingError):
                    print(encodingError)
            }
        })
    }
    
    func comment(text:String,pk:Int,parent:Int) {
        let url = client + "api/comment/reply/"
        
        let headers: HTTPHeaders = [
            "Contenttype": "application/json",
            "Authorization": UserDefaults.standard.string(forKey: "token")!,
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(UserDefaults.standard.string(forKey: "userid")!.data(using: .utf8)!, withName: "request_user_id")
            multipartFormData.append((text).data(using: .utf8)!, withName: "text")
            multipartFormData.append((String(pk)).data(using: .utf8)!, withName: "postid")
            multipartFormData.append((String(parent)).data(using: .utf8)!, withName: "parent")
        }, to: url, headers: headers, encodingCompletion: {encodingResult in
            switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseString { response in
                        let responseData = response
                        print(responseData)
                        self.delegate?.onSuccessComment()
                    }
                case .failure(let encodingError):
                    print(encodingError)
            }
        })
    }
    
    func editUser(bio:String,pic:UIImage) {
        let url = client + "api/user/edit/"
        
        let headers: HTTPHeaders = [
            "Contenttype": "application/json",
            "Authorization": UserDefaults.standard.string(forKey: "token")!,
        ]
        
        let pic = pic
        let data: NSData = pic.jpegData(compressionQuality: 1)! as NSData
        let data2: Data = data as Data
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(data2, withName: "profile", fileName: "Hello.jpg", mimeType: "image/jpeg")
            multipartFormData.append(UserDefaults.standard.string(forKey: "userid")!.data(using: .utf8)!, withName: "userid")
            multipartFormData.append((bio).data(using: .utf8)!, withName: "bio")
        }, to: url, headers: headers, encodingCompletion: {encodingResult in
            switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseString { response in
                        let responseData = response
                        print(responseData)
                        self.delegate?.onSuccessUserEdit()
                    }
                case .failure(let encodingError):
                    print(encodingError)
            }
        })
    }
    
    func getPost() {
        var post_id:Array<Int> = []
        var text:Array<String?> = []
        var username:Array<String> = []
        var user_id:Array<Int> = []
        var imagePath:Array<String?> = []
        var profilePath:Array<String?> = []
        
        guard let _ = UserDefaults.standard.string(forKey: "token")else {
            return
        }
        let headers: HTTPHeaders = [
            "Contenttype": "application/json",
            "Authorization": UserDefaults.standard.string(forKey: "token")!,
        ]
        Alamofire.request(client + "api/entries/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {response in
            if let data = response.data, let _ = String(data: data, encoding: .utf8) {
                text = []
                imagePath = []
                profilePath = []
                username = []
                post_id = []
                user_id = []
                guard let _ = response.result.value else{
                    return
                }
                let responseData = response.result.value as! NSDictionary
                for postData in responseData["results"] as! NSArray{
                    let dict = postData as! NSDictionary
                    let user = dict["author"] as! NSDictionary
                    
                    imagePath.append(dict["picture"] as! String?)
                    post_id.append(dict["id"] as! Int)
                    text.append(dict["text"] as! String?)
                    profilePath.append(user["profile_pic"] as! String?)
                    username.append(user["username"] as! String)
                    user_id.append(user["id"] as! Int)
                }
                self.delegate?.onSuccessGetPost(post_id: post_id,text: text,username: username,user_id: user_id, imagePath: imagePath,profilePath: profilePath)
            }
        }
    }
    
    func getPost(pk:Int) {
        var post_id:Array<Int> = []
        var text:Array<String?> = []
        var username:Array<String> = []
        var user_id:Array<Int> = []
        var imagePath:Array<String?> = []
        var profilePath:Array<String?> = []
        
        guard let _ = UserDefaults.standard.string(forKey: "token")else {
            return
        }
        let headers: HTTPHeaders = [
            "Contenttype": "application/json",
            "Authorization": tokenn,
        ]
        Alamofire.request(client + "api/entries/?author=" + String(pk), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {response in
            if let data = response.data, let _ = String(data: data, encoding: .utf8) {
                text = []
                imagePath = []
                profilePath = []
                username = []
                post_id = []
                user_id = []
                guard let _ = response.result.value else{
                    return
                }
                let responseData = response.result.value as! NSDictionary
                for postData in responseData["results"] as! NSArray{
                    let dict = postData as! NSDictionary
                    let user = dict["author"] as! NSDictionary
                    
                    imagePath.append(dict["picture"] as? String)
                    post_id.append(dict["id"] as! Int)
                    text.append(dict["text"] as? String)
                    profilePath.append(user["profile_pic"] as? String)
                    username.append(user["username"] as! String)
                    user_id.append(user["id"] as! Int)
                }
                self.delegate?.onSuccessGetPost(post_id: post_id,text: text,username: username,user_id: user_id, imagePath: imagePath,profilePath: profilePath)
            }
        }
    }
    
    func changePassword(password:String) {
        let url = client + "api/user/edit/password/"
        
        let params: [String: Any?] = [
            "passwd" : password,
            "userid" : UserDefaults.standard.string(forKey: "userid")!,
        ]
        let headers: HTTPHeaders = [
            "Contenttype": "application/json",
            "Authorization": UserDefaults.standard.string(forKey: "token")!,
        ]
        Alamofire.request(url, method: .post, parameters: params as Parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let result = response.result.value as? [String: Any] {
                print(result)
                print("hello")
            }
        }
    }
    
    func getComment(pk:Int) {
        var comment:Array<String> = []
        var username:Array<String> = []
        var profilePath:Array<String?> = []
        var commentid:Array<Int> = []
        
        let url = client + "api/comments/?post=" + String(pk)
        let headers: HTTPHeaders = [
            "Contenttype": "application/json",
            "Authorization": UserDefaults.standard.string(forKey: "token")!,
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let result = response.result.value as? [String: Any] {
                guard let presults = result["results"] else{
                    return
                }
                //print(presults)
                for commentData in presults as! NSArray{
                    let results = commentData as! NSDictionary
                    guard let commentText = results["comment_text"] else {
                        return
                    }
                    
                    let user = results["comment_author"] as! NSDictionary
                    
                    commentid.append(results["id"] as! Int)
                    profilePath.append(user["profile_pic"] as? String)
                    username.append(user["username"] as! String)
                    comment.append(commentText as! String)
                }
            }
            self.delegate?.onSuccessGetComment(comment: comment,profilePath: profilePath,username: username, comment_id: commentid)
        }
    }
    
    func deleteComment(pk:Int) {
        let params: [String: Any?] = [
            "commentid" : String(pk),
            "request_user_id" : UserDefaults.standard.string(forKey: "userid")!,
        ]
        let url = client + "api/comment/delete/"
        let headers: HTTPHeaders = [
            "Contenttype": "application/json",
            "Authorization": UserDefaults.standard.string(forKey: "token")!,
        ]
        Alamofire.request(url, method: .post, parameters: params as Parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let result = response.result.value as? [String: Any] {
                print(result)
            }
        }
    }
    
    func getFollowingList(userid:Int) {
        var bio:Array<String?> = []
        var username:Array<String> = []
        var profilePath:Array<String?> = []
        var id:Array<Int> = []
        
        let url = client + "api/follow/?following=" + String(userid)
        let headers: HTTPHeaders = [
            "Contenttype": "application/json",
            "Authorization": UserDefaults.standard.string(forKey: "token")!,
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let result = response.result.value as? [String: Any] {
                guard let presults = result["results"] else{
                    return
                }
                //print(presults)
                for commentData in presults as! NSArray{
                    let results = commentData as! NSDictionary
                    guard let follower = results["follower"] else {
                        return
                    }
                    
                    let user = follower as! NSDictionary
                    
                    id.append(user["id"] as! Int)
                    profilePath.append(user["profile_pic"] as? String)
                    username.append(user["username"] as! String)
                    bio.append(user["bio"] as? String)
                }
            }
        }
    }
    
    func getFollowerList(userid:Int) {
        var bio:Array<String?> = []
        var username:Array<String> = []
        var profilePath:Array<String?> = []
        var id:Array<Int> = []
        
        let url = client + "api/follow/?follower=" + String(userid)
        let headers: HTTPHeaders = [
            "Contenttype": "application/json",
            "Authorization": UserDefaults.standard.string(forKey: "token")!,
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let result = response.result.value as? [String: Any] {
                guard let presults = result["results"] else{
                    return
                }
                //print(presults)
                for commentData in presults as! NSArray{
                    let results = commentData as! NSDictionary
                    guard let follower = results["follower"] else {
                        return
                    }
                    
                    let user = follower as! NSDictionary
                    
                    id.append(user["id"] as! Int)
                    profilePath.append(user["profile_pic"] as? String)
                    username.append(user["username"] as! String)
                    bio.append(user["bio"] as? String)
                }
            }
        }
    }
    
    func getUserByName(name:String) {
        let headers: HTTPHeaders = [
            "Contenttype": "application/json",
            "Authorization": tokenn,
        ]
        
        var user_id:Array<Int> = []
        var profilePath:Array<String?> = []
        var username:Array<String> = []
        var text:Array<String?> = []
        
        Alamofire.request(client + "api/users/?username=" + name, method: .get, parameters:nil, encoding: JSONEncoding.default, headers: headers).responseJSON {response in
            if let data = response.data, let _ = String(data: data, encoding: .utf8) {
                let responseData = response.result.value as! NSDictionary
                for postData in responseData["results"] as! NSArray{
                    let dict = postData as! NSDictionary
                    
                    guard let _ = dict["id"] else {
                        return
                    }
                    
                    if let uid = dict["id"] as? Int{
                        user_id.append(uid)
                    }
                    profilePath.append(dict["profile_pic"] as? String)
                    username.append(dict["username"] as! String)
                    text.append(dict["bio"] as? String)
                }
                self.delegate?.searchResult(user_id: user_id, profilePath: profilePath, username: username, text: text)
            }
        }
    }
}

protocol ServerClassDelegate {
    func onSuccessComment()
    func onSuccessPost()
    func onSuccessDelete()
    func onSuccessLike(like:Bool)
    func onSuccessFollow(follow:Bool)
    func onSuccessUserEdit()

    func onSuccessGetUserDetail(follow:Bool?,bio:String?)
    func onSuccessGetPost(post_id:Array<Int>,text:Array<String?>,username:Array<String>,user_id:Array<Int>,imagePath:Array<String?>,profilePath:Array<String?>)
    func onSuccessGetComment(comment:Array<String>,profilePath:Array<String?>,username:Array<String>,comment_id:Array<Int>)
    func searchResult(user_id:Array<Int>,profilePath:Array<String?>,username:Array<String>,text:Array<String?>)
}

extension ServerClassDelegate{
    func onSuccessComment(){
        print("none")
    }
    func onSuccessPost(){
        print("none")
    }
    func onSuccessDelete(){
        print("none")
    }
    func onSuccessLike(like:Bool){
        print("none")
    }
    func onSuccessFollow(follow:Bool){
        print("none")
    }
    func onSuccessUserEdit(){
        print("none")
    }
    
    func onSuccessGetUserDetail(follow:Bool?,bio:String?){
        print("none")
    }
    func onSuccessGetPost(post_id:Array<Int>,text:Array<String?>,username:Array<String>,user_id:Array<Int>,imagePath:Array<String?>,profilePath:Array<String?>) {
        print("none")
    }
    func onSuccessGetComment(comment:Array<String>,profilePath:Array<String?>,username:Array<String>,comment_id:Array<Int>){
        print("none")
    }
    func searchResult(user_id:Array<Int>,profilePath:Array<String?>,username:Array<String>,text:Array<String?>){
        print("none")
    }
}


