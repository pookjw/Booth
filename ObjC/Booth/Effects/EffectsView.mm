//
//  EffectsView.mm
//  Booth
//
//  Created by Jinwoo Kim on 10/20/23.
//

#import "EffectsView.hpp"
#import "EffectsViewModel.hpp"
#import "EffectsContentView.hpp"
#import <memory>
#import <cmath>
#import <functional>

__attribute__((objc_direct_members))
@interface EffectsView () <UICollectionViewDelegate>
@property (assign, readonly) EffectsViewLayout layout;
@property (retain, nonatomic) UICollectionView *collectionView;
@property (assign, nonatomic) std::shared_ptr<EffectsViewModel> viewModel;
@property (retain, nonatomic) NSNotificationCenter *notificationCenter;
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
    if (self = [super initWithFrame:frame]) {
        _layout = layout;
        [self EffectsView_commonInit];
    }
    
    return self;
}

- (void)dealloc {
    [_collectionView release];
    [_notificationCenter release];
    [super dealloc];
}

- (void)EffectsView_commonInit __attribute__((objc_direct)) {
    [self setupAttributes];
    [self setupNotificationCenter];
    [self setupCollectionView];
    [self setupViewModel];
    
    self.viewModel.get()->load(^{
        NSLog(@"Done!");
    });
}

- (void)updatePixelBuffer:(CVPixelBufferRef)pixelBuffer __attribute__((objc_direct)) {
    [self.notificationCenter postNotificationName:ns_EffectsContentConfiguration::didChangePixelBufferNotificationName
                                           object:nil
                                         userInfo:@{ns_EffectsContentConfiguration::pixelBufferKey: static_cast<id>(pixelBuffer)}];
}

- (void)setupAttributes __attribute__((objc_direct)) {
    self.backgroundColor = UIColor.clearColor;
}

- (void)setupNotificationCenter {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter new];
    self.notificationCenter = notificationCenter;
    [notificationCenter release];
}

- (void)setupCollectionView __attribute__((objc_direct)) {
    UICollectionViewLayout *collectionViewLayout = [self makeCollectionViewLayout];
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
    UICollectionViewDiffableDataSource<NSNumber *, EffectsItemModel *> *dataSource = [self makeDataSource];
    self.viewModel = std::make_shared<EffectsViewModel>(dataSource);
}

- (UICollectionViewLayout *)makeCollectionViewLayout __attribute__((objc_direct)) {
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
            case EffectsViewLayoutGrid: {
                auto quotient = static_cast<std::uint16_t>(std::fmaf(layoutEnvironment.container.contentSize.width, std::powf(300.f, -1.f), 0.f)); // layoutEnvironment.container.contentSize.width / 300.f
                std::uint16_t count = std::less<std::uint16_t>()(quotient, 2) ? 2 : quotient;
                auto count_f = static_cast<std::float_t>(count);
                
                NSCollectionLayoutSize *itemSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:std::powf(count_f, -1.f)]
                                                                                  heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1.f]];
                
                NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize];
                
                NSCollectionLayoutSize *groupSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.f]
                                                                                   heightDimension:[NSCollectionLayoutDimension fractionalWidthDimension:std::powf(count_f, -1.f)]];
                
                NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:groupSize repeatingSubitem:item count:count];
                NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:group];
                
                return section;
            }
            case EffectsViewLayoutFull:
                return nil;
            default:
                [NSException raise:NSInternalInconsistencyException format:@"Not supported layout type: %ld", layout];
                return nil;
        }
    }
                                                                                                                       configuration:configuration];
    
    [configuration release];
    
    return [collectionViewLayout autorelease];
}

- (UICollectionViewDiffableDataSource<NSNumber *, EffectsItemModel *> *)makeDataSource __attribute__((objc_direct)) {
    UICollectionViewCellRegistration *cellRegistration = [self makeCellRegistration];
    
    UICollectionViewDiffableDataSource<NSNumber *, EffectsItemModel *> *dataSource = [[UICollectionViewDiffableDataSource<NSNumber *, EffectsItemModel *> alloc] initWithCollectionView:self.collectionView cellProvider:^UICollectionViewCell * _Nullable(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, id  _Nonnull itemIdentifier) {
        return [collectionView dequeueConfiguredReusableCellWithRegistration:cellRegistration forIndexPath:indexPath item:itemIdentifier];
    }];
    
    return [dataSource autorelease];
}

- (UICollectionViewCellRegistration *)makeCellRegistration __attribute__((objc_direct)) {
    NSNotificationCenter *notificationCenter = self.notificationCenter;
    
    UICollectionViewCellRegistration *cellRegistration = [UICollectionViewCellRegistration registrationWithCellClass:UICollectionViewCell.class configurationHandler:^(__kindof UICollectionViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, id  _Nonnull item) {
        EffectsContentConfiguration *contentConfiguration = [[EffectsContentConfiguration alloc] initWithItemModel:item notificationCenter:notificationCenter];
        cell.contentConfiguration = contentConfiguration;
        [contentConfiguration release];
    }];
    
    return cellRegistration;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", indexPath);
}

@end
