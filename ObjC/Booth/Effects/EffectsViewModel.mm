//
//  EffectsViewModel.mm
//  Booth
//
//  Created by Jinwoo Kim on 10/24/23.
//

#import "EffectsViewModel.hpp"
#import <algorithm>

EffectsViewModel::EffectsViewModel(UICollectionViewDiffableDataSource<NSNumber *, EffectsItemModel *> *dataSource) : _dataSource([dataSource retain]) {
    _queue = [NSOperationQueue new];
    _queue.maxConcurrentOperationCount = 1;
    _queue.qualityOfService = NSQualityOfServiceUtility;
}

EffectsViewModel::~EffectsViewModel() {
    [_queue cancelAllOperations];
    [_queue release];
    [_dataSource release];
}

void EffectsViewModel::load(std::function<void ()> completionHandler) {
    UICollectionViewDiffableDataSource<NSNumber *, EffectsItemModel *> *dataSource = _dataSource;
    
    [_queue addOperationWithBlock:^{
        NSDiffableDataSourceSnapshot<NSNumber *, EffectsItemModel *> *snapshot = [NSDiffableDataSourceSnapshot<NSNumber *, EffectsItemModel *> new];
        
        NSMutableArray<EffectsItemModel *> *itemModels = [NSMutableArray<EffectsItemModel *> new];
        auto itemTypes = allEffectsItemModelTypes();
        
        std::for_each(itemTypes.cbegin(), itemTypes.cend(), [itemModels](EffectsItemModelType type) {
            EffectsItemModel *itemModel = [[EffectsItemModel alloc] initWithType:type];
            [itemModels addObject:itemModel];
            [itemModel release];
        });
        
        [snapshot appendSectionsWithIdentifiers:@[@0]];
        [snapshot appendItemsWithIdentifiers:itemModels intoSectionWithIdentifier:@0];
        [itemModels release];
        
        [dataSource applySnapshot:snapshot animatingDifferences:YES completion:^{
            completionHandler();
        }];
        
        [snapshot release];
    }];
}
