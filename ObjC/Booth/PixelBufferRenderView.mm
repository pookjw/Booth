//
//  PixelBufferRenderView.mm
//  Booth
//
//  Created by Jinwoo Kim on 10/22/23.
//

#import "PixelBufferRenderView.hpp"
#import "UIWindowScene+interfaceOrientationDidChangeNotification.hpp"
#import <MetalKit/MetalKit.h>
#import <cmath>
#import <utility>
#import <functional>
#import <array>

__attribute__((objc_direct_members))
@interface PixelBufferRenderView () {
    CVPixelBufferRef _queue_pixelBuffer;
    CVMetalTextureCacheRef _textureCache;
}

@property (readonly, nonatomic) CAMetalLayer *metalLayer;
@property (retain, nonatomic) dispatch_queue_t queue;

@property (retain, nonatomic) id<MTLDevice> device;
@property (retain, nonatomic) id<MTLCommandQueue> commandQueue;
@property (retain, nonatomic) id<MTLRenderPipelineState> renderPipelineState;
@property (retain, nonatomic) id<MTLSamplerState> samplerState;
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
    [_commandQueue release];
    [_renderPipelineState release];
    [_samplerState release];
    CFRelease(_textureCache);
    
    [super dealloc];
}

- (void)PixelBufferRenderView_commonInit __attribute__((objc_direct)) {
    [self setupQueue];
    dispatch_async(self.queue, ^{
        [self queue_setupMetalAttributes];
    });
}

- (CAMetalLayer *)metalLayer {
    return static_cast<CAMetalLayer *>(self.layer);
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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    CGFloat displayScale = self.traitCollection.displayScale; // TODO: trait changes
    CAMetalLayer *metalLayer = self.metalLayer;
    
    dispatch_async(self.queue, ^{
        metalLayer.drawableSize = CGSizeMake(size.width * displayScale, size.height * displayScale);
        [self queue_renderInMetalLayer:metalLayer];
    });
}

- (void)updatePixelBuffer:(CVPixelBufferRef)pixelBuffer __attribute__((objc_direct)) {
    // block catpure
    id bridged = (id)pixelBuffer;
    
    dispatch_async(self.queue, ^{
        auto pixelBuffer = static_cast<CVPixelBufferRef>(bridged);
        if (_queue_pixelBuffer) {
            CFRelease(_queue_pixelBuffer);
        }
        CFRetain(pixelBuffer);
        _queue_pixelBuffer = pixelBuffer;
        
        __block CAMetalLayer *metalLayer;
        dispatch_sync(dispatch_get_main_queue(), ^{
            metalLayer = [self.metalLayer retain];
        });
        
        [self queue_renderInMetalLayer:metalLayer];
        [metalLayer release];
    });
}

