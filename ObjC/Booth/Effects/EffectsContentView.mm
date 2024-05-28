//
//  EffectsContentView.mm
//  Booth
//
//  Created by Jinwoo Kim on 10/25/23.
//

#import "EffectsContentView.hpp"
#import "PixelBufferRenderView.hpp"

__attribute__((objc_direct_members))
@interface EffectsContentConfiguration ()
@property (retain, readonly, nonatomic) EffectsItemModel *itemModel;
@property (retain, readonly, nonatomic) NSNotificationCenter *notificationCenter;
@end

@implementation EffectsContentConfiguration

- (instancetype)initWithItemModel:(EffectsItemModel *)itemModel notificationCenter:(NSNotificationCenter *)notificationCenter __attribute__((objc_direct)) {
    if (self = [super init]) {
        _itemModel = [itemModel retain];
        _notificationCenter = [notificationCenter retain];
    }
    
    return self;
}

- (void)dealloc {
    [_itemModel release];
    [_notificationCenter release];
    [super dealloc];
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone { 
    EffectsContentConfiguration *copy = [self.class new];
    
    if (copy) {
        copy->_itemModel = [_itemModel copyWithZone:zone];
    }
    
    return copy;
}

- (nonnull __kindof UIView<UIContentView> *)makeContentView { 
    EffectsContentView *contentView = [[EffectsContentView alloc] initWithContentConfiguration:self];
    return [contentView autorelease];
}

- (nonnull instancetype)updatedConfigurationForState:(nonnull id<UIConfigurationState>)state { 
    return self;
}

@end


__attribute__((objc_direct_members))
@interface EffectsContentView () {
    EffectsContentConfiguration *_contentConfiguration;
}
@property (retain, nonatomic) PixelBufferRenderView *pixelBufferRenderView;
@end

@implementation EffectsContentView

- (instancetype)initWithContentConfiguration:(EffectsContentConfiguration *)contentConfiguration __attribute__((objc_direct)) {
    if (self = [super initWithFrame:CGRectNull]) {
        [self setupPixelBufferRenderView];
        self.configuration = contentConfiguration;
    }
    
    return self;
}

- (void)dealloc {
    [_pixelBufferRenderView release];
    [_contentConfiguration release];
    [super dealloc];
}

- (id<UIContentConfiguration>)configuration {
    return _contentConfiguration;
}

- (void)setConfiguration:(id<UIContentConfiguration>)configuration {
    if (_contentConfiguration) {
        [_contentConfiguration.notificationCenter removeObserver:self name:ns_EffectsContentConfiguration::didChangePixelBufferNotificationName object:nil];
    }
    
    auto contentConfiguration = static_cast<EffectsContentConfiguration *>(configuration);
    
    [_contentConfiguration release];
    _contentConfiguration = [contentConfiguration copy];
    
    [contentConfiguration.notificationCenter addObserver:self
                                                selector:@selector(didChangePixelBuffer:)
                                                    name:ns_EffectsContentConfiguration::didChangePixelBufferNotificationName
                                                  object:nil];
}

- (void)setupPixelBufferRenderView {
    PixelBufferRenderView *pixelBufferRenderView = [[PixelBufferRenderView alloc] initWithFrame:self.bounds];
    pixelBufferRenderView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:pixelBufferRenderView];
    [NSLayoutConstraint activateConstraints:@[
        [pixelBufferRenderView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [pixelBufferRenderView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [pixelBufferRenderView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [pixelBufferRenderView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
    
    self.pixelBufferRenderView = pixelBufferRenderView;
    [pixelBufferRenderView release];
}

- (void)didChangePixelBuffer:(NSNotification *)notification {
    id pixelBufferObject = notification.userInfo[ns_EffectsContentConfiguration::pixelBufferKey];
    auto pixelBuffer = static_cast<CVPixelBufferRef>(pixelBufferObject);
    [self.pixelBufferRenderView updatePixelBuffer:pixelBuffer];
}

@end
