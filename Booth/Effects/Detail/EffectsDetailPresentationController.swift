//
//  EffectsDetailPresentationController.swift
//  Booth
//
//  Created by Jinwoo Kim on 9/25/23.
//

import UIKit

@MainActor
final class EffectsDetailPresentationController: UIPresentationController {
    private var backgroundView: UIView?
    
    override var shouldPresentInFullscreen: Bool {
        true
    }
    
    override var shouldRemovePresentersView: Bool {
        true
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        addBackgroundView()
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        removeBackgroundView()
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
    }
    
    private func addBackgroundView() {
        guard let containerView: UIView else {
            return
        }
        
        let backgroundView: UIView = .init(frame: containerView.bounds)
        backgroundView.backgroundColor = .black
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        if let transitionCoordinator: UIViewControllerTransitionCoordinator = presentedViewController.transitionCoordinator {
            backgroundView.alpha = .zero
            transitionCoordinator.animate { context in
                backgroundView.alpha = 1.0
            } completion: { context in
                if context.isCancelled {
//                    backgroundView.removeFromSuperview()
                    fatalError("Unsupported yet")
                }
            }
        }
        
        self.backgroundView = backgroundView
    }
    
    private func removeBackgroundView() {
        guard let backgroundView: UIView else {
            return
        }
        
        if let transitionCoordinator: UIViewControllerTransitionCoordinator = presentedViewController.transitionCoordinator {
            transitionCoordinator.animate { context in
                backgroundView.alpha = .zero
            } completion: { context in
                if context.isCancelled {
                    backgroundView.alpha = 1.0
                } else {
                    backgroundView.removeFromSuperview()
                }
            }

        } else {
            backgroundView.removeFromSuperview()
        }
    }
}
