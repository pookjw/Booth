//
//  CameraRootViewController.mm
//  Booth
//
//  Created by Jinwoo Kim on 10/21/23.
//

#import "CameraRootViewController.hpp"
#import "EffectsGridViewController.hpp"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

namespace ns_CameraRootViewController {
    void *devicesContext = &devicesContext;
}

__attribute__((objc_direct_members))
@interface CameraRootViewController () <AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
@property (retain, nonatomic) EffectsGridViewController *effectsGridViewController;

@property (retain) AVCapturePhotoOutput *capturePhotoOutput;
@property (retain) AVCaptureVideoDataOutput *captureVideoDataOutput;
@property (retain) AVCaptureSession *captureSession;
@property (retain) AVCaptureDeviceDiscoverySession *deviceDiscoverySession;

@property (retain) dispatch_queue_t queue;
@property (retain) dispatch_queue_t videoSampleBufferQueue;
@end

@implementation CameraRootViewController

- (void)dealloc {
    [_deviceDiscoverySession removeObserver:self forKeyPath:@"devices" context:ns_CameraRootViewController::devicesContext];
    
    [_effectsGridViewController release];
    
    [_capturePhotoOutput release];
    [_captureVideoDataOutput release];
    // TODO: Pause session's'?
    [_captureSession release];
    [_deviceDiscoverySession release];
    
    dispatch_release(_queue);
    dispatch_release(_videoSampleBufferQueue);
    
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == ns_CameraRootViewController::devicesContext) {
        // TODO
        NSLog(@"Devices!!!");
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAttributes];
    [self setupEffectsGridViewController];
    [self setupQueue];
    
    dispatch_async(self.queue, ^{
        [self setupDeviceDiscoverySession];
        [self setupCapturePhotoOutput];
        [self setupCaptureVideoDataOutput];
        [self setupCaptureSession];
        
        [self requestVideoAuthorizationWithCompletionHandler:^(BOOL authorized) {
            dispatch_async(self.queue, ^{
                if (!self.captureSession.isRunning) {
                    [self.captureSession startRunning];
                }
            });
        }];
    });
}

- (void)setupAttributes __attribute__((objc_direct)) {
    UIAction *primaryAction = [UIAction actionWithTitle:[NSString string]
                                                  image:[UIImage systemImageNamed:@"camera.shutter.button.fill"]
                                             identifier:nil
                                                handler:^(__kindof UIAction * _Nonnull action) {
        // TODO
    }];
    
    UIBarButtonItem *captureBarButtonItem = [[UIBarButtonItem alloc] initWithPrimaryAction:primaryAction];
    [self setToolbarItems:@[captureBarButtonItem] animated:NO];
    [captureBarButtonItem release];
    
    self.view.backgroundColor = UIColor.systemBackgroundColor;
}

- (void)setupEffectsGridViewController __attribute__((objc_direct)) {
    EffectsGridViewController *effectsGridViewController = [EffectsGridViewController new];
    
    effectsGridViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addChildViewController:effectsGridViewController];
    [self.view addSubview:effectsGridViewController.view];
    [effectsGridViewController didMoveToParentViewController:self];
    
    self.effectsGridViewController = effectsGridViewController;
    [effectsGridViewController release];
}

- (void)setupQueue __attribute__((objc_direct)) {
    dispatch_queue_attr_t qosAttribute = dispatch_queue_attr_make_with_autorelease_frequency(dispatch_queue_attr_make_with_qos_class(nullptr, QOS_CLASS_UTILITY, QOS_MIN_RELATIVE_PRIORITY),
                                                                                             DISPATCH_AUTORELEASE_FREQUENCY_WORK_ITEM);
    dispatch_queue_t queue = dispatch_queue_create("com.pookjw.Booth.queue", qosAttribute);
    self.queue = queue;
    dispatch_release(queue);
}

- (void)setupDeviceDiscoverySession __attribute__((objc_direct)) {
    NSArray<AVCaptureDeviceType> *deviceTypes = @[
        AVCaptureDeviceTypeBuiltInWideAngleCamera,
        AVCaptureDeviceTypeBuiltInDualCamera,
        AVCaptureDeviceTypeBuiltInTrueDepthCamera,
        AVCaptureDeviceTypeExternal
    ];
    
    AVCaptureDeviceDiscoverySession *deviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes
                                                                                                                     mediaType:AVMediaTypeVideo
                                                                                                                      position:AVCaptureDevicePositionUnspecified];
    
    [deviceDiscoverySession addObserver:self forKeyPath:@"devices" options:NSKeyValueObservingOptionNew context:ns_CameraRootViewController::devicesContext];
    
    self.deviceDiscoverySession = deviceDiscoverySession;
}

