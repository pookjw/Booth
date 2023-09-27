//
//  EffectsDetailViewController.swift
//  Booth
//
//  Created by Jinwoo Kim on 9/25/23.
//

import UIKit

@MainActor
final class EffectsDetailViewController: UIViewController {
    private weak var targetRenderView: PixelBufferRenderView?
    
    convenience init(targetRenderView: PixelBufferRenderView?) {
        self.init(nibName: nil, bundle: nil)
        self.targetRenderView = targetRenderView
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange.withAlphaComponent(0.5)
    }
    
    private func commonInit() {
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
}

extension EffectsDetailViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let targetRenderView: PixelBufferRenderView {
            EffectsDetailPresentationAnimationController(targetView: targetRenderView, targetFrame: presented.view.bounds)
        } else {
            EffectsDetailPresentationAnimationController()
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        EffectsDetailDismissalAnimationController()
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        EffectsDetailPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
