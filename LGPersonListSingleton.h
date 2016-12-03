//
//  LGPersonListSingleton.h
//  
//
//  Created by A&A  on 17.11.16.
//
//

#import <Foundation/Foundation.h>
#import "LGPerson.h"

@interface LGPersonListSingleton : NSObject

@property (strong, nonatomic) NSArray<LGPerson *> *persons;

+ (LGPersonListSingleton *)sharedPersonList;

- (void)sortList;

@end
