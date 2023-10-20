//
//  AsyncEventSubject.swift
//  Booth
//
//  Created by Jinwoo Kim on 9/24/23.
//

import Foundation

actor AsyncEventSubject<Element: Sendable> {
    var stream: AsyncStream<Element> {
        let (stream, continuation): (AsyncStream<Element>, AsyncStream<Element>.Continuation) = AsyncStream<Element>.makeStream()
        let key = UUID()
        
        continuation.onTermination = { [weak self] _ in
            Task { [weak self] in
                await self?.remove(key: key)
            }
        }
        
        continuations[key] = continuation
        
        return stream
    }
    
    private var continuations: [UUID: AsyncStream<Element>.Continuation] = .init()
    
    deinit {
        continuations.values.forEach { continuation in
            continuation.finish()
        }
    }
    
    func yield(with value: Element) {
        continuations.values.forEach { continuation in
            continuation.yield(value)
        }
    }
    
    private func remove(key: UUID) {
        continuations.removeValue(forKey: key)
    }
}