- (void)queue_renderInMetalLayer:(CAMetalLayer *)metalLayer __attribute__((objc_direct)) {
    if (_queue_pixelBuffer == NULL) return;
    
    id<CAMetalDrawable> _Nullable drawable = metalLayer.nextDrawable;
    if (!drawable) return;
    
    size_t width = CVPixelBufferGetWidth(_queue_pixelBuffer);
    size_t height = CVPixelBufferGetHeight(_queue_pixelBuffer);
    
    CVMetalTextureRef _Nullable metalTexture = nil;
    CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                              _textureCache,
                                              _queue_pixelBuffer,
                                              nil,
                                              MTLPixelFormatBGRA8Unorm,
                                              width,
                                              height,
                                              0,
                                              &metalTexture);
    
    if (!metalTexture) {
        CVMetalTextureCacheFlush(_textureCache, 0);
        return;
    }
    
    id<MTLTexture> _Nullable texture = CVMetalTextureGetTexture(metalTexture);
    CFRelease(metalTexture);
    
    if (!texture) {
        CVMetalTextureCacheFlush(_textureCache, 0);
        return;
    }
    
    //
    
    CGSize drawableSize = metalLayer.drawableSize;
    
    std::pair<std::float_t, std::float_t> ratio {
        std::fmaf(drawableSize.width, std::powl(width, -1.), 0.f), // drawableSize.width / width
        std::fmaf(drawableSize.height, std::powl(height, -1.), 0.f) // drawableSize.height / height
    };
    
    std::pair<std::float_t, std::float_t> scale;
    if (std::less<std::float_t>()(ratio.first, ratio.second)) { // ratio.first < ratio.second
        scale = {1.f, std::fmaf(ratio.first, std::powf(ratio.second, -1.f), 0.f)}; // (1.f, ratioX / ratioY)
    } else {
        scale = {std::fmaf(ratio.second, std::powf(ratio.first, -1.f), 0.f), 1.f}; // (ratioY / ratioX, 1.f)
    }
    
    std::array<std::float_t, 16> vertexArray {
        -scale.first, -scale.second, 0.f, 1.f,
        scale.first, -scale.second, 0.f, 1.f,
        -scale.first, scale.second, 0.f, 1.f,
        scale.first, scale.second, 0.f, 1.f
    };
    
    id<MTLBuffer> vertexCoordBuffer = [_device newBufferWithBytes:vertexArray.data() length:vertexArray.size() * sizeof(std::float_t) options:0];
    
    constexpr std::array<std::float_t, 8> textureArray {
        0.f, 1.f,
        1.f, 1.f,
        0.f, 0.f,
        1.f, 0.f
    };
    
    id<MTLBuffer> textureCoordBuffer = [_device newBufferWithBytes:textureArray.data() length:textureArray.size() * sizeof(std::float_t) options:0];
    
    MTLCommandBufferDescriptor *commandBufferDescriptor = [MTLCommandBufferDescriptor new];
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBufferWithDescriptor:commandBufferDescriptor];
    [commandBufferDescriptor release];
    
    //
    
    MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor new];
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.f, 1.f, 1.f, 1.f);
    
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [renderPassDescriptor release];
    commandEncoder.label = [NSString stringWithFormat:@"%@", self];
    [commandEncoder setRenderPipelineState:_renderPipelineState];
    [commandEncoder setVertexBuffer:vertexCoordBuffer offset:0 atIndex:0];
    [vertexCoordBuffer release];
    [commandEncoder setVertexBuffer:textureCoordBuffer offset:0 atIndex:1];
    [textureCoordBuffer release];
    [commandEncoder setFragmentTexture:texture atIndex:0];
    [commandEncoder setFragmentSamplerState:_samplerState atIndex:0];
    [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [commandEncoder endEncoding];
    
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
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
    id<MTLCommandQueue> commandQueue = [device newCommandQueue];
    
    NSError * _Nullable error = nil;
    id<MTLLibrary> library = [device newDefaultLibraryWithBundle:NSBundle.mainBundle error:&error];
    assert(!error);
    
    MTLFunctionDescriptor *vertexFunctionDescriptor = [MTLFunctionDescriptor new];
    vertexFunctionDescriptor.name = @"pixel_buffer_shader::vertexFunction";
    id<MTLFunction> vertexFunction = [library newFunctionWithDescriptor:vertexFunctionDescriptor error:&error];
    [vertexFunctionDescriptor release];
    assert(!error);
    
    MTLFunctionDescriptor *fragmentFunctionDescriptor = [MTLFunctionDescriptor new];
    fragmentFunctionDescriptor.name = @"pixel_buffer_shader::fragmentFunction";
    id<MTLFunction> fragmentFunction = [library newFunctionWithDescriptor:fragmentFunctionDescriptor error:&error];
    [fragmentFunctionDescriptor release];
    assert(!error);
    
    [library release];
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDescriptor.vertexFunction = vertexFunction;
    [vertexFunction release];
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    [fragmentFunction release];
    
    id<MTLRenderPipelineState> renderPipelineState = [device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
    [pipelineDescriptor release];
    assert(!error);
    
    MTLSamplerDescriptor *samplerDescriptor = [MTLSamplerDescriptor new];
    samplerDescriptor.sAddressMode = MTLSamplerAddressModeClampToEdge;
    samplerDescriptor.tAddressMode = MTLSamplerAddressModeClampToEdge;
    samplerDescriptor.minFilter = MTLSamplerMinMagFilterLinear;
    samplerDescriptor.magFilter = MTLSamplerMinMagFilterLinear;
    id<MTLSamplerState> samplerState = [device newSamplerStateWithDescriptor:samplerDescriptor];
    [samplerDescriptor release];
    
    CVReturn result = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &_textureCache);
    assert(result == kCVReturnSuccess);
    
    self.device = device;
    self.commandQueue = commandQueue;
    self.renderPipelineState = renderPipelineState;
    self.samplerState = samplerState;
    
    [device release];
    [commandQueue release];
    [renderPipelineState release];
    [samplerState release];
}

- (void)interfaceOrientationDidChange:(NSNotification *)notification {
    CAMetalLayer *metalLayer = self.metalLayer;
    
    dispatch_async(self.queue, ^{
        [self queue_renderInMetalLayer:metalLayer];
    });
}

@end
