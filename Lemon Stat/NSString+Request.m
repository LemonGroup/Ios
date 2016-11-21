//
//  NSString+Request.m
//  Lemon Stat
//
//  Created by Arkadiy Grigoryanc on 21.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "NSString+Request.h"

@implementation NSString (Request)

- (NSString *)encodeString {
    
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:self];
    NSString *encoded = [self stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    
    return encoded;
    
}

@end
