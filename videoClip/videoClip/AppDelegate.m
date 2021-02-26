//
//  AppDelegate.m
//  videoClip
//
//  Created by db J on 2021/2/24.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch
    
    //创建沙盒文件地址
    [SystemUtils successCreateMyGIFDirectory];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:[[HomeViewController alloc]init]];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
    return YES;
}


@end
