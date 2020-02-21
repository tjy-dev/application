//
//  Animation.swift
//  Django
//
//  Created by YUKITO on 2020/01/19.
//  Copyright © 2020 TJ-Tech. All rights reserved.
//

import Foundation
import UIKit

protocol animTransitionable {
    var cellImageView: UIImageView { get }
    var backgroundColor: UIView { get }
    var cellBackground: UIView { get }
    var profileImageView: UIImageView { get }
    var usernameView: UILabel { get }
}

class PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard let fromVC = transitionContext.viewController(forKey: .from) as? animTransitionable,
            let toVC = transitionContext.viewController(forKey: .to) as? animTransitionable else {
                transitionContext.completeTransition(false)
                return
        }
        
        //MARK: -Set ViewController
        let fromViewController = transitionContext.viewController(forKey: .from)!
        
        let toViewController = transitionContext.viewController(forKey: .to)!
        
        //MARK: -Set Floating Image
        let imageViewSnapshot = UIImageView(image: fromVC.cellImageView.image)
        imageViewSnapshot.contentMode = .scaleAspectFill
        
        imageViewSnapshot.clipsToBounds = true
        imageViewSnapshot.layer.cornerCurve = fromVC.cellImageView.layer.cornerCurve
        imageViewSnapshot.layer.cornerRadius = fromVC.cellImageView.layer.cornerRadius
        imageViewSnapshot.frame = containerView.convert(fromVC.cellImageView.frame, from: fromVC.cellImageView.superview)
        
        let profimageSnapshot = UIImageView(image: fromVC.profileImageView.image)
        profimageSnapshot.contentMode = .scaleAspectFill
        
        profimageSnapshot.clipsToBounds = true
        profimageSnapshot.layer.cornerRadius = fromVC.profileImageView.layer.cornerRadius
        profimageSnapshot.frame = containerView.convert(fromVC.profileImageView.frame,from: fromVC.profileImageView.superview)
        
        
        
        //MARK: -Background View With Correct Color
        let backgroundView = UIView()
        backgroundView.frame = fromVC.backgroundColor.frame
        backgroundView.backgroundColor = fromVC.backgroundColor.backgroundColor
        
        
        //MARK: -Other Components
        let label = UILabel()
        label.frame = containerView.convert(fromVC.usernameView.frame, from: fromVC.usernameView.superview)
        label.text = fromVC.usernameView.text ?? ""
        label.textColor = fromVC.usernameView.textColor
        
        
        //MARK: -Cell Background
        let cellBackground = UIView()
        cellBackground.frame =  containerView.convert(fromVC.cellBackground.frame, from: fromVC.cellBackground.superview)
        cellBackground.backgroundColor = fromVC.cellBackground.backgroundColor
        cellBackground.layer.cornerRadius = fromVC.cellBackground.layer.cornerRadius
        cellBackground.layer.cornerCurve = fromVC.cellBackground.layer.cornerCurve
        //cellBackground.layer.masksToBounds = fromVC.cellBackground.layer.masksToBounds
        cellBackground.layer.masksToBounds = false
        cellBackground.layer.shadowColor = fromVC.cellBackground.layer.shadowColor
        cellBackground.layer.shadowOffset = fromVC.cellBackground.layer.shadowOffset
        cellBackground.layer.shadowRadius = fromVC.cellBackground.layer.shadowRadius
        cellBackground.layer.shadowOpacity = fromVC.cellBackground.layer.shadowOpacity
        
        containerView.addSubview(backgroundView)
        
        containerView.addSubview(fromViewController.view)
        containerView.addSubview(toViewController.view)
        
        containerView.addSubview(cellBackground)
        containerView.addSubview(profimageSnapshot)
        containerView.addSubview(label)
        containerView.addSubview(imageViewSnapshot)
        
        
        fromViewController.view.isHidden = false
        toViewController.view.isHidden = true
        
        let frameAnim1 = CGRect(x: 0, y: cellBackground.frame.minY, width: UIScreen.main.bounds.width, height: cellBackground.frame.height)
        let frameAnim2 = CGRect(x: 0, y: toVC.cellBackground.frame.minY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - toVC.cellBackground.frame.minY)
        
        
        let animator1 = {
            UIViewPropertyAnimator(duration: 0.2, dampingRatio: 1.0) {
                cellBackground.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            }
        }()
        
        let animator2 = {
            UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.9) {
                cellBackground.layer.cornerRadius = 0
                cellBackground.frame = frameAnim1
            }
        }()
        
        let animator3 = {
            UIViewPropertyAnimator(duration: 0.6, dampingRatio: 0.9) {
                cellBackground.frame = frameAnim2
                cellBackground.layer.cornerRadius = 0
                imageViewSnapshot.frame = containerView.convert(toVC.cellImageView.frame, from: toVC.cellImageView.superview)
                imageViewSnapshot.layer.cornerRadius = toVC.cellImageView.layer.cornerRadius
                profimageSnapshot.frame = containerView.convert(toVC.profileImageView.frame, from: toVC.profileImageView.superview)
                profimageSnapshot.layer.cornerRadius = toVC.profileImageView.layer.cornerRadius
                label.frame = containerView.convert(toVC.usernameView.frame,from: toVC.usernameView.superview)
                
                fromViewController.view.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
                }
        }()
        
        
        animator1.addCompletion { _ in
            animator3.startAnimation()
        }
        
        animator2.addCompletion {  _ in
            animator3.startAnimation(afterDelay: 0.1)
        }
        
        animator3.addCompletion {  _ in
            imageViewSnapshot.removeFromSuperview()
            cellBackground.removeFromSuperview()
            profimageSnapshot.removeFromSuperview()
            label.removeFromSuperview()
            
            fromViewController.view.transform = CGAffineTransform(scaleX: 1, y: 1)
            fromViewController.view.removeFromSuperview()
            backgroundView.removeFromSuperview()
            
            fromViewController.view.isHidden = false
            toViewController.view.isHidden = false
            
            transitionContext.completeTransition(true)            
        }
        
        animator3.startAnimation()
        
    }
}

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
      
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
         guard let fromVC = transitionContext.viewController(forKey: .from) as? animTransitionable,
         let toVC = transitionContext.viewController(forKey: .to) as? animTransitionable else {
            transitionContext.completeTransition(false)
            return
         }
        
        //MARK: -Set ViewController
        let fromViewController = transitionContext.viewController(forKey: .from)!
        
        let toViewController = transitionContext.viewController(forKey: .to)!
        
        //MARK: -Set Floating Image
        let imageViewSnapshot = UIImageView(image: toVC.cellImageView.image)
        imageViewSnapshot.contentMode = .scaleAspectFill
        imageViewSnapshot.clipsToBounds = true
        imageViewSnapshot.frame = containerView.convert(fromVC.cellImageView.frame, from: fromVC.cellImageView.superview)
        
        let profimageSnapshot = UIImageView(image: fromVC.profileImageView.image)
        profimageSnapshot.contentMode = .scaleAspectFill

        profimageSnapshot.clipsToBounds = true
        profimageSnapshot.layer.cornerRadius = fromVC.profileImageView.layer.cornerRadius
        profimageSnapshot.frame = containerView.convert(fromVC.profileImageView.frame,from: fromVC.profileImageView.superview)
        

        //MARK: -Background View Correct Color
        let backgroundView = UIView()
        backgroundView.frame = fromVC.backgroundColor.frame
        backgroundView.backgroundColor = fromVC.backgroundColor.backgroundColor

        
        //MARK: -Other Components
        let label = UILabel()
        label.frame = containerView.convert(fromVC.usernameView.frame, from: fromVC.usernameView.superview)
        label.text = fromVC.usernameView.text ?? ""
        label.textColor = fromVC.usernameView.textColor
        
        
        //MARK: -Cell Background
        let cellBackground = UIView()
        cellBackground.frame =  containerView.convert(fromVC.cellBackground.frame, from: fromVC.cellBackground.superview)
        cellBackground.backgroundColor = fromVC.cellBackground.backgroundColor
        cellBackground.layer.masksToBounds = false
        
        cellBackground.layer.shadowColor = toVC.cellBackground.layer.shadowColor
        cellBackground.layer.shadowOffset = toVC.cellBackground.layer.shadowOffset
        cellBackground.layer.shadowRadius = toVC.cellBackground.layer.shadowRadius
        cellBackground.layer.shadowOpacity = toVC.cellBackground.layer.shadowOpacity
        
        let cellBackgroundToVC = containerView.convert(toVC.cellBackground.frame, from: toVC.cellBackground.superview)
        let imageViewToVC = containerView.convert(toVC.cellImageView.frame, from: toVC.cellImageView.superview)
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(cellBackground)
        containerView.addSubview(profimageSnapshot)
        containerView.addSubview(label)
        containerView.addSubview(imageViewSnapshot)
        
        
        
        fromViewController.view.isHidden = true
        toViewController.view.isHidden = false
        
        
        let frameAnim1 = CGRect(x: fromVC.cellBackground.frame.minX, y: cellBackgroundToVC.minY , width: UIScreen.main.bounds.width, height: cellBackgroundToVC.height)
        let frameAnim2 = CGRect(x: cellBackgroundToVC.minX, y: cellBackgroundToVC.minY, width: cellBackgroundToVC.width, height: cellBackgroundToVC.height )
        let frameImageToVC = containerView.convert(toVC.cellImageView.frame, from: toVC.cellImageView.superview)
        let frameProfileImageToVC = containerView.convert(toVC.profileImageView.frame, from: toVC.profileImageView.superview)
        
        let animator1 = {
            UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
                cellBackground.frame = frameAnim1
            }
        }()
        
        let _ = {
            UIViewPropertyAnimator(duration: 0.1, curve: .easeOut) {
                imageViewSnapshot.frame = CGRect(x: frameImageToVC.minX, y: cellBackgroundToVC.minY - (toVC.cellImageView.frame.height / 30) , width: imageViewToVC.width, height: imageViewToVC.height)
                imageViewSnapshot.layer.cornerRadius = toVC.cellImageView.layer.cornerRadius
                imageViewSnapshot.layer.cornerCurve = toVC.cellImageView.layer.cornerCurve
            }
        }()
        
        let animator3 = {
            UIViewPropertyAnimator(duration: 0.6, dampingRatio: 0.9) {
                cellBackground.frame = frameAnim2
                cellBackground.layer.cornerRadius = toVC.cellBackground.layer.cornerRadius
                imageViewSnapshot.frame = frameImageToVC
                imageViewSnapshot.layer.cornerRadius = toVC.cellImageView.layer.cornerRadius
                imageViewSnapshot.layer.cornerCurve = toVC.cellImageView.layer.cornerCurve
                profimageSnapshot.frame = frameProfileImageToVC
                profimageSnapshot.layer.cornerRadius = toVC.profileImageView.layer.cornerRadius
                profimageSnapshot.layer.cornerCurve = toVC.profileImageView.layer.cornerCurve
                label.frame = containerView.convert(toVC.usernameView.frame, from: toVC.usernameView.superview)
            }
        }()

        
        // Animations Completion Handler
        animator1.addCompletion {  _ in
             animator3.startAnimation()
        }
        
        animator3.addCompletion { _ in
            
            
            imageViewSnapshot.removeFromSuperview()
            cellBackground.removeFromSuperview()
            profimageSnapshot.removeFromSuperview()
            label.removeFromSuperview()
            
            toViewController.view.isHidden = false
            
            transitionContext.completeTransition(true)
        }
        
        animator1.startAnimation()
        animator3.startAnimation()
    }
}

class TransitionCoordinator: NSObject, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch operation {
        case .push:
            return PushAnimator()
        case .pop:
            return PopAnimator()
        default:
            return nil
        }
                
    }
    
}
