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
#import <PNChart/PNChart.h>

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
    UITextField *_currentTextField;
    NSDate *_selectedStartDate;
    NSDate *_selectedEndDate;
}

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) PNLineChart *lineChart;

@property (weak, nonatomic) IBOutlet UITextField *siteField;
@property (weak, nonatomic) IBOutlet UITextField *personField;
@property (weak, nonatomic) IBOutlet UITextField *startDateField;
@property (weak, nonatomic) IBOutlet UITextField *endDateField;

@property (weak, nonatomic) IBOutlet UILabel *responseLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalNumberLabel;

@property (weak, nonatomic) UIButton *applyButton;

@property (weak, nonatomic) LGPopoverViewController *popoverViewController;

@end

@implementation LGDailyStatsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (_multipleType != 1 && _multipleType != 2) {
        _multipleType = 1;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self changeInfoView];
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
             
             NSLog(@"JSON: %@", responseObject);
             
             if (responseObject) {
                 
                 _responseJSON = responseObject;
                 
                 switch (_multipleType) {
                     case MultipleTypeTable:
                         [self.tableView reloadData];
                         break;
                     case MultipleTypeChart:
                         [self loadChart];
                         break;
                     default:
                         break;
                 }
                 
                 [self setTotalNumber];
                 
             } else {
                 
                 [self alertActionWithTitle:@"Нет данных" andMessage:nil];
                 
             }
             
             NSLog(@"JSON: %@", _responseJSON);
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
             
             [self alertActionWithTitle:@"Сервер не отвечает" andMessage:@"Попробуйте позже"];
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
    
    NSString *string = [NSString stringWithFormat:@"stat/daily_stat?siteId=%ld&personId=%ld&start_date=%@&end_date=%@", siteID, personID, startDate, endDate];
    
    return [string encodeURLString];
}

#pragma mark - Chart Methods

- (void)loadChart {
    
    if (_responseJSON) {
        
        NSMutableArray *dates = [NSMutableArray array];
        NSMutableArray *numberOfNewPages = [NSMutableArray array];
        
        for (id obj in _responseJSON) {
            [dates addObject:[obj valueForKey:@"date"]];
        }
        
        for (id obj in _responseJSON) {
            [numberOfNewPages addObject:[obj valueForKey:@"numberOfNewPages"]];
        }
        
        [self.lineChart setXLabels:dates];
        
        // Line Chart No.1
        NSArray * data01Array = numberOfNewPages;
        PNLineChartData *data01 = [PNLineChartData new];
        data01.color = [UIColor blueColor];
        data01.itemCount = self.lineChart.xLabels.count;
        data01.getData = ^(NSUInteger index) {
            CGFloat yValue = [data01Array[index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        
        self.lineChart.showCoordinateAxis = YES;
        
        self.lineChart.chartData = @[data01];
        [self.lineChart strokeChart];
    }
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
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    
    // set textLabel
    cell.textLabel.text = [_responseJSON[indexPath.row] valueForKey:@"date"];
    
    // set detailTextLabel
    NSString *numberOfNewPages = [_responseJSON[indexPath.row] valueForKey:@"numberOfNewPages"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", numberOfNewPages];
    
    return cell;
}

#pragma mark - Methods

- (void)changeInfoView {
    
    NSLog(@"LGDailyViewController %d", _multipleType);
    
    switch (_multipleType) {
        case MultipleTypeTable: {
            [self createTableView];
        }
            break;
        case MultipleTypeChart: {
            [self createChart];
        }
            break;
        default:
            break;
    }
}

- (void)createTableView {
    [self.lineChart removeFromSuperview];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 245.0, SCREEN_WIDTH, 328)];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    self.tableView = tableView;
    
    [self.view addSubview:tableView];
}

- (void) createChart {
    [self.tableView removeFromSuperview];
    
    PNLineChart *lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 245.0, SCREEN_WIDTH, 328)];
    self.lineChart = lineChart;
    
    [self.view addSubview:lineChart];
    [self loadChart];
}

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
    _currentTextField = sender;
    
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

#pragma mark - Alert Methods

- (void)alertActionWithTitle:(NSString *)title andMessage:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"ОК"
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
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
    
    switch (_currentTextField.tag) {
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
    
    switch (_currentTextField.tag) {
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
    
    switch (_currentTextField.tag) {
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
    
    switch (_currentTextField.tag) {
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
    
    switch (_currentTextField.tag) {
        case TextFieldTypeStartDate: {
            _selectedStartDate = datePicker.date;
            self.startDateField.text = [dateFormatter stringFromDate:datePicker.date];
        }
            break;
        case TextFieldTypeEndDate: {
            _selectedEndDate = datePicker.date;
            self.endDateField.text = [dateFormatter stringFromDate:datePicker.date];
        }
            break;
        default:
            break;
    }
}

- (void)dateRangeForDatePicker:(UIDatePicker *)datePicker forPopoverViewController:(LGPopoverViewController *)popoverViewController {
    
    switch (_currentTextField.tag) {
        case TextFieldTypeStartDate: {
            
            datePicker.minimumDate = [[NSDate alloc] initWithTimeIntervalSince1970:0];
            
            if (_selectedEndDate) {         // если установлена конечная дата
                datePicker.maximumDate = _selectedEndDate;
            } else {
                datePicker.maximumDate = [NSDate date];
            }
        }
            break;
        case TextFieldTypeEndDate: {
            
            if (_selectedStartDate) {         // если установлена начальная дата
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
