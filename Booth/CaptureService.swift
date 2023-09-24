//
//  CaptureService.swift
//  Booth
//
//  Created by Jinwoo Kim on 9/24/23.
//

import AVFoundation

actor CaptureService: NSObject {
    let sampleBufferSubject: AsyncEventSubject<CMSampleBuffer> = .init()
    
    private let captureSession: AVCaptureSession = .init()
    private let discoverySession: AVCaptureDevice.DiscoverySession = .init(deviceTypes: [.builtInWideAngleCamera, .continuityCamera, .external], mediaType: .video, position: .unspecified)
    private var discoverySessionObservation: NSKeyValueObservation?
    private let videoDataOutput: AVCaptureVideoDataOutput = .init()
    private let videoDataOutputQueue: DispatchQueue = .init(label: "com.pookjw.Booth.CaptureService.videoDataQueue", qos: .userInitiated)
    
    func load() async throws {
        let authorized: Bool = await requestVideoAuthorization()
        assert(authorized)
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        videoDataOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        assert(captureSession.canAddOutput(videoDataOutput))
        captureSession.addOutput(videoDataOutput)
        
        if let preferredCaptureDevice: AVCaptureDevice = .userPreferredCamera ?? .systemPreferredCamera ?? discoverySession.devices.first {
            try update(captureDevice: preferredCaptureDevice, isInitialSetup: true)
        }
        
        captureSession.commitConfiguration()
        
        discoverySessionObservation = discoverySession.observe(\.devices) { discoverySession, changes in
            print("TODO")
        }
    }
    
    func start() {
        guard !captureSession.isRunning else { return }
        captureSession.startRunning()
    }
    
    func pause() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
    }
    
    private func requestVideoAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }
    
    private func update(captureDevice: AVCaptureDevice, isInitialSetup: Bool) throws {
        if !isInitialSetup {
            captureSession.beginConfiguration()
        }
        defer {
            if !isInitialSetup {
                captureSession.commitConfiguration()
            }
        }
        
        //
        
        captureSession
            .inputs
            .forEach { input in
                if let deviceInput: AVCaptureDeviceInput = input as? AVCaptureDeviceInput {
                    NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: deviceInput.device)
                }
                
                captureSession.removeInput(input)
            }
        
        NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange(_:)), name: .AVCaptureDeviceSubjectAreaDidChange, object: captureDevice)
        let deviceInput: AVCaptureDeviceInput = try .init(device: captureDevice)
        captureSession.addInput(deviceInput)
    }
    
    @objc private nonisolated func subjectAreaDidChange(_ sender: AVCaptureInput) {
        print("TODO")
    }
}

extension CaptureService: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        Task {
            await sampleBufferSubject.yield(with: sampleBuffer)
        }
    }
}
