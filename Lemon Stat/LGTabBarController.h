//
//  LGTabBarController.h
//  Lemon Stat
//
//  Created by A&A  on 19.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGTabBarController : UITabBarController

@property (weak, nonatomic) IBOutlet UISegmentedControl *multipleOptions;

- (IBAction)changeSegment:(id)sender;



@end
