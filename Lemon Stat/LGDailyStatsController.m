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

#import "LGDailyRow.h"
#import "LGSection.h"

#import "NSString+Request.h"

typedef enum {
    TextFieldTypeSites = 1,
    TextFieldTypePersons = 2,
    TextFieldTypeStartDate = 3,
    TextFieldTypeEndDate = 4
} TextFieldType;

@interface LGDailyStatsController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, LGPopoverViewControllerDelegate> {
    UITextField *_currentTextField;
    NSDate *_selectedStartDate;
    NSDate *_selectedEndDate;
}

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UIScrollView *lineChart;

@property (weak, nonatomic) IBOutlet UITextField *siteField;
@property (weak, nonatomic) IBOutlet UITextField *personField;
@property (weak, nonatomic) IBOutlet UITextField *startDateField;
@property (weak, nonatomic) IBOutlet UITextField *endDateField;

@property (weak, nonatomic) IBOutlet UILabel *responseLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalNumberLabel;

@property (weak, nonatomic) UIButton *applyButton;

@property (weak, nonatomic) LGPopoverViewController *popoverViewController;

@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSArray<LGDailyRow *> *dailyRows;

@property (strong, nonatomic) NSOperation *currentOperation;

@end

@implementation LGDailyStatsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (_multipleType != MultipleTypeTable && _multipleType != MultipleTypeChart) {
        _multipleType = MultipleTypeTable;
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
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *urlString = [self stringForRequest];
    
    [manager GET:urlString
      parameters:nil
        progress:nil
         success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
             
             NSLog(@"responseObject JSON: %@", responseObject);
             
             NSMutableArray *dailyRows = [NSMutableArray array];
             
             if (responseObject) {
                 
                 for (id obj in responseObject) {
                     LGDailyRow *dailyRow = [[LGDailyRow alloc] init];
                     dailyRow.date = [obj valueForKey:@"date"];
                     dailyRow.numberOfNewPages = [[obj valueForKey:@"numberOfNewPages"] stringValue];
                     [dailyRows addObject:dailyRow];
                 }
                 self.dailyRows = dailyRows;
                 
                 [self setTotalNumber];
                 
             } else {
                 
                 _dailyRows = nil;
                 
                 [self alertActionWithTitle:@"Нет данных" andMessage:nil];
                 {
                 /************* Убрать этот кусок кода *************/
                 // фейковые данные
                 NSArray *responseJSON = @[@{@"date" : @"2016-11-29", @"numberOfNewPages" : @57},
                                           @{@"date" : @"2016-11-30", @"numberOfNewPages" : @94},
                                           @{@"date" : @"2016-12-1", @"numberOfNewPages" : @23},
                                           @{@"date" : @"2016-12-2", @"numberOfNewPages" : @94},
                                           @{@"date" : @"2016-12-3", @"numberOfNewPages" : @121},
                                           @{@"date" : @"2016-12-4", @"numberOfNewPages" : @34},
                                           @{@"date" : @"2016-12-5", @"numberOfNewPages" : @65},
                                           @{@"date" : @"2016-12-6", @"numberOfNewPages" : @69},
                                           @{@"date" : @"2016-12-7", @"numberOfNewPages" : @11},
                                           @{@"date" : @"2016-12-8", @"numberOfNewPages" : @26},
                                           @{@"date" : @"2016-12-9", @"numberOfNewPages" : @30},
                                           @{@"date" : @"2016-12-10", @"numberOfNewPages" : @30},
                                           @{@"date" : @"2016-12-11", @"numberOfNewPages" : @57},
                                           @{@"date" : @"2016-12-12", @"numberOfNewPages" : @94},
                                           @{@"date" : @"2016-12-13", @"numberOfNewPages" : @23},
                                           @{@"date" : @"2016-12-14", @"numberOfNewPages" : @94},
                                           @{@"date" : @"2016-12-15", @"numberOfNewPages" : @121},
                                           @{@"date" : @"2016-12-16", @"numberOfNewPages" : @34},
                                           @{@"date" : @"2016-12-17", @"numberOfNewPages" : @65},
                                           @{@"date" : @"2016-12-18", @"numberOfNewPages" : @69},
                                           @{@"date" : @"2016-12-19", @"numberOfNewPages" : @11},
                                           @{@"date" : @"2016-12-20", @"numberOfNewPages" : @26},
                                           @{@"date" : @"2016-12-21", @"numberOfNewPages" : @30},
                                           @{@"date" : @"2016-12-22", @"numberOfNewPages" : @30},
                                           @{@"date" : @"2016-12-23", @"numberOfNewPages" : @94},
                                           @{@"date" : @"2016-12-24", @"numberOfNewPages" : @23},
                                           @{@"date" : @"2016-12-25", @"numberOfNewPages" : @94},
                                           @{@"date" : @"2016-12-26", @"numberOfNewPages" : @121},
                                           @{@"date" : @"2016-12-27", @"numberOfNewPages" : @34},
                                           @{@"date" : @"2016-12-28", @"numberOfNewPages" : @65},
                                           @{@"date" : @"2016-12-29", @"numberOfNewPages" : @69},
                                           @{@"date" : @"2016-12-30", @"numberOfNewPages" : @11},
                                           @{@"date" : @"2017-01-1", @"numberOfNewPages" : @26},
                                           @{@"date" : @"2017-01-2", @"numberOfNewPages" : @30},
                                           @{@"date" : @"2017-01-23", @"numberOfNewPages" : @30}];
                 
                 for (id obj in responseJSON) {    // заменить _responseJSON на responseObject
                     LGDailyRow *dailyRow = [[LGDailyRow alloc] init];
                     dailyRow.date = [obj valueForKey:@"date"];
                     dailyRow.numberOfNewPages = [[obj valueForKey:@"numberOfNewPages"] stringValue];
                     [dailyRows addObject:dailyRow];
                 }
                 self.dailyRows = dailyRows;
                     
                 [self setTotalNumber];
                 
                 NSLog(@"JSON: %@", responseJSON);
                 /**************************************************/
                 }
             }
             
             switch (_multipleType) {
                 case MultipleTypeTable:
                     [self generateSectionsInBackgroundFromArray:dailyRows];
                     break;
                 case MultipleTypeChart:
                     [self reloadChart];
                     break;
             }
             
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

- (void)generateSectionsInBackgroundFromArray:(NSArray *)array {
    
    if (array.count > 0) {
        
        [self.currentOperation cancel];
        
        __weak LGDailyStatsController *weakSelf = self;
        
        self.currentOperation = [NSBlockOperation blockOperationWithBlock:^{
            
            NSArray *sectionsArray = [self generateSectionsFromArray:array];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                weakSelf.sections = sectionsArray;
                [weakSelf.tableView reloadData];
                
                self.currentOperation = nil;
            });
        }];
        
        [self.currentOperation start];
        
    } else {
        
        [self.tableView reloadData];
        
    }
}