- (void)setupCapturePhotoOutput __attribute__((objc_direct)) {
    AVCapturePhotoOutput *capturePhotoOutput = [AVCapturePhotoOutput new];
    
    // TOOD
//    if (photoSettings.availablePreviewPhotoPixelFormatTypes.count > 0) {
//        photoSettings.previewPhotoFormat = @{ (NSString*)kCVPixelBufferPixelFormatTypeKey : photoSettings.availablePreviewPhotoPixelFormatTypes.firstObject };
//    }
    
    self.capturePhotoOutput = capturePhotoOutput;
    [capturePhotoOutput release];
}

- (void)setupCaptureVideoDataOutput __attribute__((objc_direct)) {
    AVCaptureVideoDataOutput *captureVideoDataOutput = [AVCaptureVideoDataOutput new];
    dispatch_queue_attr_t qosAttribute = dispatch_queue_attr_make_with_autorelease_frequency(dispatch_queue_attr_make_with_qos_class(nullptr, QOS_CLASS_USER_INITIATED, QOS_MIN_RELATIVE_PRIORITY),
                                                                                             DISPATCH_AUTORELEASE_FREQUENCY_WORK_ITEM);
    dispatch_queue_t videoSampleBufferQueue = dispatch_queue_create("com.pookjw.Booth.videoSampleBufferQueue", qosAttribute);
    
    [[captureVideoDataOutput availableVideoCVPixelFormatTypes] enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        char buffer[5] = {0};
        *(int *)&buffer[0] = CFSwapInt32HostToBig([obj intValue]);
        NSLog(@"FORMAT: %s", buffer);
    }];
    
    [captureVideoDataOutput setSampleBufferDelegate:self queue:videoSampleBufferQueue];
    captureVideoDataOutput.videoSettings = @{
        (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)
    };
    
    self.captureVideoDataOutput = captureVideoDataOutput;
    self.videoSampleBufferQueue = videoSampleBufferQueue;
    [captureVideoDataOutput release];
    dispatch_release(videoSampleBufferQueue);
}

- (void)setupCaptureSession __attribute__((objc_direct)) {
    AVCaptureSession *captureSession = [AVCaptureSession new];
    
    [captureSession beginConfiguration];
    
    captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    assert([captureSession canAddOutput:self.captureVideoDataOutput]);
    [captureSession addOutput:self.captureVideoDataOutput];
    
    AVCaptureDevice * _Nullable captureDevice;
    if (AVCaptureDevice *userPreferredCamera = AVCaptureDevice.userPreferredCamera) {
        captureDevice = userPreferredCamera;
    } else if (AVCaptureDevice *systemPreferredCamera = AVCaptureDevice.systemPreferredCamera) {
        captureDevice = systemPreferredCamera;
    } else if (AVCaptureDevice *firstCaptureDevice = self.deviceDiscoverySession.devices.firstObject) {
        captureDevice = firstCaptureDevice;
    } else {
        captureDevice = nil;
    }
    
    if (captureDevice) {
        NSError * _Nullable error = nil;
        AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
        
        if (error) {
            NSLog(@"%@", error);
            assert(!error);
            return;
        }
        
        if (input) {
            [captureSession addInput:input];
        }
        
        [input release];
    }
    
    [captureSession commitConfiguration];
    
    self.captureSession = captureSession;
    [captureSession release];
}

- (void)requestVideoAuthorizationWithCompletionHandler:(void (^)(BOOL authorized))completionHandler __attribute__((objc_direct)) {
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized:
            completionHandler(YES);
            break;
        case AVAuthorizationStatusNotDetermined:
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:completionHandler];
            break;
        default:
            completionHandler(NO);
            break;
    }
}


#pragma mark - AVCapturePhotoCaptureDelegate

- (void)captureOutput:(AVCapturePhotoOutput *)output willBeginCaptureForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings {
    
}

- (void)captureOutput:(AVCapturePhotoOutput *)output willCapturePhotoForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings {
    
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didCapturePhotoForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings {
    
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error {
    
}

// and more...


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    [self.effectsGridViewController updatePixelBuffer:pixelBuffer];
}

@end
