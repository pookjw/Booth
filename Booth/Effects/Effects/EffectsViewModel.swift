//
//  EffectsViewModel.swift
//  Booth
//
//  Created by Jinwoo Kim on 9/24/23.
//

import UIKit

actor EffectsViewModel {
    private let dataSource: UICollectionViewDiffableDataSource<Int, Effect>
    
    init(dataSource: UICollectionViewDiffableDataSource<Int, Effect>) {
        self.dataSource = dataSource
    }
    
    func loadDataSource() async {
        var snapshot: NSDiffableDataSourceSnapshot<Int, Effect> = .init()
        
        snapshot.appendSections([.zero])
        snapshot.appendItems(Effect.allCases, toSection: .zero)
        
        await dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func effect(at indexPath: IndexPath) async -> Effect? {
        await dataSource.itemIdentifier(for: indexPath)
    }
}
