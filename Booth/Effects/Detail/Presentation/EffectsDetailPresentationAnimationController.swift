//
//  EffectsDetailPresentationAnimationController.swift
//  Booth
//
//  Created by Jinwoo Kim on 9/27/23.
//

import UIKit

@MainActor
final class EffectsDetailPresentationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private let zoomStartView: UIView
    private let zoomEndView: UIView
    
    init(zoomStartView: UIView, zoomEndView: UIView) {
        self.zoomStartView = zoomStartView
        self.zoomEndView = zoomEndView
        super.init()
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
        
        let zoomStartFrame: CGRect = zoomStartView.frame(in: fromView)!
        let containerView: UIView = transitionContext.containerView
        
        if transitionContext.isAnimated {
            toView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(toView)
            NSLayoutConstraint.activate([
                toView.topAnchor.constraint(equalTo: containerView.topAnchor),
                toView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                toView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                toView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            
            //
            
            zoomEndView.removeFromSuperview()
            containerView.addSubview(zoomEndView)
            zoomEndView.translatesAutoresizingMaskIntoConstraints = true
            zoomEndView.autoresizingMask = .init(rawValue: .zero)
            zoomEndView.frame = zoomStartFrame
            zoomStartView.isHidden = true
            
            //
            
            containerView.layoutIfNeeded()
            toView.alpha = .zero
            
            //
            
            UIView.animate(withDuration: 0.3) { [zoomEndView] in
                toView.alpha = 1.0
                zoomEndView.frame = toView.bounds // TODO: Constraints
            }
        } else {
            fatalError("TODO")
        }
    }
    
//    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
//        
//    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        
    }
}
