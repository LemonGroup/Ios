//
//  LGPersonListSingleton.m
//  
//
//  Created by A&A  on 17.11.16.
//
//

#import "LGPersonListSingleton.h"

@implementation LGPersonListSingleton

static LGPersonListSingleton* _sharedPersonList = nil;

+(LGPersonListSingleton*) sharedPersonList{
    
    @synchronized(self) {
        if (!_sharedPersonList) {
            _sharedPersonList = [[LGPersonListSingleton alloc] init];
        }
    }
    return _sharedPersonList;
    
}


@end
