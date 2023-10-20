//
//  EffectsDetailViewController.swift
//  Booth
//
//  Created by Jinwoo Kim on 9/25/23.
//

import UIKit
import CoreMedia

@MainActor
final class EffectsDetailViewController: UIViewController {
    var sampleBuffer: CMSampleBuffer? {
        get {
            effectsView.sampleBuffer
        }
        set {
            effectsView.sampleBuffer = newValue
        }
    }
    
    private let effectsView: EffectsView = .init(frame: .null, layout: .full)
    
    private weak var zoomStartView: UIView?
    private let initialEffect: Effect?
    
    init(zoomStartView: UIView, initialEffect: Effect) {
        self.zoomStartView = zoomStartView
        self.initialEffect = initialEffect
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        zoomStartView = nil
        initialEffect = nil
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAttributes()
        layoutEffectsView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let transitionCoordinator: UIViewControllerTransitionCoordinator {
            transitionCoordinator.animate { context in
                
            } completion: { [weak self] context in
                self?.layoutEffectsView()
            }
        }
    }
    
    private func commonInit() {
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    private func setupAttributes() {
        view.backgroundColor = .clear
    }
    
    private func layoutEffectsView() {
        effectsView.removeFromSuperview()
        effectsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(effectsView)
        NSLayoutConstraint.activate([
            effectsView.topAnchor.constraint(equalTo: view.topAnchor),
            effectsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            effectsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            effectsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension EffectsDetailViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if
            let zoomStartView: UIView
        {
            EffectsDetailPresentationAnimationController(zoomStartView: zoomStartView, zoomEndView: effectsView)
        } else {
            fatalError("TODO")
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
        EffectsDetailPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
}
