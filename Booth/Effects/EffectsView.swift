//
//  EffectsView.swift
//  Booth
//
//  Created by Jinwoo Kim on 9/24/23.
//

import UIKit
import CoreMedia
import CoreVideo

final class EffectsView: UIView {
    var sampleBuffer: CMSampleBuffer? {
        didSet {
            sampleBufferDidChange()
        }
    }
    private let pixelBufferSubject: AsyncEventSubject<CVPixelBuffer?> = .init()
    
    private var collectionView: UICollectionView!
    private var viewModel: EffectsViewModel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        configureCollectionView()
        configureViewModel()
        
        Task { [viewModel] in
            await viewModel?.loadDataSource()
        }
    }
    
    private func configureCollectionView() {
        let collectionViewLayout: UICollectionViewLayout = createCollectionViewLayout()
        let collectionView: UICollectionView = .init(frame: bounds, collectionViewLayout: collectionViewLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(collectionView)
        self.collectionView = collectionView
    }
    
    private func configureViewModel() {
        let dataSource: UICollectionViewDiffableDataSource<Int, EffectsItemModel> = createDataSource()
        let viewModel: EffectsViewModel = .init(dataSource: dataSource)
        self.viewModel = viewModel
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let configuration: UICollectionViewCompositionalLayoutConfiguration = .init()
        configuration.scrollDirection = .vertical
        
        let layout: UICollectionViewCompositionalLayout = .init(
            sectionProvider: { sectionIndex, environment in
                let quotient: Int = .init(floorf(Float(environment.container.contentSize.width) / 300.0))
                let count: Int = (quotient < 2) ? 2 : quotient
                let count_f: Float = .init(count)
                
                let itemSize: NSCollectionLayoutSize = .init(
                    widthDimension: .fractionalWidth(.init(1.0 / count_f)),
                    heightDimension: .fractionalHeight(1.0)
                )
                
                let item: NSCollectionLayoutItem = .init(layoutSize: itemSize)
                
                let groupSize: NSCollectionLayoutSize = .init(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(.init(1.0 / count_f))
                )
                
                let group: NSCollectionLayoutGroup = .horizontal(layoutSize: groupSize, repeatingSubitem: item, count: count)
                let section: NSCollectionLayoutSection = .init(group: group)
                
                return section
        },
            configuration: configuration
        )
        
        return layout
    }
    
    private func createDataSource() -> UICollectionViewDiffableDataSource<Int, EffectsItemModel> {
        let cellRegistratoin: UICollectionView.CellRegistration<UICollectionViewCell, EffectsItemModel> = createCellRegistration()
        
        return .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistratoin, for: indexPath, item: itemIdentifier)
        }
    }
    
    private func createCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, EffectsItemModel> {
        .init { [pixelBufferSubject] cell, indexPath, itemIdentifier in
            let contentConfiguration: EffectsContentView.Configuration = .init(pixelBufferSubject: pixelBufferSubject)
            cell.contentConfiguration = contentConfiguration
        }
    }
    
    private nonisolated func pixelBuffer(from sampleBuffer: CMSampleBuffer) async -> CVPixelBuffer? {
        CMSampleBufferGetImageBuffer(sampleBuffer)
    }
    
    private func sampleBufferDidChange() {
        Task.detached(priority: .userInitiated) { [sampleBuffer, pixelBufferSubject] in
            let pixelBuffer: CVPixelBuffer?
            if let sampleBuffer: CMSampleBuffer {
                pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            } else {
                pixelBuffer = nil
            }
            
            await pixelBufferSubject.yield(with: pixelBuffer)
        }
    }
}
