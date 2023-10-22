//
//  PixelBufferRenderView.h
//  Booth
//
//  Created by Jinwoo Kim on 10/22/23.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

__attribute__((objc_direct_members))
@interface PixelBufferRenderView : UIView
- (void)updatePixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
