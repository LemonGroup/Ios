//
//  LGPersonListSingleton.m
//  
//
//  Created by A&A  on 17.11.16.
//
//

#import "LGPersonListSingleton.h"

@implementation LGPersonListSingleton

+ (LGPersonListSingleton *)sharedPersonList {
    
    static LGPersonListSingleton* _sharedPersonList = nil;
    
    @synchronized(self) {
        if (!_sharedPersonList) {
            _sharedPersonList = [[LGPersonListSingleton alloc] init];
            //_sharedPersonList.persons = [NSMutableArray array];
        }
    }
    return _sharedPersonList;
    
}

- (void)sortList {
    
    _persons = [_persons sortedArrayUsingSelector:@selector(compare:)];
    
    //[_persons sortUsingSelector:@selector(compare:)];
}

@end
