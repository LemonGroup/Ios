//
//  UIImage+UISegmentIconAndText.h
//  Lemon Stat
//
//  Created by Arkadiy Grigoryanc on 26.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UISegmentIconAndText)

+ (instancetype) imageFromImage:(UIImage*)image size:(CGSize)size string:(NSString*)string;

@end
