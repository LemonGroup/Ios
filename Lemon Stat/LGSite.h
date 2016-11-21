//
//  LGSite.h
//  Lemon Stat
//
//  Created by Arkadiy Grigoryanc on 21.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGSite : NSObject

@property (strong, nonatomic) NSNumber *siteID;
@property (strong, nonatomic) NSString *siteURL;

+ (LGSite *)siteWithID:(NSNumber *)siteID andURL:(NSString *)siteURL;

@end
