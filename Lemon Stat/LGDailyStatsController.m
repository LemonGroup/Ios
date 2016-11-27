//
//  LGDailyStatsController.m
//  Lemon Stat
//
//  Created by decidion on 09.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGDailyStatsController.h"

#import "LGPopoverViewController.h"

#import <AFNetworking/AFNetworking.h>

#import "LGSiteListSingleton.h"
#import "LGSite.h"
#import "LGPersonListSingleton.h"
#import "LGPerson.h"

#import "NSString+Request.h"

typedef enum {
    TextFieldTypeSites = 1,
    TextFieldTypePersons = 2,
    TextFieldTypeStartDate = 3,
    TextFieldTypeEndDate = 4
} TextFieldType;

@interface LGDailyStatsController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, LGPopoverViewControllerDelegate> {
    NSArray *_responseJSON;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UITextField *siteField;
@property (weak, nonatomic) IBOutlet UITextField *personField;
@property (weak, nonatomic) IBOutlet UITextField *startDateField;
@property (weak, nonatomic) IBOutlet UITextField *endDateField;

@property (weak, nonatomic) IBOutlet UILabel *totalNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *responseLabel;

@property (weak, nonatomic) UIButton *applyButton;

@property (weak, nonatomic) LGPopoverViewController *popoverViewController;

@property (weak, nonatomic) UITextField *currentTextField;

@property (strong, nonatomic) NSDate *selectedStartDate;
@property (strong, nonatomic) NSDate *selectedEndDate;

@end

@implementation LGDailyStatsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Requests Methods

- (void)requestStat {
    
    extern NSString *gToken;
    extern NSURL *baseURL;
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithBaseURL:baseURL];
    [manager.requestSerializer setValue:gToken forHTTPHeaderField:@"Auth-Token"];
    
    NSString *urlString = [self stringForRequest];
    
    [manager GET:urlString
      parameters:nil
        progress:nil
         success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
             
             _responseJSON = responseObject;
             
             [self.tableView reloadData];
             [self setTotalNumber];
             NSLog(@"JSON: %@", _responseJSON);
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
         }];
    
}

- (NSString *)stringForRequest {
    
    NSInteger siteID = 0;
    
    for (LGSite *site in [[LGSiteListSingleton sharedSiteList] sites]) {
        
        if ([site.siteURL isEqualToString:_siteField.text]) {
            siteID = [site.siteID integerValue];
            continue;
        }
        
    }
    
    NSInteger personID = 0;
    
    for (LGPerson *person in [[LGPersonListSingleton sharedPersonList] persons]) {
        
        if ([person.personName isEqualToString:_personField.text]) {
            personID = [person.personID integerValue];
            continue;
        }
        
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *startDate = [formatter stringFromDate:_selectedStartDate];
    NSString *endDate = [formatter stringFromDate:_selectedEndDate];
    
    NSString *string = [NSString stringWithFormat:@"http://yrsoft.cu.cc:8080/stat/daily_stat?siteId=%ld&personId=%ld&start_date=%@&end_date=%@", siteID, personID, startDate, endDate];
    
    return [string encodeURLString];
}

#pragma mark - UITableViewDelegate



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _responseJSON.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"DateCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    // set textLabel
    cell.textLabel.text = [_responseJSON[indexPath.row] valueForKey:@"date"];
    
    // set detailTextLabel
    NSString *numberOfNewPages = [_responseJSON[indexPath.row] valueForKey:@"numberOfNewPages"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", numberOfNewPages];
    
    return cell;
}

#pragma mark - Methods

- (void)setTotalNumber {
    
    NSInteger totalNumber = 0;
    
    for (id obj in _responseJSON) {
        
        NSNumber *number = [obj valueForKey:@"numberOfNewPages"];
        
        totalNumber += [number integerValue];
    }
    
    _totalNumberLabel.text = [NSString stringWithFormat:@"%ld", totalNumber];
}

- (void)createPopover:(UITextField *)sender {
    
    CGSize contentSize = CGSizeMake(280,280);
    
    LGPopoverViewController *vc= [[LGPopoverViewController alloc] init];
    vc.preferredContentSize = contentSize;
    vc.delegate = self;
    //vc.type = (LGPopoverType)sender.tag;
    
    switch (sender.tag) {
        case TextFieldTypeSites:
            vc.currentString = self.siteField.text;
            break;
        case TextFieldTypePersons:
            vc.currentString = self.personField.text;
            break;
        case TextFieldTypeStartDate:
            vc.currentDate = _selectedStartDate;
            break;
        case TextFieldTypeEndDate:
            vc.currentDate = _selectedEndDate;
            break;
        default:
            break;
    }
    
    self.popoverViewController = vc;
    self.currentTextField = sender;
    
    UINavigationController *destNav = [[UINavigationController alloc] initWithRootViewController:vc];
    destNav.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *presentationController = [destNav popoverPresentationController];
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    presentationController.delegate = self;
    presentationController.sourceView = sender;
    presentationController.sourceRect = sender.bounds;
    
    [self presentViewController:destNav animated:YES completion:nil];
    
}

- (void)createRefreshButton {
    
    if (_applyButton == nil) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"Обновить" forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(actionRefresh:)
         forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0, 0, 100, 20);
        button.center = _responseLabel.center;
        
        _applyButton = button;
        
        [self.view addSubview:button];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [self createPopover:textField];
    
    return NO;
}

