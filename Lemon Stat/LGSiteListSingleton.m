//
//  LGSiteListSingleton.m
//  Lemon Stat
//
//  Created by A&A  on 17.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGSiteListSingleton.h"

@implementation LGSiteListSingleton

    
static LGSiteListSingleton* _sharedSiteList = nil;
    
+(LGSiteListSingleton*) sharedSiteList{
        
        @synchronized(self) {
            if (!_sharedSiteList) {
                _sharedSiteList = [[LGSiteListSingleton alloc] init];
            }
        }
        return _sharedSiteList;
    
}

@end
