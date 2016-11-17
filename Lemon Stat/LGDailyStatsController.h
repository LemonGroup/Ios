//
//  LGDailyStatsController.h
//  Lemon Stat
//
//  Created by decidion on 09.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGDailyStatsController : UIViewController

@property (strong, nonatomic) NSDate *selectedStartDate;
@property (strong, nonatomic) NSDate *selectedEndDate;

@property (weak, nonatomic) IBOutlet UITextField *siteLabel;
@property (weak, nonatomic) IBOutlet UITextField *personLabel;
@property (weak, nonatomic) IBOutlet UITextField *startDateLabel;
@property (weak, nonatomic) IBOutlet UITextField *endDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalNumberLabel;

@end
