//
//  LGSiteListSingleton.h
//  Lemon Stat
//
//  Created by A&A  on 17.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LGSite;

@interface LGSiteListSingleton : NSObject

@property (strong, nonatomic) NSArray<LGSite *> *sites;

+ (LGSiteListSingleton *)sharedSiteList;

- (void)sortList;

@end
