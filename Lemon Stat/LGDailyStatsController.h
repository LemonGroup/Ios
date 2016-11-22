//
//  LGDailyStatsController.h
//  Lemon Stat
//
//  Created by decidion on 09.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TextFieldTypeSites = 1,
    TextFieldTypePersons = 2,
    TextFieldTypeStartDate = 3,
    TextFieldTypeEndDate = 4
} TextFieldType;

@interface LGDailyStatsController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *siteLabel;
@property (weak, nonatomic) IBOutlet UITextField *personLabel;
@property (weak, nonatomic) IBOutlet UITextField *startDateLabel;
@property (weak, nonatomic) IBOutlet UITextField *endDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalNumberLabel;

@end

