//
//  EffectsView.mm
//  Booth
//
//  Created by Jinwoo Kim on 10/20/23.
//

#import "EffectsView.hpp"
#import "EffectsViewModel.hpp"
#import <memory>

__attribute__((objc_direct_members))
@interface EffectsView () <UICollectionViewDelegate>
@property (assign, readonly) EffectsViewLayout layout;
@property (retain, nonatomic) UICollectionView *collectionView;
@property (assign, nonatomic) std::shared_ptr<EffectsViewModel> viewModel;
@end

@implementation EffectsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _layout = EffectsViewLayoutFull;
        [self EffectsView_commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        _layout = EffectsViewLayoutFull;
        [self EffectsView_commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame layout:(EffectsViewLayout)layout __attribute__((objc_direct)) {
    if (self = [self initWithFrame:frame]) {
        _layout = layout;
        [self EffectsView_commonInit];
    }
    
    return self;
}

- (void)dealloc {
    [_collectionView release];
    [super dealloc];
}

- (void)EffectsView_commonInit __attribute__((objc_direct)) {
    [self setupAttributes];
    [self setupCollectionView];
    [self setupViewModel];
}

- (void)updatePixelBuffer:(CVPixelBufferRef)pixelBuffer __attribute__((objc_direct)) {
    NSLog(@"TODO");
}

- (void)setupAttributes __attribute__((objc_direct)) {
    self.backgroundColor = UIColor.clearColor;
}

- (void)setupCollectionView __attribute__((objc_direct)) {
    UICollectionViewLayout *collectionViewLayout = [self createCollectionViewLayout];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:collectionViewLayout];
    collectionView.delegate = self;
    
    switch (self.layout) {
        case EffectsViewLayoutGrid:
            collectionView.bounces = YES;
            collectionView.showsVerticalScrollIndicator = YES;
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
            break;
        case EffectsViewLayoutFull:
            collectionView.bounces = NO;
            collectionView.showsVerticalScrollIndicator = NO;
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Not supported layout type: %ld", self.layout];
            [collectionView release];
            return;
    }
    
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    [collectionView release];
}

- (void)setupViewModel __attribute__((objc_direct)) {
    UICollectionViewDiffableDataSource<NSNumber *, EffectsItemModel *> *dataSource = [self createDataSource];
    _viewModel = std::make_shared<EffectsViewModel>(dataSource);
}

- (UICollectionViewLayout *)createCollectionViewLayout __attribute__((objc_direct)) {
    UICollectionViewCompositionalLayoutConfiguration *configuration = [UICollectionViewCompositionalLayoutConfiguration new];
    EffectsViewLayout layout = self.layout;
    
    switch (layout) {
        case EffectsViewLayoutGrid:
            configuration.contentInsetsReference = UIContentInsetsReferenceSafeArea;
            configuration.scrollDirection = UICollectionViewScrollDirectionVertical;
            break;
        case EffectsViewLayoutFull:
            configuration.contentInsetsReference = UIContentInsetsReferenceNone;
            configuration.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Not supported layout type: %ld", layout];
            [configuration release];
            return nil;
    }
    
    UICollectionViewCompositionalLayout *collectionViewLayout = [[UICollectionViewCompositionalLayout alloc] initWithSectionProvider:^NSCollectionLayoutSection * _Nullable(NSInteger sectionIndex, id<NSCollectionLayoutEnvironment>  _Nonnull layoutEnvironment) {
        switch (layout) {
            case EffectsViewLayoutGrid:
                return nil;
            case EffectsViewLayoutFull:
                return nil;
            default:
                [NSException raise:NSInternalInconsistencyException format:@"Not supported layout type: %ld", layout];
                [configuration release];
                return nil;
        }
    }
                                                                                                                       configuration:configuration];
    
    [configuration release];
    
    return [collectionViewLayout autorelease];
}

- (UICollectionViewDiffableDataSource<NSNumber *, EffectsItemModel *> *)createDataSource {
    return nil;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", indexPath);
}

@end