- (NSArray *)generateSectionsFromArray:(NSArray *)array {
    
    NSString *currentYear = 0;
    
    NSMutableArray *sectionsArray = [NSMutableArray array];
    
    for (LGDailyRow *row in array) {
        
        NSString *year = [row.date substringToIndex:7];
        
        LGSection *section = nil;
        
        if (![currentYear isEqualToString:year]) {
            
            section = [[LGSection alloc] init];
            section.name = year;
            section.rows = [NSMutableArray array];
            
            currentYear = year;
            
            [sectionsArray addObject:section];
            
        } else {
            
            section = [sectionsArray lastObject];
            
        }
        
        [section.rows addObject:row];
    
    }
    
    return sectionsArray;
}

- (void)reloadChart {
    
    [self.lineChart removeFromSuperview];
    
    UIScrollView *scrollView;
    PNLineChart *lineChart;
    
    if (_dailyRows) {
        
        NSMutableArray *dates = [NSMutableArray array];
        NSMutableArray *numberOfNewPages = [NSMutableArray array];
        
        for (LGDailyRow *row in _dailyRows) {
            [dates addObject:row.date];
            [numberOfNewPages addObject:row.numberOfNewPages];
        }
        
        NSInteger valueWidth = 60;
        NSInteger maxValuesOnScreen = 6;
        NSInteger contentWidth;
        
        if (dates.count > maxValuesOnScreen) {
            contentWidth = valueWidth * (dates.count + 1);
        } else {
            contentWidth = SCREEN_WIDTH;
        }
        
        // create ScrollView
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 253.0, SCREEN_WIDTH, 328)];
        scrollView.contentSize = CGSizeMake(contentWidth, 328);
        
        // create Chart
        lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, contentWidth, 328)];
        lineChart.showCoordinateAxis = YES;
        
        
        if (dates.count > maxValuesOnScreen) {
            [lineChart setXLabels:dates withWidth:valueWidth];
        } else {
            [lineChart setXLabels:dates];
        }
        
        // Line Chart No.1
        NSArray * data01Array = numberOfNewPages;
        PNLineChartData *data01 = [PNLineChartData new];
        data01.showPointLabel = YES;
        data01.inflexionPointStyle = PNLineChartPointStyleCircle;
        data01.pointLabelFont = [UIFont systemFontOfSize:12];
        data01.color = [UIColor blueColor];
        data01.itemCount = lineChart.xLabels.count;
        data01.getData = ^(NSUInteger index) {
            CGFloat yValue = [data01Array[index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        
        lineChart.chartData = @[data01];
        
    } else {
        
        // create ScrollView
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 253.0, SCREEN_WIDTH, 328)];
        scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 328);
        
        // create Chart
        lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 328)];
        lineChart.showCoordinateAxis = YES;
    }
    
    [lineChart strokeChart];
    
    [self.view addSubview:scrollView];
    [scrollView addSubview:lineChart];
    
    self.lineChart = scrollView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sections[section] rows].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sections[section] name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"DateCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    
    // Configure the cell...
    
    LGDailyRow *row = [self.sections[indexPath.section] rows][indexPath.row];
    
    // set textLabel
    cell.textLabel.text = row.date;
    
    // set detailTextLabel
    cell.detailTextLabel.text = row.numberOfNewPages;
    cell.detailTextLabel.textColor = [UIColor blueColor];
    
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
    }
}

