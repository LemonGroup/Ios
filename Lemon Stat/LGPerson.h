//
//  LGPerson.h
//  Lemon Stat
//
//  Created by A&A  on 17.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGPerson : NSObject

@property (strong, nonatomic) NSNumber *personID;
@property (strong, nonatomic) NSString *personName;

+ (LGPerson *)personWithID:(NSNumber *)personID andName:(NSString *)personName;

@end
