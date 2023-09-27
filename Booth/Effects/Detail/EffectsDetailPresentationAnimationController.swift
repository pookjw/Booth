//
//  EffectsDetailPresentationAnimationController.swift
//  Booth
//
//  Created by Jinwoo Kim on 9/27/23.
//

import UIKit

@MainActor
final class EffectsDetailPresentationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private weak var targetView: UIView?
    
    convenience init(targetView: UIView, targetFrame: CGRect) {
        self.init()
        self.targetView = targetView
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView: UIView = transitionContext.view(forKey: .from),
            let toView: UIView = transitionContext.view(forKey: .to)
        else {
            return
        }
        
        let containerView: UIView = transitionContext.containerView
        
        if transitionContext.isAnimated {
            if 
                let targetView: UIView,
                let targetFrame: CGRect = targetView.frame(in: fromView)
            {
                
            } else {
                
            }
            toView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(toView)
            NSLayoutConstraint.activate([
                toView.topAnchor.constraint(equalTo: containerView.topAnchor),
                toView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                toView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                toView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            
            toView.alpha = .zero
            UIView.animate(withDuration: 0.3) { 
                toView.alpha = 1.0
            }
        } else {
            // TODO
        }
    }
    
//    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
//        
//    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        
    }
}
