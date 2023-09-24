//
//  EffectsViewModel.swift
//  Booth
//
//  Created by Jinwoo Kim on 9/24/23.
//

import UIKit

actor EffectsViewModel {
    private let dataSource: UICollectionViewDiffableDataSource<Int, EffectsItemModel>
    
    init(dataSource: UICollectionViewDiffableDataSource<Int, EffectsItemModel>) {
        self.dataSource = dataSource
    }
    
    func loadDataSource() async {
        var snapshot: NSDiffableDataSourceSnapshot<Int, EffectsItemModel> = .init()
        
        snapshot.appendSections([.zero])
        snapshot.appendItems(EffectsItemModel.allCases, toSection: .zero)
        
        await dataSource.apply(snapshot, animatingDifferences: true)
    }
}
