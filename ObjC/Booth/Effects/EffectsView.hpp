//
//  EffectsView.h
//  Booth
//
//  Created by Jinwoo Kim on 10/20/23.
//

#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSUInteger, EffectsViewLayout) {
    EffectsViewLayoutGrid,
    EffectsViewLayoutFull
};

__attribute__((objc_direct_members))
@interface EffectsView : UIView
- (instancetype)initWithFrame:(CGRect)frame layout:(EffectsViewLayout)layout;
- (void)updatePixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
