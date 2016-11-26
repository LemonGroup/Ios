//
//  UIImage+UISegmentIconAndText.m
//  Lemon Stat
//
//  Created by Arkadiy Grigoryanc on 26.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "UIImage+UISegmentIconAndText.h"

@implementation UIImage (UISegmentIconAndText)

+ (instancetype) imageFromImage:(UIImage*)image size:(CGSize)imageSize string:(NSString*)string {
    
    UIFont *font = [UIFont systemFontOfSize:16.0];
    CGSize expectedTextSize = [string sizeWithAttributes:@{NSFontAttributeName: font}];
    
    UIImage *newImage = [image imageWithImage:image scaledToSize:imageSize];
    
    int width = expectedTextSize.width + newImage.size.width + 5;
    int height = MAX(expectedTextSize.height, newImage.size.width);
    CGSize size = CGSizeMake((float)width, (float)height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSetFillColorWithColor(context, color.CGColor);
    int fontTopPosition = (height - expectedTextSize.height) / 2;
    CGPoint textPoint = CGPointMake(newImage.size.width + 5, fontTopPosition);
    
    [string drawAtPoint:textPoint withAttributes:@{NSFontAttributeName: font}];
    // Images upside down so flip them
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, size.height);
    CGContextConcatCTM(context, flipVertical);
    
    NSInteger space = 10;
    CGRect rect = CGRectMake(space / 2,
                             (height - newImage.size.height) / 2 + space / 2,
                             newImage.size.width - space,
                             newImage.size.height - space);
    
    CGContextDrawImage(context, rect, newImage.CGImage);
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
    
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
