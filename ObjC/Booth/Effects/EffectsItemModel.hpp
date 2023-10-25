//
//  EffectsItemModel.hpp
//  Booth
//
//  Created by Jinwoo Kim on 10/24/23.
//

#import <Foundation/Foundation.h>
#import <set>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSUInteger, EffectsItemModelType) {
    EffectsItemModelTypeTMP1,
    EffectsItemModelTypeTMP2,
    EffectsItemModelTypeTMP3,
    EffectsItemModelTypeTMP4,
    EffectsItemModelTypeTMP5,
    EffectsItemModelTypeTMP6,
    EffectsItemModelTypeTMP7,
    EffectsItemModelTypeTMP8,
    EffectsItemModelTypeTMP9,
    EffectsItemModelTypeTMP10,
    EffectsItemModelTypeTMP11,
    EffectsItemModelTypeTMP12,
    EffectsItemModelTypeTMP13,
    EffectsItemModelTypeTMP14,
    EffectsItemModelTypeTMP15,
    EffectsItemModelTypeTMP16,
    EffectsItemModelTypeTMP17,
    EffectsItemModelTypeTMP18
};

const std::set<EffectsItemModelType> allEffectsItemModelTypes();

__attribute__((objc_direct_members))
@interface EffectsItemModel : NSObject <NSCopying>
@property (assign, readonly) EffectsItemModelType type;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType:(EffectsItemModelType)type NS_DESIGNATED_INITIALIZER;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
