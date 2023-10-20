//
//  EffectsView.mm
//  Booth
//
//  Created by Jinwoo Kim on 10/20/23.
//

#import "EffectsView.hpp"

@implementation EffectsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self EffectsView_commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self EffectsView_commonInit];
    }
    
    return self;
}

- (void)EffectsView_commonInit {
    self.backgroundColor = UIColor.systemMintColor;
}

@end
