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
	var opts: UIViewAnimationOptions = UIViewAnimationOptions.CurveEaseInOut
	
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.35
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let topView = dismissing ? fromViewController.view : toViewController.view
        let bottomViewController = dismissing ? toViewController : fromViewController
        var bottomView = bottomViewController.view
        let offset = bottomView.bounds.size.width
        if let navVC = bottomViewController as? UINavigationController {
            bottomView = navVC.topViewController?.view
        }
        
        transitionContext.containerView().insertSubview(toViewController.view, aboveSubview: fromViewController.view)
        if dismissing { transitionContext.containerView().insertSubview(toViewController.view, belowSubview: fromViewController.view) }
        
        topView.frame = fromViewController.view.frame
        topView.transform = dismissing ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(offset, 0)
        
        let shadowView = UIImageView(image: UIImage(named: "shadow"))
        shadowView.contentMode = UIViewContentMode.ScaleAspectFill
        shadowView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        shadowView.frame = bottomView.bounds
        bottomView.addSubview(shadowView)
        shadowView.transform = dismissing ? CGAffineTransformMakeScale(0.01, 1) : CGAffineTransformIdentity
        shadowView.alpha = self.dismissing ? 1.0 : 0.0
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: animOpts(), animations: { () -> Void in
                topView.transform = self.dismissing ? CGAffineTransformMakeTranslation(offset, 0) : CGAffineTransformIdentity
                shadowView.transform = self.dismissing ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0.01, 1)
                shadowView.alpha = self.dismissing ? 0.0 : 1.0
            }) { ( finished ) -> Void in
                topView.transform = CGAffineTransformIdentity
                shadowView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
	func animOpts() -> UIViewAnimationOptions {
		let opts = self.percentageDriven ? UIViewAnimationOptions.CurveLinear : UIViewAnimationOptions.CurveEaseInOut
	
		return opts.union(UIViewAnimationOptions.AllowAnimatedContent).union(UIViewAnimationOptions.BeginFromCurrentState).union(UIViewAnimationOptions.LayoutSubviews)
    }
}
