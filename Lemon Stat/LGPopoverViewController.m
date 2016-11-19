//
//  LGPopoverViewController.m
//  Lemon Stat
//
//  Created by Arkadiy Grigoryanc on 17.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGPopoverViewController.h"

#import "LGGeneralStatsController.h"
#import "LGDailyStatsController.h"

@interface LGPopoverViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

// Fake Data
@property (strong, nonatomic) NSArray *personsFake;
@property (strong, nonatomic) NSArray *sitesFake;

@property (strong, nonatomic) NSArray *arrayFake;

@end

@implementation LGPopoverViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isRecognizeDisappear = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.view.backgroundColor = [UIColor whiteColor];
    
    // filling fake data
    _personsFake = @[@"Путин", @"Медведев", @"Навальный"];
    _sitesFake = @[@"lenta.ru", @"vesti.ru", @"rbk.ru"];
    
    if ([self.delegate respondsToSelector:@selector(recognizeDisappearForPopoverViewController:)]) {
        _isRecognizeDisappear = [self.delegate recognizeDisappearForPopoverViewController:self];
    }
    
    // create button
    [self createButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    switch (self.type) {
        case LGPopoverTypeSites:
            self.navigationItem.title = @"Выберите сайт";
            [self createPickerWithArray:self.sitesFake];
            break;
        case LGPopoverTypePersons:
            self.navigationItem.title = @"Выберите личность";
            [self createPickerWithArray:self.personsFake];
            break;
        case LGPopoverTypeStartDate:
            self.navigationItem.title = @"Выберите дату начала";
            [self createDatePicker];
            break;
        case LGPopoverTypeEndDate:
            self.navigationItem.title = @"Выберите дату окончания";
            [self createDatePicker];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (_isRecognizeDisappear) {
        [self.delegate disappearedPopoverViewController:self];
    }
}

- (void)dealloc {
    NSLog(@"Popover is dealocated");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Methods

- (void)createPickerWithArray:(NSArray *)array {
    
    self.arrayFake = array;
    
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.center = self.view.center;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    
    if (![_currentString isEqualToString:@""]) {
        
        NSInteger row = [array indexOfObject:_currentString];
        [pickerView selectRow:row inComponent:0 animated:NO];
        
    } else {
        
        NSInteger row = [pickerView selectedRowInComponent:0];
        [self.delegate stringChange:_arrayFake[row]];
    }
    
    [self.view addSubview:pickerView];
}

- (void)createDatePicker {
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.center = self.view.center;
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    if([self.delegate respondsToSelector:@selector(dateRangeForDatePicker:forPopoverViewController:)]) {
        [self.delegate dateRangeForDatePicker:datePicker forPopoverViewController:self];
    } else {
        datePicker.minimumDate = [[NSDate alloc] initWithTimeIntervalSince1970:0];
        datePicker.maximumDate = [NSDate date];
    }
    
    if (_currentDate) {
        datePicker.date = _currentDate;
    }
    
    [datePicker addTarget:self.delegate
                   action:@selector(dateChange:)
         forControlEvents:UIControlEventValueChanged];
    
    [self.delegate dateChange:datePicker];
    [self.view addSubview:datePicker];
    
}

- (void)createButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSInteger heightButton = 50;
    
    CGFloat heightNavBar = CGRectGetHeight(self.navigationController.navigationBar.frame);// valueForKey:@"view"] frame]);
    
    button.frame = CGRectMake(0,
                              self.preferredContentSize.height + heightNavBar - heightButton,
                              self.preferredContentSize.width,
                              heightButton);
    
    [button setBackgroundColor:[UIColor yellowColor]];
    
    NSString *title = [self.delegate titleButtonForPopoverViewController:self];
    [button setTitle:title forState:UIControlStateNormal];
    
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [button addTarget:self.delegate
               action:@selector(actionReturn:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
//    self.returnKeyButton = button;
    
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _arrayFake[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.delegate stringChange:_arrayFake[row]];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _arrayFake.count;
}

@end
