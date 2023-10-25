//
//  EffectsGridViewController.mm
//  Booth
//
//  Created by Jinwoo Kim on 10/20/23.
//

#import "EffectsGridViewController.hpp"
#import "EffectsView.hpp"

@interface EffectsGridViewController ()
@property (retain, nonatomic) EffectsView *effectsView;
@end

@implementation EffectsGridViewController

- (void)dealloc {
    [_effectsView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAttributes];
    [self setupEffectsView];
}

- (void)updatePixelBuffer:(CVPixelBufferRef)pixelBuffer __attribute__((objc_direct)) {
    [self.effectsView updatePixelBuffer:pixelBuffer];
}

- (void)setupAttributes __attribute__((objc_direct)) {
    self.view.backgroundColor = UIColor.clearColor;
}

- (void)setupEffectsView __attribute__((objc_direct)) {
    EffectsView *effectsView = [[EffectsView alloc] initWithFrame:self.view.bounds layout:EffectsViewLayoutGrid];
    effectsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:effectsView];
    self.effectsView = effectsView;
    [effectsView release];
}

@end
