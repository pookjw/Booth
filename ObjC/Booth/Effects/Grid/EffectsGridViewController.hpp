//
//  EffectsGridViewController.hpp
//  Booth
//
//  Created by Jinwoo Kim on 10/20/23.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

__attribute__((objc_direct_members))
@interface EffectsGridViewController : UIViewController
- (void)updateSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
