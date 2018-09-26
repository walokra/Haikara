//
//  SCModalPushPopAnimator.swift
//  highkara
//
//  Created by stringCode on 3/1/15.
//  Copyright (c) 2015 stringCode. All rights reserved.
//  The MIT License (MIT)
//

import UIKit

class SCModalPushPopAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
	
	var dismissing: Bool = false
	var percentageDriven: Bool = false
	var opts: UIView.AnimationOptions = UIView.AnimationOptions()
	
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let topView = dismissing ? fromViewController.view! : toViewController.view!
        let bottomViewController = dismissing ? toViewController : fromViewController
        var bottomView = bottomViewController.view!
        let offset = bottomView.bounds.size.width
        if let navVC = bottomViewController as? UINavigationController {
            bottomView = (navVC.topViewController?.view)!
        }
		
        transitionContext.containerView.insertSubview(toViewController.view, aboveSubview: fromViewController.view)
        if dismissing { transitionContext.containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view) }
        
        topView.frame = fromViewController.view.frame
        topView.transform = dismissing ? CGAffineTransform.identity : CGAffineTransform(translationX: offset, y: 0)
        
        let shadowView = UIImageView(image: UIImage(named: "shadow"))
        shadowView.contentMode = UIView.ContentMode.scaleAspectFill
        shadowView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        shadowView.frame = bottomView.bounds
        bottomView.addSubview(shadowView)
        shadowView.transform = dismissing ? CGAffineTransform(scaleX: 0.01, y: 1) : CGAffineTransform.identity
        shadowView.alpha = self.dismissing ? 1.0 : 0.0
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: animOpts(), animations: { () -> Void in
                topView.transform = self.dismissing ? CGAffineTransform(translationX: offset, y: 0) : CGAffineTransform.identity
                shadowView.transform = self.dismissing ? CGAffineTransform.identity : CGAffineTransform(scaleX: 0.01, y: 1)
                shadowView.alpha = self.dismissing ? 0.0 : 1.0
            }) { ( finished ) -> Void in
                topView.transform = CGAffineTransform.identity
                shadowView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
	func animOpts() -> UIView.AnimationOptions {
		let opts = self.percentageDriven ? UIView.AnimationOptions.curveLinear : UIView.AnimationOptions()
	
		return opts.union(UIView.AnimationOptions.allowAnimatedContent).union(UIView.AnimationOptions.beginFromCurrentState).union(UIView.AnimationOptions.layoutSubviews)
    }
}
