//
//  EffectsGridViewController.mm
//  Booth
//
//  Created by Jinwoo Kim on 10/20/23.
//

#import "EffectsGridViewController.hpp"
#import "EffectsView.hpp"

@interface EffectsGridViewController ()
@property (retain) EffectsView *effectsView;
@end

@implementation EffectsGridViewController

- (void)dealloc {
    [_effectsView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupEffectsView];
}

- (void)setupEffectsView {
    EffectsView *effectsView = [[EffectsView alloc] initWithFrame:self.view.bounds];
    effectsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:effectsView];
    self.effectsView = effectsView;
    [effectsView release];
}

@end
