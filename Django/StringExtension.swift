//
//  StringExtension.swift
//  Django
//
//  Created by YUKITO on 2020/02/05.
//  Copyright © 2020 TJ-Tech. All rights reserved.
//

import Foundation
import UIKit

//MARK: -String Extension
extension String {
    var addThubnail:String{
        var str = self
        var ext = ""
        if str != ""{
            while true {
                if str.suffix(1) == "."{
                    break
                }else{
                    ext = str.suffix(1) + ext
                    str.removeLast()
                }
            }
            str.append("thumbnail.")
            str.append(ext)
        }
        return str
    }
}

extension UIColor {
    class var background: UIColor {
        get {
            .init(dynamicProvider: { (traitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1)
                case .light:
                    return UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
                case .unspecified:
                    return .systemBackground
                @unknown default: return .systemBackground
                }
            })
        }
    }
    class var footerColor: UIColor {
        get {
            .init(dynamicProvider: { (traitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
                case .light:
                    return UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
                case .unspecified:
                    return .systemBackground
                @unknown default: return .systemBackground
                }
            })
        }
    }
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    func resized(){
        
    }
}

extension UIView {
    func innerShadow() {
        let path = UIBezierPath(rect: CGRect(x: -5.0, y: -5.0, width: self.bounds.size.width + 5.0, height: 5.0 ))
        let innerLayer = CALayer()
        innerLayer.frame = self.bounds
        innerLayer.masksToBounds = true
        innerLayer.shadowColor = UIColor.black.cgColor
        innerLayer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        innerLayer.shadowOpacity = 0.5
        innerLayer.shadowPath = path.cgPath
        self.layer.addSublayer(innerLayer)
    }
}
