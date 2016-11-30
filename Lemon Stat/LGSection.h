//
//  LGSection.h
//  Lemon Stat
//
//  Created by Arkadiy Grigoryanc on 30.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LGDailyRow;
@class LGGeneralRow;

@interface LGSection : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray<id> *rows;

@end
