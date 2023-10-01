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
    enum Layout {
        case grid
        case full
    }
    
    let didSelectEffectSubject: AsyncEventSubject<Effect> = .init()
    
    var sampleBuffer: CMSampleBuffer? {
        didSet {
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
    
    private let layout: Layout
    // for cells
    private let pixelBufferSubject: AsyncEventSubject<CVPixelBuffer?> = .init()
    
    private var collectionView: UICollectionView!
    private var viewModel: EffectsViewModel!
    
    init(frame: CGRect, layout: Layout) {
        self.layout = layout
        super.init(frame: frame)
        commonInit()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func renderView(from effect: Effect) -> PixelBufferRenderView? {
        for cell in collectionView.visibleCells {
            guard
                let contentConfiguration: EffectsContentView.Configuration = cell.contentConfiguration as? EffectsContentView.Configuration,
                let contentView: EffectsContentView = cell.contentView as? EffectsContentView,
                contentConfiguration.effect == effect
            else {
                continue
            }
            
            return contentView.renderView
        }
        
        return nil
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
        collectionView.delegate = self
        
        switch layout {
        case .grid:
            collectionView.bounces = true
            collectionView.showsVerticalScrollIndicator = true
            collectionView.contentInsetAdjustmentBehavior = .always
        case .full:
            collectionView.bounces = false
            collectionView.showsVerticalScrollIndicator = false
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(collectionView)
        self.collectionView = collectionView
    }
    
    private func configureViewModel() {
        let dataSource: UICollectionViewDiffableDataSource<Int, Effect> = createDataSource()
        let viewModel: EffectsViewModel = .init(dataSource: dataSource)
        self.viewModel = viewModel
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let configuration: UICollectionViewCompositionalLayoutConfiguration = .init()
        
        switch layout {
        case .grid:
            configuration.contentInsetsReference = .safeArea
            configuration.scrollDirection = .vertical
        case .full:
            configuration.contentInsetsReference = .none
            configuration.scrollDirection = .vertical
        }
        
        let collectionViewLayout: UICollectionViewCompositionalLayout = .init(
            sectionProvider: { [layout] sectionIndex, environment in
                switch layout {
                case .grid:
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
                case .full:
                    let itemSize: NSCollectionLayoutSize = .init(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0)
                    )
                    
                    let item: NSCollectionLayoutItem = .init(layoutSize: itemSize)
                    
                    let groupSize: NSCollectionLayoutSize = .init(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0)
                    )
                    
                    let group: NSCollectionLayoutGroup = .horizontal(layoutSize: groupSize, subitems: [item])
                    
                    let section: NSCollectionLayoutSection = .init(group: group)
                    section.orthogonalScrollingBehavior = .groupPaging
                    section.orthogonalScrollingProperties.bounce = .always
                    section.orthogonalScrollingProperties.decelerationRate = .fast
                    section.contentInsetsReference = .none
                    
                    return section
                }
        },
            configuration: configuration
        )
        
        return collectionViewLayout
    }
    
    private func createDataSource() -> UICollectionViewDiffableDataSource<Int, Effect> {
        let cellRegistratoin: UICollectionView.CellRegistration<UICollectionViewCell, Effect> = createCellRegistration()
        
        return .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistratoin, for: indexPath, item: itemIdentifier)
        }
    }
    
    private func createCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, Effect> {
        .init { [pixelBufferSubject] cell, indexPath, itemIdentifier in
            let contentConfiguration: EffectsContentView.Configuration = .init(effect: itemIdentifier, pixelBufferSubject: pixelBufferSubject)
            cell.contentConfiguration = contentConfiguration
        }
    }
    
    private nonisolated func pixelBuffer(from sampleBuffer: CMSampleBuffer) async -> CVPixelBuffer? {
        CMSampleBufferGetImageBuffer(sampleBuffer)
    }
}

extension EffectsView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Task { [viewModel, didSelectEffectSubject] in
            guard let effect: Effect = await viewModel?.effect(at: indexPath) else {
                return
            }
            
            await didSelectEffectSubject.yield(with: effect)
        }
    }
}
