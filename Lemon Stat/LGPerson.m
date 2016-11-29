//
//  LGPerson.m
//  Lemon Stat
//
//  Created by A&A  on 17.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGPerson.h"

@implementation LGPerson

+ (LGPerson *)personWithID:(NSNumber *)personID andName:(NSString *)personName {
    
    LGPerson *person = [[LGPerson alloc] init];
    
    person.personID = personID;
    person.personName = personName;
    
    return person;
    
}

- (NSComparisonResult)compare:(LGPerson *)element {
    return [_personName compare:[element personName]];
}

@end
