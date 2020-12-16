# Coding Guide 

## Overview 
The Root View Controller is 
[[Root View](x-source-tag://RootView)]

Components List:
[[PostList View](x-source-tag://PostList)]
[[Search View](x-source-tag://Search)]
[[New Post View](x-source-tag://NewPost)]
[[Notification View](x-source-tag://Notification)]
[[UserDetail View](x-source-tag://UserDetail)]

InDepth:
[[UserDetail View](x-source-tag://PostDetail)]
[[Login View](x-source-tag://LoginView)]





## Component Structure Guide

.background color and components are set in the following.

```swift
    //ViewController
    viewDidLoad(){
        view.backgroundColor = .white
    }
 
    //Other components
    configure()
    configureComponents()
    configureCollection()
 
    //CollectionView Cell
    init()
```

Color settings are in StringExtension.swift

Make sure that  all components' frames are set in 
```swift
    override func viewDidLayoutSubviews(){
        //code
    }
```

- Note: Except for PostDetail() : due to technical problems, it is set in configure() or configureAgain() Sorry for the weird naming


## Maximum Number of Characters 
Comment : 100
PostText : 200
Bio : 250
username : 150


## Change Password
パスワードが数字のみではないかなどはローカルで確認をするようにしてください


## Delegate
処理を任せて、終わったら伝えること
 使用法
 
 ```swift
    ServerStructDelegate //を適合して
    let Server = ServerStruct()
    Server.delegate = self 
 
    //終了の通知は
    func onSuccessPost(){
    }
```

## Post Detail
PostDetail() Viewを呼び出す際には、とりあえずこれを呼び出してください。

```swift
    NotificationCenter.default.post(name: .hide, object: nil)//Hide Footer
```

## Footer
hide footer only:
```swift
    NotificationCenter.default.post(name: .hifo, object: nil)//Hide Footer
```
hide footer and status bar:
```swift
    NotificationCenter.default.post(name: .hide, object: nil)//Hide Footer
```
show footer and status bar:
```swift
    NotificationCenter.default.post(name: .show, object: nil)//Show Footer
```











#### Personal Memo:
観光名所ごと
写真と言葉の共存
ハッシュタグボタン
文字数制限
