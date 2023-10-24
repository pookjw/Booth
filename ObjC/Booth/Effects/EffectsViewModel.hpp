//
//  EffectsViewModel.hpp
//  Booth
//
//  Created by Jinwoo Kim on 10/24/23.
//

#import <UIKit/UIKit.h>
#import <functional>
#import "EffectsItemModel.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class EffectsViewModel {
public:
    EffectsViewModel(UICollectionViewDiffableDataSource<NSNumber *, EffectsItemModel *> *dataSource);
    ~EffectsViewModel();
    
    void load(std::function<void ()>completionHandler);
private:
    UICollectionViewDiffableDataSource<NSNumber *, EffectsItemModel *> *_dataSource;
    NSOperationQueue *_queue;
};

NS_HEADER_AUDIT_END(nullability, sendability)
