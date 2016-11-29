//
//  LGPopoverViewController.m
//  Lemon Stat
//
//  Created by Arkadiy Grigoryanc on 17.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGPopoverViewController.h"

@interface LGPopoverViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) NSArray *dataArray;

@property (weak, nonatomic) UIButton *returnButton;

@end

@implementation LGPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // create button
    [self createButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self.delegate respondsToSelector:@selector(titleForPopoverViewController:)]) {
        
        NSString *title = [self.delegate titleForPopoverViewController:self];
        
        if (title) {
            self.navigationItem.title = title;
        } else {
            self.navigationController.navigationBarHidden = YES;
        }
        
    } else {
        self.navigationController.navigationBarHidden = YES;
    }
    
    if ([self.delegate respondsToSelector:@selector(arrayForPopoverViewController:)]) {
        
        NSArray *arrayData = [self.delegate arrayForPopoverViewController:self];
        
        if (arrayData) {
            if (arrayData.count > 0) {
                [self createPickerWithArray:arrayData];
            }
        } else {
            [self createDatePicker];
        }
        
    } else {
        [self createDatePicker];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([self.delegate respondsToSelector:@selector(disappearedPopoverViewController:)]) {
        [self.delegate disappearedPopoverViewController:self];
    }
}

- (void)dealloc {
    NSLog(@"Popover is dealocated");
}

#pragma mark - Methods

- (void)createPickerWithArray:(NSArray *)array {
    
    self.dataArray = array;
    
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.center = self.view.center;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    
    NSInteger row = 0;
    
    if ([self.delegate respondsToSelector:@selector(labelCurrentRowForPopoverViewController:)]) {
        
        NSString *labelCurrentRow = [self.delegate labelCurrentRowForPopoverViewController:self];
        
        if (labelCurrentRow) {
            
            if ([array containsObject:labelCurrentRow]) {
                
                row = [array indexOfObject:labelCurrentRow];
                [pickerView selectRow:row inComponent:0 animated:NO];
                
            }
        }
    }
    
    [self stringChange:array[row]];
    
    [self.view addSubview:pickerView];
}

- (void)createDatePicker {
    
    // set frame
    CGFloat heightNavBar = CGRectGetHeight(self.navigationController.navigationBar.frame);
    
    CGRect rect;
    
    if (!self.navigationController.navigationBarHidden) {
        rect = CGRectMake(0, heightNavBar, self.preferredContentSize.width, self.preferredContentSize.height - CGRectGetHeight(self.returnButton.frame));
    } else {
        rect = CGRectMake(0, 0, self.preferredContentSize.width, self.preferredContentSize.height + heightNavBar - CGRectGetHeight(self.returnButton.frame));
    }
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:rect];
    
    // set mode
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    // set range dates
    if([self.delegate respondsToSelector:@selector(dateRangeForDatePicker:forPopoverViewController:)]) {
        [self.delegate dateRangeForDatePicker:datePicker forPopoverViewController:self];
    } else {
        datePicker.minimumDate = [[NSDate alloc] initWithTimeIntervalSince1970:0];
        datePicker.maximumDate = [NSDate date];
    }
    
    // set current date
    if (_currentDate) {
        datePicker.date = _currentDate;
    }
    
    if ([self.delegate respondsToSelector:@selector(dateChange:)]) {
        
        // set action
        [datePicker addTarget:self.delegate
                       action:@selector(dateChange:)
             forControlEvents:UIControlEventValueChanged];
        
        [self.delegate dateChange:datePicker];
    }
    
    [self.view addSubview:datePicker];
}

- (void)createButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // set frame
    NSInteger heightButton = 50;
    CGFloat heightNavBar = CGRectGetHeight(self.navigationController.navigationBar.frame);
    button.frame = CGRectMake(0,
                              self.preferredContentSize.height + heightNavBar - heightButton,
                              self.preferredContentSize.width,
                              heightButton);
    
    // set background title
    if ([self.delegate respondsToSelector:@selector(colorBackgroundForReturnButton)]) {
        [button setBackgroundColor:[self.delegate colorBackgroundForReturnButton]];
    }
    
    // set title
    NSString *title;
    if ([self.delegate respondsToSelector:@selector(titleButtonForPopoverViewController:)]) {
        title = [self.delegate titleButtonForPopoverViewController:self];
    } else {
        title = @"ОК";
    }
    [button setTitle:title forState:UIControlStateNormal];
    
    // set text color
    UIColor *color;
    if ([self.delegate respondsToSelector:@selector(colorTextForReturnButton)]) {
        color = [self.delegate colorTextForReturnButton];
    } else {
        color = [UIColor blackColor];
    }
    [button setTitleColor:color forState:UIControlStateNormal];
    
    // set action
    [button addTarget:self.delegate
               action:@selector(actionReturn:)
     forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:button];
    self.returnButton = button;
}

- (void)stringChange:(NSString *)string {
    
    if ([self.delegate respondsToSelector:@selector(stringChange:)]) {
        
        [self.delegate stringChange:string];
    }
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _dataArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self stringChange:_dataArray[row]];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _dataArray.count;
}

@end