#pragma mark - UIAdaptivePresentationControllerDelegate

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}

#pragma mark - LGPopoverViewControllerDelegate

- (NSString *)titleForPopoverViewController:(LGPopoverViewController *)popoverViewController {
    
    switch (self.currentTextField.tag) {
        case TextFieldTypeSites:
            return @"Выберите сайт";
            break;
        case TextFieldTypePersons:
            return @"Выберите личность";
            break;
        case TextFieldTypeStartDate:
            return @"Выберите начальную дату";
            break;
        case TextFieldTypeEndDate:
            return @"Выберите конечную дату";
            break;
            
        default:
            return nil;
            break;
    }
}

- (NSArray *)arrayForPopoverViewController:(LGPopoverViewController *)popoverViewController {
    
    NSMutableArray *array = [NSMutableArray array];
    
    switch (self.currentTextField.tag) {
        case TextFieldTypeSites: {
            
            for (LGSite *site in [[LGSiteListSingleton sharedSiteList] sites]) {
                [array addObject:site.siteURL];
            }
        }
            break;
        case TextFieldTypePersons: {
            
            for (LGPerson *person in [[LGPersonListSingleton sharedPersonList] persons]) {
                [array addObject:person.personName];
            }
        }
            break;
        default:
            return nil;
            break;
    }
    
    return array;
}

- (NSString *)labelCurrentRowForPopoverViewController:(LGPopoverViewController *)popoverViewController {
    
    switch (self.currentTextField.tag) {
        case TextFieldTypeSites:
            return _siteField.text;
            break;
        case TextFieldTypePersons:
            return _personField.text;
            break;
        default:
            return nil;
            break;
    }
    
}

- (void)stringChange:(NSString *)string {
    
    switch (self.currentTextField.tag) {
        case TextFieldTypeSites: {
            self.siteField.text = string;
        }
            break;
        case TextFieldTypePersons: {
            self.personField.text = string;
        }
            break;
        default:
            break;
    }
}

- (void)dateChange:(UIDatePicker *)datePicker {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMMM YYYY"];
    
    switch (self.currentTextField.tag) {
        case TextFieldTypeStartDate: {
            self.selectedStartDate = datePicker.date;
            self.startDateField.text = [dateFormatter stringFromDate:datePicker.date];
        }
            break;
        case TextFieldTypeEndDate: {
            self.selectedEndDate = datePicker.date;
            self.endDateField.text = [dateFormatter stringFromDate:datePicker.date];
        }
            break;
        default:
            break;
    }
}

- (void)dateRangeForDatePicker:(UIDatePicker *)datePicker forPopoverViewController:(LGPopoverViewController *)popoverViewController {
    
    switch (self.currentTextField.tag) {
        case TextFieldTypeStartDate: {
            
            datePicker.minimumDate = [[NSDate alloc] initWithTimeIntervalSince1970:0];
            
            if (self.selectedEndDate) {         // если установлена конечная дата
                datePicker.maximumDate = _selectedEndDate;
            } else {
                datePicker.maximumDate = [NSDate date];
            }
        }
            break;
        case TextFieldTypeEndDate: {
            
            if (self.selectedStartDate) {         // если установлена начальная дата
                datePicker.minimumDate = _selectedStartDate;
            } else {
                datePicker.minimumDate = [[NSDate alloc] initWithTimeIntervalSince1970:0];
            }
            
            datePicker.maximumDate = [NSDate date];
            
        }
            break;
        default:
            break;
    }
}

- (NSString *)titleButtonForPopoverViewController:(LGPopoverViewController *)popoverViewController {
    
    NSArray *fields = @[_siteField, _personField, _startDateField, _endDateField];
    
    NSInteger sum = 0;
    
    for (UITextField *textField in fields) {
        
        if ([textField.text length] != 0) {
            ++sum;
        }
        
    }
    
    if (sum < 3) {
        return @"Дальше";
    } else {
        [self createRefreshButton];
        [_responseLabel removeFromSuperview];
//        _responseLabel.hidden = YES;
//        _applyButton.hidden = NO;
        return @"Применить";
    }
}

- (void)actionReturn:(UIButton *)button {
    
    [_popoverViewController dismissViewControllerAnimated:YES completion:^{
        
        NSArray *fields = @[_siteField, _personField, _startDateField, _endDateField];
        
        NSInteger currentIndex = [fields indexOfObject:_currentTextField];
        
        for (NSInteger i = 0, j = currentIndex + 1; i < fields.count; i++, j++) {
            
            j == fields.count ? j = 0 : j;
            
            if ([fields[j] text].length == 0) {
                [fields[j] becomeFirstResponder];
                break;
            }
            
            if (i == fields.count - 1) {
                [self actionRefresh:nil];
            }
        }
    }];
}

#pragma mark - Actions

- (void)actionRefresh:(id)sender {
    // Метод заполнения таблицы или графика
    
    [self requestStat];
}

#pragma mark - Segment Control

@end