- (void)createTableView {
    [self.lineChart removeFromSuperview];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 253.0, SCREEN_WIDTH, 328)];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    self.tableView = tableView;
    
    [self.view addSubview:tableView];
}

- (void) createChart {
    [self.tableView removeFromSuperview];
    [self.lineChart removeFromSuperview];
    
    [self reloadChart];
}

- (void)setTotalNumber {
    
    NSInteger totalNumber = 0;
    
    for (LGDailyRow *row in _dailyRows) {
        totalNumber += [row.numberOfNewPages integerValue];
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

- (void)nextField {
    
    NSArray *fields = @[_siteField, _personField, _startDateField, _endDateField];
    
    NSInteger currentIndex = [fields indexOfObject:_currentTextField];
    
    for (NSInteger i = 0, j = currentIndex + 1; i < fields.count; i++, j++) {
        
        j == fields.count ? j = 0 : j;
        
        if ([fields[j] text].length == 0) {
            [fields[j] becomeFirstResponder];
            break;
        }
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

- (NSArray<NSString *> *)arrayForPopoverViewController:(LGPopoverViewController *)popoverViewController {
    
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

- (UIColor *)colorBackgroundForReturnButton {
    return [UIColor blueColor];
}

- (UIColor *)colorTextForReturnButton{
    return [UIColor whiteColor];
}

- (void)disappearedPopoverViewController:(LGPopoverViewController *)popoverViewController {
    
    
    if (_siteField.text.length > 0 &&
        _personField.text.length > 0 &&
        _startDateField.text.length > 0 &&
        _endDateField.text.length > 0 ) {
        
        [self actionRefresh:nil];
        
    }
}

- (void)actionReturn:(UIButton *)button {
    
    [_popoverViewController dismissViewControllerAnimated:YES
                                               completion:^{
                                                   [self nextField];
                                               }];
}

#pragma mark - Actions

- (void)actionRefresh:(id)sender {
    // Метод заполнения таблицы или графика
    
    [self requestStat];
}

@end
