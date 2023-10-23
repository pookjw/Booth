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
    CVPixelBufferRef _queue_pixelBuffer;
    CVMetalTextureCacheRef _textureCache;
}

@property (retain, nonatomic) dispatch_queue_t queue;

@property (retain, nonatomic) id<MTLDevice> device;
@property (retain, nonatomic) id<MTLSamplerState> sampler;
@property (retain, nonatomic) id<MTLRenderPipelineState> renderPipelineState;
@property (retain, nonatomic) id<MTLCommandQueue> commandQueue;
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
    if (_queue_pixelBuffer) {
        CFRelease(_queue_pixelBuffer);
    }
    dispatch_release(_queue);
    
    [_device release];
    [_sampler release];
    [_renderPipelineState release];
    [_commandQueue release];
    CFRelease(_textureCache);
    
    [super dealloc];
}

- (void)PixelBufferRenderView_commonInit __attribute__((objc_direct)) {
    [self setupQueue];
    dispatch_async(self.queue, ^{
        [self queue_setupMetalAttributes];
    });
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (UIWindowScene *windowScene = self.window.windowScene) {
        [NSNotificationCenter.defaultCenter removeObserver:self name:UIWindowSceneInterfaceOrientationDidChangeNotification object:windowScene];
    }
    
    [super willMoveToWindow:newWindow];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    if (UIWindowScene *windowScene = self.window.windowScene) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(interfaceOrientationDidChange:) name:UIWindowSceneInterfaceOrientationDidChangeNotification object:windowScene];
    }
}

- (void)updatePixelBuffer:(CVPixelBufferRef)pixelBuffer __attribute__((objc_direct)) {
    // block catpure
    id bridged = (id)pixelBuffer;
    
    // TODO
    dispatch_async(self.queue, ^{
        auto pixelBuffer = static_cast<CVPixelBufferRef>(bridged);
        if (_queue_pixelBuffer) {
            CFRelease(_queue_pixelBuffer);
        }
        CFRetain(pixelBuffer);
        _queue_pixelBuffer = pixelBuffer;
        
        [self queue_renderWithPixelBuffer:pixelBuffer];
    });
}

- (void)render __attribute__((objc_direct)) {
    dispatch_async(self.queue, ^{
        [self queue_renderWithPixelBuffer:_queue_pixelBuffer];
    });
}

- (void)queue_renderWithPixelBuffer:(CVPixelBufferRef)pixelBuffer __attribute__((objc_direct)) {
    if (pixelBuffer == NULL) return;
    
    // TODO
}

- (void)setupQueue __attribute__((objc_direct)) {
    dispatch_queue_attr_t qosAttribute = dispatch_queue_attr_make_with_autorelease_frequency(dispatch_queue_attr_make_with_qos_class(nullptr, QOS_CLASS_UTILITY, QOS_MIN_RELATIVE_PRIORITY),
                                                                                             DISPATCH_AUTORELEASE_FREQUENCY_WORK_ITEM);
    dispatch_queue_t queue = dispatch_queue_create("com.pookjw.Booth.queue", qosAttribute);
    self.queue = queue;
    dispatch_release(queue);
}

- (void)queue_setupMetalAttributes __attribute__((objc_direct)) {
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    
    NSError * _Nullable error = nil;
    id<MTLLibrary> library = [device newDefaultLibraryWithBundle:NSBundle.mainBundle error:&error];
    assert(!error);
    
    MTLFunctionDescriptor *vertexFunction = [MTLFunctionDescriptor new];
    vertexFunction.name = @"pixel_buffer_shader::vertexFunction";
    
    MTLFunctionDescriptor *fragmentFunction = [MTLFunctionDescriptor new];
    fragmentFunction.name = @"pixel_buffer_shader::fragmentFunction";
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    
    self.device = device;
    
    [device release];
}

- (void)interfaceOrientationDidChange:(NSNotification *)notification {
    [self render];
}

@end
