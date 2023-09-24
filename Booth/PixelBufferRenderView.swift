//
//  PixelBufferRenderView.swift
//  Booth
//
//  Created by Jinwoo Kim on 9/24/23.
//

import UIKit
import MetalKit
import AVFoundation

@MainActor
final class PixelBufferRenderView: UIView {
    var pixelBuffer: CVPixelBuffer? {
        didSet {
            render()
        }
    }
//    var captureOrientation: (AVCaptureVideoOrientation, AVCaptureDevice.Position) {
//        didSet {
//            render()
//        }
//    }
    private let renderer: Renderer
    private let mtkView: MTKView
    private var interfaceOrientationRegistration: NSObjectProtocol?
//    private var metalLayer: CAMetalLayer { layer as! CAMetalLayer }
//    
//    override class var layerClass: AnyClass {
//        CAMetalLayer.self
//    }
    
    init() {
        mtkView = .init(frame: .null)
        renderer = try! .init(mtkView: mtkView)
        super.init(frame: .null)
        addSubview(mtkView)
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mtkView.topAnchor.constraint(equalTo: topAnchor),
            mtkView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mtkView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mtkView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if let windowScene: UIWindowScene = window?.windowScene {
            interfaceOrientationRegistration = NotificationCenter.default.addObserver(forName: .UIWindowSceneInterfaceOrientationDidChange, object: windowScene, queue: nil) { [weak self] notification in
                Task { @MainActor [weak self] in
                    self?.render()
                }
            }
        } else {
            interfaceOrientationRegistration = nil
        }
    }
    
    private func render() {
        Task.detached(priority: .userInitiated) { [renderer, pixelBuffer, mtkView] in
            guard let pixelBuffer: CVPixelBuffer else { return }
            await renderer.draw(pixelBuffer: pixelBuffer)
        }
    }
}

extension PixelBufferRenderView {
    fileprivate actor Renderer: NSObject {
        private let mtkView: MTKView
        private let device: MTLDevice
        private let sampler: MTLSamplerState
        private let renderPipelineState: MTLRenderPipelineState
        private let commandQueue: MTLCommandQueue
        private let textureCache: CVMetalTextureCache
        
        @MainActor
        init(mtkView: MTKView) throws {
            self.mtkView = mtkView
            device = MTLCreateSystemDefaultDevice()!
            let library: MTLLibrary = try device.makeDefaultLibrary(bundle: .init(for: PixelBufferRenderView.self))
            
            let vertexFunction: MTLFunctionDescriptor = .init()
            vertexFunction.name = "pixel_buffer_shader::vertexFunction"
            
            let fragmentFunction: MTLFunctionDescriptor = .init()
            fragmentFunction.name = "pixel_buffer_shader::fragmentFunction"
            
            let pipelineDescriptor: MTLRenderPipelineDescriptor = .init()
            pipelineDescriptor.colorAttachments[.zero].pixelFormat = .bgra8Unorm
            pipelineDescriptor.vertexFunction = try library.makeFunction(descriptor: vertexFunction)
            pipelineDescriptor.fragmentFunction = try library.makeFunction(descriptor: fragmentFunction)
            renderPipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            
            let samplerDescriptor: MTLSamplerDescriptor = .init()
            samplerDescriptor.sAddressMode = .clampToEdge
            samplerDescriptor.tAddressMode = .clampToEdge
            samplerDescriptor.minFilter = .linear
            samplerDescriptor.magFilter = .linear
            sampler = device.makeSamplerState(descriptor: samplerDescriptor)!
            
            commandQueue = device.makeCommandQueue()!
            
            var _textureCache: CVMetalTextureCache?
            let result: CVReturn = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &_textureCache)
            assert(result == kCVReturnSuccess)
            textureCache = _textureCache!
            
            mtkView.device = device
            mtkView.clearColor = .init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            mtkView.colorPixelFormat = .bgra8Unorm
        }
        
        func draw(pixelBuffer: CVPixelBuffer) async {
//            let drawable: CAMetalDrawable = metalLayer.nextDrawable()!
            let data: (CAMetalDrawable?, MTLRenderPassDescriptor?) = await MainActor.run { [mtkView] in
                (mtkView.currentDrawable, mtkView.currentRenderPassDescriptor)
            }
            guard
                let drawable: CAMetalDrawable = data.0,
                let renderPassDescriptor: MTLRenderPassDescriptor = data.1
            else {
                return
            }
            
            // MARK: - Get Textures
            
            let width: Int = CVPixelBufferGetWidth(pixelBuffer)
            let height: Int = CVPixelBufferGetHeight(pixelBuffer)
            
            var _metalTexture: CVMetalTexture?
            CVMetalTextureCacheCreateTextureFromImage(
                kCFAllocatorDefault,
                textureCache,
                pixelBuffer,
                nil,
                .bgra8Unorm,
                width,
                height,
                .zero,
                &_metalTexture
            )
            
            guard
                let metalTexture: CVMetalTexture = _metalTexture,
                let texture: MTLTexture = CVMetalTextureGetTexture(metalTexture)
            else {
                CVMetalTextureCacheFlush(textureCache, .zero)
                return
            }
            
            // MARK: - Get Buffers
            
            let drawableSize: CGSize = drawable.layer.drawableSize
            let ratioX: Float = Float(drawableSize.width) / Float(width)
            let ratioY: Float = Float(drawableSize.height) / Float(height)
            let scaleX: Float
            let scaleY: Float
            if width < height {
                scaleX = 1.0
                scaleY = ratioX / ratioY
            } else {
                scaleX = ratioY / ratioX
                scaleY = 1.0
            }
            let vertexData: [Float] = [
                -scaleX, -scaleY, 0.0, 1.0,
                scaleX, -scaleY, 0.0, 1.0,
                -scaleX, scaleY, 0.0, 1.0,
                scaleX, scaleY, 0.0, 1.0
            ]
            let vertexCoordBuffer: MTLBuffer = device.makeBuffer(bytes: vertexData, length: vertexData.count * MemoryLayout<Float>.size, options: .init())!
            
            let textureData: [Float] = [
                .zero, 1.0,
                1.0, 1.0,
                .zero, .zero,
                1.0, .zero
            ]
            let textureCorrdBuffer: MTLBuffer = device.makeBuffer(bytes: textureData, length: textureData.count * MemoryLayout<Float>.size, options: .init())!
            
            //
            
            let commandBufferDescriptor: MTLCommandBufferDescriptor = .init()
            let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer(descriptor: commandBufferDescriptor)!
            
            //
            
//            let renderPassDescriptor: MTLRenderPassDescriptor = .init()
//            renderPassDescriptor.colorAttachments[.zero].texture = drawable.texture
//            renderPassDescriptor.colorAttachments[.zero].loadAction = .clear
//            renderPassDescriptor.colorAttachments[.zero].storeAction = .store
//            renderPassDescriptor.colorAttachments[.zero].clearColor = .init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            let commandEncoder: MTLRenderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
            commandEncoder.label = String(describing: self)
            commandEncoder.setRenderPipelineState(renderPipelineState)
            commandEncoder.setVertexBuffer(vertexCoordBuffer, offset: .zero, index: .zero)
            commandEncoder.setVertexBuffer(textureCorrdBuffer, offset: .zero, index: 1)
            commandEncoder.setFragmentTexture(texture, index: .zero)
            commandEncoder.setFragmentSamplerState(sampler, index: .zero)
            commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: .zero, vertexCount: 4)
            commandEncoder.endEncoding()
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}
