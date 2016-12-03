//
//  AppDelegate.m
//  Lemon Stat
//
//  Created by decidion on 09.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "AppDelegate.h"


#import "LGSiteListSingleton.h"
#import "LGSite.h"
#import "LGPersonListSingleton.h"
#import "LGPerson.h"


NSURL *gBaseURL;
NSString *gContentType;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    extern NSString *gToken;
    
    gBaseURL = [NSURL URLWithString:@"http://yrsoft.cu.cc:8080"];
    gContentType = @"application/json";
    
    // разархивируем массив токенов и текущий токен
    NSString *path = [NSString stringWithFormat:@"%@/tokens.arch", NSTemporaryDirectory()];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] == YES) {      // если массив существует
        
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        NSLog(@"%@", dict);
        
        gToken = [dict objectForKey:@"currentToken"];
        
    }
    
//    NSMutableArray<LGSite *> *sites = [NSMutableArray array];
//    for (int i = 0; i < 4; i++) {
//        LGSite *site = [LGSite siteWithID:@1 andURL:@"www.site.ru"];
//        [sites addObject:site];
//    }
//    LGSiteListSingleton *siteList = [LGSiteListSingleton sharedSiteList];
//    siteList.sites = sites;
//    
//    NSMutableArray<LGPerson *> *persons = [NSMutableArray array];
//    for (int i = 0; i < 4; i++) {
//        LGPerson *person = [LGPerson personWithID:@2 andName:@"Персонаж"];
//        [persons addObject:person];
//    }
//    LGPersonListSingleton *personList = [LGPersonListSingleton sharedPersonList];
//    personList.persons = persons;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
