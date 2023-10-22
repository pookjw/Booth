//
//  EffectsGridViewController.mm
//  Booth
//
//  Created by Jinwoo Kim on 10/20/23.
//

#import "EffectsGridViewController.hpp"
#import "EffectsView.hpp"
#import "PixelBufferRenderView.hpp"
#import <CoreMedia/CoreMedia.h>

@interface EffectsGridViewController ()
@property (retain) EffectsView *effectsView;
@property (retain) PixelBufferRenderView *tmp_renderView;
@end

@implementation EffectsGridViewController

- (void)dealloc {
    [_effectsView release];
    [_tmp_renderView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self setupEffectsView];
    [self set_tmp_renderView];
}

- (void)setupEffectsView {
    EffectsView *effectsView = [[EffectsView alloc] initWithFrame:self.view.bounds];
    effectsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:effectsView];
    self.effectsView = effectsView;
    [effectsView release];
}

- (void)set_tmp_renderView {
    PixelBufferRenderView *tmp_renderView = [[PixelBufferRenderView alloc] initWithFrame:self.view.bounds];
    tmp_renderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tmp_renderView];
    self.tmp_renderView = tmp_renderView;
    [tmp_renderView release];
}

- (void)updateSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    [self.tmp_renderView updatePixelBuffer:pixelBuffer];
}

@end
