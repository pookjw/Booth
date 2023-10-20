//
//  CameraService.mm
//  Booth
//
//  Created by Jinwoo Kim on 10/20/23.
//

#import "CameraService.hpp"
#import <AVFoundation/AVFoundation.h>

__attribute__((objc_direct_members))
@interface CameraService ()
@property (retain) AVCaptureSession *session;
@property (retain) AVCaptureDeviceDiscoverySession *discoverySession;
@property (retain) AVCaptureVideoDataOutput *videoDataOutput;
@property (retain) dispatch_queue_t videoDataOutputQueue;
@end

@implementation CameraService

- (instancetype)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)dealloc {
    // TODO: Pause session's'?
    [_session release];
    [_discoverySession release];
    [_videoDataOutput release];
    dispatch_release(_videoDataOutputQueue);
    [super dealloc];
}

@end
