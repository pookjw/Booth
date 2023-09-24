//
//  EffectsContentView.swift
//  Booth
//
//  Created by Jinwoo Kim on 9/24/23.
//

import UIKit
import CoreVideo

@MainActor
final class EffectsContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        @storageRestrictions(initializes: _configuration)
        init(initialValue) {
            if let casted: Configuration = initialValue as? Configuration {
                _configuration = casted
            } else {
                _configuration = nil
            }
        }
        get {
            _configuration
        }
        set {
            if let casted: Configuration = newValue as? Configuration {
                _configuration = casted
            } else {
                _configuration = nil
            }
        }
    }
    
    private var _configuration: Configuration! {
        didSet {
            configurationDidChange()
        }
    }
    
    private var renderView: PixelBufferRenderView!
    
    init(configuration: Configuration) {
        self.configuration = configuration
        super.init(frame: .null)
        configureRenderView()
        configurationDidChange()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func supports(_ configuration: UIContentConfiguration) -> Bool {
        configuration is Configuration
    }
    
    private func configureRenderView() {
        let renderView: PixelBufferRenderView = .init(frame: bounds)
        renderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(renderView)
        NSLayoutConstraint.activate([
            renderView.topAnchor.constraint(equalTo: topAnchor),
            renderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            renderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            renderView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        self.renderView = renderView
    }
    
    private func configurationDidChange() {
        renderView.pixelBuffer = _configuration?.pixelBuffer
    }
}

extension EffectsContentView {
    struct Configuration: UIContentConfiguration {
        let pixelBuffer: CVPixelBuffer?
        
        func makeContentView() -> UIView & UIContentView {
            EffectsContentView(configuration: self)
        }
        
        func updated(for state: UIConfigurationState) -> EffectsContentView.Configuration {
            self
        }
    }
}
