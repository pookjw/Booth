//
//  EffectsItemModel.mm
//  Booth
//
//  Created by Jinwoo Kim on 10/24/23.
//

#import "EffectsItemModel.hpp"

const std::set<EffectsItemModelType> allEffectsItemModelTypes() {
    return {
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
}

__attribute__((objc_direct_members))
@interface EffectsItemModel ()
@property (assign) EffectsItemModelType type;
@end

@implementation EffectsItemModel

- (instancetype)initWithType:(EffectsItemModelType)type {
    if (self = [super init]) {
        _type = type;
    }
    
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        return _type == static_cast<EffectsItemModel *>(other)->_type;
    }
}

- (NSUInteger)hash {
    return _type;
}

@end
