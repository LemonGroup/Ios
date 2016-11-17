//
//  LGPopoverViewController.h
//  Lemon Stat
//
//  Created by Arkadiy Grigoryanc on 17.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LGPopoverViewControllerDelegate;

typedef enum {
    LGPopoverTypeSites = 1,
    LGPopoverTypePersons = 2,
    LGPopoverTypeStartDate = 3,
    LGPopoverTypeEndDate = 4
} LGPopoverType;

@interface LGPopoverViewController : UIViewController

@property (weak, nonatomic) id<LGPopoverViewControllerDelegate> delegate;

@property (assign, nonatomic) LGPopoverType type;

// Data for pickers
@property (strong, nonatomic) NSDate *currentDate;
@property (strong, nonatomic) NSString *currentString;

@property (assign, nonatomic) BOOL isRecognizeDisappear; // If know disappeared popover. Default is NO

@end

@protocol LGPopoverViewControllerDelegate <NSObject>

- (void)actionReturn:(UIButton *)button;

- (void)stringChange:(NSString *)string;
- (NSString *)titleButtonForPopoverViewController:(LGPopoverViewController *)popoverViewController;

@optional
- (void)dateChange:(UIDatePicker *)datePicker;

// вызывается когда контроллер исчезнет
- (void)disappearedPopoverViewController:(LGPopoverViewController *)popoverViewController;

@end
