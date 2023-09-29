//
//  EffectsDetailDismissalAnimationController.swift
//  Booth
//
//  Created by Jinwoo Kim on 9/27/23.
//

import UIKit

@MainActor
final class EffectsDetailDismissalAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
    }
    
//    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
//        
//    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        
    }
}
