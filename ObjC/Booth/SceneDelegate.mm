//
//  SceneDelegate.mm
//  Booth
//
//  Created by Jinwoo Kim on 10/20/23.
//

#import "SceneDelegate.hpp"
#import "CameraRootViewController.hpp"

@interface SceneDelegate ()
@end

@implementation SceneDelegate

- (void)dealloc {
    [_window release];
    [super dealloc];
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:static_cast<UIWindowScene *>(scene)];
    CameraRootViewController *cameraRootViewController = [CameraRootViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:cameraRootViewController];
    
    [cameraRootViewController release];
    [navigationController setToolbarHidden:NO animated:NO];
    window.rootViewController = navigationController;
    [navigationController release];
    
    [window makeKeyAndVisible];
    self.window = window;
    [window release];
}

@end
