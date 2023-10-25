//
//  EffectsContentView.hpp
//  Booth
//
//  Created by Jinwoo Kim on 10/25/23.
//

#import <UIKit/UIKit.h>
#import "EffectsItemModel.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

namespace ns_EffectsContentConfiguration {
    static NSNotificationName const didChangePixelBufferNotificationName = @"ns_EffectsContentConfiguration::didChangePixelBufferNotificationName";
    static NSString * const pixelBufferKey = @"pixelBuffer";
}

__attribute__((objc_direct_members))
@interface EffectsContentConfiguration : NSObject <UIContentConfiguration>
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithItemModel:(EffectsItemModel *)itemModel notificationCenter:(NSNotificationCenter *)notificationCenter NS_DESIGNATED_INITIALIZER;
@end

__attribute__((objc_direct_members))
@interface EffectsContentView : UIView <UIContentView>
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithContentConfiguration:(EffectsContentConfiguration *)contentConfiguration;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
