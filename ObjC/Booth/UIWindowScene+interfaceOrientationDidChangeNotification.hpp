//
//  UIWindowScene+interfaceOrientationDidChangeNotification.hpp
//  Booth
//
//  Created by Jinwoo Kim on 9/24/23.
//

#import <UIKit/UIKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

static NSNotificationName const UIWindowSceneInterfaceOrientationDidChangeNotification = @"UIWindowSceneInterfaceOrientationDidChangeNotification";
static NSString * const UIWindowSceneInterfaceOrientationValueUserInfoKey = @"UIWindowSceneInterfaceOrientationValueUserInfoKey";
static NSString * const UIWindowSceneInterfaceOrientationAnimationDurationUserInfoKey = @"UIWindowSceneInterfaceOrientationAnimationDurationUserInfoKey";

NS_HEADER_AUDIT_END(nullability, sendability)
