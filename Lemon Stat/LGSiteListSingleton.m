//
//  LGSiteListSingleton.m
//  Lemon Stat
//
//  Created by A&A  on 17.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGSiteListSingleton.h"

@implementation LGSiteListSingleton

+ (LGSiteListSingleton *)sharedSiteList {
    
    static LGSiteListSingleton* _sharedSiteList = nil;
    
    @synchronized(self) {
        if (!_sharedSiteList) {
            _sharedSiteList = [[LGSiteListSingleton alloc] init];
            //_sharedSiteList.sites = [NSMutabArray array];
        }
    }
    return _sharedSiteList;
    
}

- (void)sortList {
    
    _sites = [_sites sortedArrayUsingSelector:@selector(compare:)];
    
    //[_sites sortUsingSelector:@selector(compare:)];
}

@end
