//
//  PixelBufferRenderView.mm
//  Booth
//
//  Created by Jinwoo Kim on 10/22/23.
//

#import "PixelBufferRenderView.hpp"
#import "UIWindowScene+interfaceOrientationDidChangeNotification.hpp"
#import <MetalKit/MetalKit.h>

__attribute__((objc_direct_members))
@interface PixelBufferRenderView () {
    CMSampleBufferRef _sampleBuffer;
}
@property (retain) dispatch_queue_t queue;
@end

@implementation PixelBufferRenderView

+ (Class)layerClass {
    return CAMetalLayer.class;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self PixelBufferRenderView_commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self PixelBufferRenderView_commonInit];
    }
    
    return self;
}

- (void)dealloc {
    CFRelease(_sampleBuffer);
    dispatch_release(self.queue);
    [super dealloc];
}

- (void)PixelBufferRenderView_commonInit __attribute__((objc_direct)) {
    dispatch_queue_attr_t qosAttribute = dispatch_queue_attr_make_with_autorelease_frequency(dispatch_queue_attr_make_with_qos_class(nullptr, QOS_CLASS_UTILITY, QOS_MIN_RELATIVE_PRIORITY),
                                                                                             DISPATCH_AUTORELEASE_FREQUENCY_WORK_ITEM);
    dispatch_queue_t queue = dispatch_queue_create("com.pookjw.Booth.queue", qosAttribute);
    self.queue = queue;
    dispatch_release(queue);
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (UIWindowScene *windowScene = self.window.windowScene) {
        [NSNotificationCenter.defaultCenter removeObserver:self name:UIWindowSceneInterfaceOrientationDidChangeNotification object:windowScene];
    }
    
    [self willMoveToWindow:newWindow];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    if (UIWindowScene *windowScene = self.window.windowScene) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(interfaceOrientationDidChange:) name:UIWindowSceneInterfaceOrientationDidChangeNotification object:windowScene];
    }
}

- (void)updateSampleBuffer:(CMSampleBufferRef)sampleBuffer __attribute__((objc_direct)) {
    // data race?
    CFRelease(_sampleBuffer);
    CFRetain(sampleBuffer);
    _sampleBuffer = sampleBuffer;
}

- (void)interfaceOrientationDidChange:(NSNotification *)notification {
    [self render];
}

- (void)render __attribute__((objc_direct)) {
    // retain 미리
    dispatch_async(self.queue, ^{
        
    });
}

@end
