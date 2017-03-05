#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //tabcolor
    //UITabBarController *tabBarController = (UITabBarController *) self.window.rootViewController;
    //tabBarController.view.tintColor = [UIColor redColor];

    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    
    return YES;
}

@end
