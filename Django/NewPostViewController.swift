//
//  NewPostViewController.swift
//  Django
//
//  Created by YUKITO on 2020/02/05.
//  Copyright © 2020 TJ-Tech. All rights reserved.
//

import Foundation
import UIKit
import Photos
import CropViewController

/// - Tag: NewPost
class NewPostViewController:UIViewController,UICollectionViewDelegate,UIScrollViewDelegate ,UITextFieldDelegate{
    override func viewDidLayoutSubviews() {
        scrollView.frame = view.frame
        scrollView.contentSize = CGSize(width: view.frame.width*2, height: view.frame.height)
        
        //Page1
        collection.frame = CGRect(x: 0, y: view.safeAreaInsets.top + 50, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top - 50)
        button.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 10, width: 100, height: 30)
        
        //Page2
        backButton.frame = CGRect(x: view.frame.width+20, y: view.safeAreaInsets.top + 10, width: 100, height: 30)
        postButton.frame = CGRect(x: view.frame.width * 2 - 120, y: view.safeAreaInsets.top + 10, width: 100, height: 30)
        image.frame = CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: view.frame.width)
        textField.frame = CGRect(x: view.frame.width+10, y: image.frame.maxY+10, width: view.frame.width-20, height: view.frame.height-image.frame.maxY)
        cropButton.frame = CGRect(x: view.frame.width*2 - 50, y: image.frame.maxY+10, width: 40, height: 40)
    }
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        server.delegate = self
        
        libraryRequestAuthorization()
        
        //Get Photos
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        }
        
        configure()
        configureCollection()
    }
    
    let button = UIButton()
    let backButton = UIButton()
    let postButton = UIButton()
    let cropButton = UIButton()
    var collection: UICollectionView!
    let textField = UITextField()
    var server = ServerStruct()
    var fetchResult: PHFetchResult<PHAsset>!
    
    var image = UIImageView()
    var scrollView = UIScrollView()
    
    func configure(){
        scrollView.isScrollEnabled = false
        view.addSubview(scrollView)
        
        textField.placeholder = "Type something..."
        textField.contentVerticalAlignment = .top
        textField.delegate = self
        textField.returnKeyType = .done
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        scrollView.addSubview(textField)
        
        image.contentMode = UIView.ContentMode.scaleAspectFill
        image.clipsToBounds = true
        image.layer.masksToBounds = true
        
        cropButton.setImage(UIImage(systemName: "crop",withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)), for: .normal)
        cropButton.tintColor = .label
        cropButton.addTarget(self, action: #selector(crop(_:)), for: .touchUpInside)
        
        scrollView.addSubview(image)
        scrollView.addSubview(cropButton)
        
        let array = [button,backButton,postButton]
        
        for button in array{
            button.setTitleColor(.label, for: .normal)
            button.tintColor = .label
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .light)
            scrollView.addSubview(button)
        }
        button.setTitle("Cancel", for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        backButton.contentHorizontalAlignment = .left
        postButton.setTitle("Post", for: .normal)
        postButton.addTarget(self, action: #selector(postButton(_:)), for: .touchUpInside)
        postButton.contentHorizontalAlignment = .right
        postButton.isEnabled = false
        postButton.setTitleColor(.systemGray4, for: .normal)
        
    }
    
    func configureCollection() {
        // UICollectionViewCellのマージン等の設定
        let flowLayout: UICollectionViewFlowLayout! = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.width/3)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumInteritemSpacing = 0   //Horisantle
        flowLayout.minimumLineSpacing = 0        //Vertical
        
        collection = UICollectionView(frame: view.frame,collectionViewLayout: flowLayout)
        collection.backgroundColor = .clear
        collection.dataSource = self
        collection.delegate = self
        collection.register(CameraRollCollectionViewCell.self, forCellWithReuseIdentifier: "cameraCell")
        
        collection.alwaysBounceVertical = true
        
        scrollView.addSubview(collection)
        
        
    }
    
    // カメラロールへのアクセス許可
    fileprivate func libraryRequestAuthorization() {
        PHPhotoLibrary.requestAuthorization({ [weak self] status in
            guard let wself = self else {
                return
            }
            switch status {
            case .authorized:
                print("")
            case .denied:
                wself.showDeniedAlert()
            case .notDetermined:
                print("NotDetermined")
            case .restricted:
                print("Restricted")
            @unknown default:
                fatalError()
            }
        })
    }
    
    // カメラロールへのアクセスが拒否されている場合のアラート
    fileprivate func showDeniedAlert() {
        let alert: UIAlertController = UIAlertController(title: "エラー",
                                                         message: "「写真」へのアクセスが拒否されています。設定より変更してください。",
                                                         preferredStyle: .alert)
        let cancel: UIAlertAction = UIAlertAction(title: "キャンセル",
                                                  style: .cancel,
                                                  handler: nil)
        let ok: UIAlertAction = UIAlertAction(title: "設定画面へ",
                                              style: .default,
                                              handler: { [weak self] (action) -> Void in
                                                guard let wself = self else {
                                                    return
                                                }
                                                wself.transitionToSettingsApplition()
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    //設定へ飛ばす
    fileprivate func transitionToSettingsApplition() {
        let url = URL(string: UIApplication.openSettingsURLString)
        if let url = url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    //MARK: -Action
    
    //change button color
    @objc func textFieldDidChange(_ sender: UITextField) {
        if textField.text != nil && textField.text != ""{
            postButton.isEnabled = true
            postButton.setTitleColor(.label, for: .normal)
        }else{
            postButton.isEnabled = false
            postButton.setTitleColor(.systemGray4, for: .normal)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @objc func crop(_ sender: UIButton) {
        let cropViewController = CropViewController(image: image.image!)
//        クロップするビュー
//        プロパティには以下の四つが使えそう
//        cropViewController.setAspectRatioPreset(.presetSquare, animated: true)
//        cropViewController.aspectRatioLockEnabled = true
//        cropViewController.aspectRatioPickerButtonHidden = true
//        cropViewController.resetButtonHidden = true
        cropViewController.delegate = self
        present(cropViewController, animated: true, completion: nil)
    }
    
    @objc func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func back(_ sender: UIButton) {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @objc func postButton(_ sender: UIButton) {
        if let text = textField.text{
            let h = image.image?.size.height
            let w = image.image?.size.width
            let quality = 2500/(h!+w!)
            let postImage = image.image!
            self.server.post(pic: postImage.resized(withPercentage: quality)!, text: text)
            postButton.isEnabled = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .exact
        
        let asset = fetchResult.object(at: indexPath.row)
        

        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options, resultHandler: { image, _ in
            guard let image = image else { return }
            
            self.image.image = image
            
            self.scrollView.setContentOffset(CGPoint(x: self.view.frame.width, y: 0), animated: true)
        })
    }
}

extension NewPostViewController: CropViewControllerDelegate{
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.image.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

extension NewPostViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cameraCell", for: indexPath) as! CameraRollCollectionViewCell
        let asset = fetchResult.object(at: indexPath.row)
        cell.setConfigure(assets: asset)
        return cell
    }
    
}

extension NewPostViewController: ServerClassDelegate {
    func onSuccessPost() {
        self.dismiss(animated: true, completion: nil)
    }
}

class CameraRollCollectionViewCell:UICollectionViewCell {
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        
        self.contentView.addSubview(imageView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setConfigure(assets: PHAsset) {
        let manager = PHImageManager()
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .exact
        
        manager.requestImage(for: assets,
                             targetSize: frame.size,
                             contentMode: .aspectFill,
                             options: options,
                             resultHandler: { [weak self] (image, info) in
                                guard let wself = self, let _ = image else {
                                    return
                                }
                                wself.imageView.image = image
        })
    }
}
