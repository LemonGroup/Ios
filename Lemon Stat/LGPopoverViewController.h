//
//  LGPopoverViewController.h
//  Lemon Stat
//
//  Created by Arkadiy Grigoryanc on 17.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LGPopoverViewControllerDelegate;

@interface LGPopoverViewController : UIViewController

@property (weak, nonatomic) id<LGPopoverViewControllerDelegate> delegate;

// Data for pickers
@property (strong, nonatomic) NSDate *currentDate;
@property (strong, nonatomic, readonly) NSDate *minDate;
@property (strong, nonatomic, readonly) NSDate *maxDate;

@property (strong, nonatomic) NSString *currentString;

@end

@protocol LGPopoverViewControllerDelegate <NSObject>

- (void)actionReturn:(UIButton *)button;

- (void)stringChange:(NSString *)string;
- (NSString *)titleButtonForPopoverViewController:(LGPopoverViewController *)popoverViewController;

@optional
- (UIColor *)colorBackgroundForReturnButton;
- (UIColor *)colorTextForReturnButton;

// header
- (NSString *)titleForPopoverViewController:(LGPopoverViewController *)popoverViewController;

// Если метод arrayForPopoverViewController: не реализован или возвращает nil, то будет создан datePicker
// for picker with own array
- (NSArray<NSString *> *)arrayForPopoverViewController:(LGPopoverViewController *)popoverViewController;
- (NSString *)labelCurrentRowForPopoverViewController:(LGPopoverViewController *)popoverViewController;
// for date picker
- (void)dateRangeForDatePicker:(UIDatePicker *)datePicker forPopoverViewController:(LGPopoverViewController *)popoverViewController;
- (void)dateChange:(UIDatePicker *)datePicker;  // вызываеся каждый раз, когда меняется дата;

// вызывается когда контроллер исчезнет
- (void)disappearedPopoverViewController:(LGPopoverViewController *)popoverViewController;

@end
