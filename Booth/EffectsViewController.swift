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
    @ViewLoading private var renderView: PixelBufferRenderView
    private let captureService: CaptureService = .init()
    private var sampleBufferTask: Task<Void, Never>?
    
    deinit {
        sampleBufferTask?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderView = .init()
        renderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(renderView)
        NSLayoutConstraint.activate([
            renderView.topAnchor.constraint(equalTo: view.topAnchor),
            renderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            renderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            renderView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        Task {
            try! await captureService.load()
            sampleBufferTask = .init { [renderView, captureService] in
                for await sampleBuffer in await captureService.sampleBufferSubject.stream {
                    renderView.pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
                }
            }
        }
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
}
