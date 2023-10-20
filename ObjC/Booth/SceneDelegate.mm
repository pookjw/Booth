//
//  SceneDelegate.mm
//  Booth
//
//  Created by Jinwoo Kim on 10/20/23.
//

#import "SceneDelegate.hpp"
#import "EffectsGridViewController.hpp"

@interface SceneDelegate ()
@end

@implementation SceneDelegate

- (void)dealloc {
    [_window release];
    [super dealloc];
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:static_cast<UIWindowScene *>(scene)];
    EffectsGridViewController *rootViewController = [EffectsGridViewController new];
    window.rootViewController = rootViewController;
    [rootViewController release];
    [window makeKeyAndVisible];
    self.window = window;
    [window release];
}

@end
