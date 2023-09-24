//
//  EffectsViewController.swift
//  Booth
//
//  Created by Jinwoo Kim on 9/24/23.
//

import UIKit
import CoreMedia

@MainActor
final class EffectsViewController: UIViewController {
    @ViewLoading private var effectsView: EffectsView
    private let captureService: CaptureService = .init()
    private var sampleBufferTask: Task<Void, Never>?
    
    deinit {
        sampleBufferTask?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureEffectsView()
        loadCaptureService()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            await captureService.start()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        Task {
            await captureService.pause()
        }
    }
    
    private func configureEffectsView() {
        effectsView = .init(frame: view.bounds)
        effectsView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(effectsView)
    }
    
    private func loadCaptureService() {
        Task {
            try! await captureService.load()
            sampleBufferTask = .init { [effectsView, captureService] in
                for await sampleBuffer in await captureService.sampleBufferSubject.stream {
                    effectsView.sampleBuffer = sampleBuffer
                }
            }
        }
    }
}