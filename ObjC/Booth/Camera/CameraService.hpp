//
//  CameraService.hpp
//  Booth
//
//  Created by Jinwoo Kim on 10/20/23.
//

#import <Foundation/Foundation.h>
#import <functional>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

namespace ns_CameraService {
    static NSNotificationName const didChangeSampleBufferNotification = @"ns_CameraService::didChangeSampleBufferNotification";
    static NSString * const sampleBufferKey = @"sampleBufferKey";
}

@interface CameraService : NSObject

@end

NS_HEADER_AUDIT_END(nullability, sendability)
