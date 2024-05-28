//
//  UIWindowScene+interfaceOrientationDidChangeNotification.mm
//  Booth
//
//  Created by Jinwoo Kim on 9/24/23.
//

#import "UIWindowScene+interfaceOrientationDidChangeNotification.hpp"
#import <objc/runtime.h>
#import <objc/message.h>

namespace UIWindowScene_Booth_Category {
    namespace _updateClientSettingsToInterfaceOrientation_withAnimationDuration {
        static void (*original)(UIWindowScene *self, SEL _cmd, UIInterfaceOrientation interfaceOrientation, CGFloat animationDuration);
        static void custom(UIWindowScene *self, SEL _cmd, UIInterfaceOrientation interfaceOrientation, CGFloat animationDuration) {
            original(self, _cmd, interfaceOrientation, animationDuration);
            [NSNotificationCenter.defaultCenter postNotificationName:UIWindowSceneInterfaceOrientationDidChangeNotificationName
                                                              object:self
                                                            userInfo:@{
                UIWindowSceneInterfaceOrientationValueUserInfoKey: @(self.interfaceOrientation),
                UIWindowSceneInterfaceOrientationAnimationDurationUserInfoKey: @(animationDuration)
            }];
        }
        
        static void swizzle() {
            Method method = class_getInstanceMethod(UIWindowScene.class, NSSelectorFromString(@"_updateClientSettingsToInterfaceOrientation:withAnimationDuration:"));
            original = reinterpret_cast<void (*)(UIWindowScene *, SEL, UIInterfaceOrientation, CGFloat)>(method_getImplementation(method));
            method_setImplementation(method, reinterpret_cast<IMP>(&custom));
        }
    }
}

@implementation UIWindowScene (Booth_Category)

+ (void)load {
    UIWindowScene_Booth_Category::_updateClientSettingsToInterfaceOrientation_withAnimationDuration::swizzle();
}

@end
