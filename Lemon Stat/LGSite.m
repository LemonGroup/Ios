//
//  LGSite.m
//  Lemon Stat
//
//  Created by Arkadiy Grigoryanc on 21.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGSite.h"

@implementation LGSite

+ (LGSite *)siteWithID:(NSNumber *)siteID andURL:(NSString *)siteURL {
    
    LGSite *site = [[LGSite alloc] init];
    
    site.siteID = siteID;
    site.siteURL = siteURL;
    
    return site;
    
}

@end
