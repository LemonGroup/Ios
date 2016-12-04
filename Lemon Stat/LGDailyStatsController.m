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

@interface LGDailyStatsController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, LGPopoverViewControllerDelegate, PNChartDelegate> {
    UITextField *_currentTextField;
    NSDate *_selectedStartDate;
    NSDate *_selectedEndDate;
}

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UIScrollView *scrollChartView;
@property (weak, nonatomic) PNLineChart *lineChart;

@property (weak, nonatomic) IBOutlet UITextField *siteField;
@property (weak, nonatomic) IBOutlet UITextField *personField;
@property (weak, nonatomic) IBOutlet UITextField *startDateField;
@property (weak, nonatomic) IBOutlet UITextField *endDateField;

@property (weak, nonatomic) IBOutlet UILabel *responseLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalNumberLabel;

@property (weak, nonatomic) UIButton *applyButton;
@property (weak, nonatomic) UIButton *refreshButton;

@property (weak, nonatomic) LGPopoverViewController *popoverViewController;

@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSArray<LGDailyRow *> *dailyRows;

@property (strong, nonatomic) NSOperation *currentOperation;

@property (weak, nonatomic) UIActivityIndicatorView *activityIndecatorView;

@property (strong, nonatomic) NSArray *months;

@property (weak, nonatomic) UILabel *currentPoinLabel;

@end

@implementation LGDailyStatsController

/************* Убрать этот кусок кода *************/
#pragma mark - Fake Method
- (void)fakeDataMethod{
    // фейковые данные
    
    NSArray *responseJSON = @[@{@"date" : @"2016-11-29", @"numberOfNewPages" : @57},
                              @{@"date" : @"2016-11-30", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-01", @"numberOfNewPages" : @23},
                              @{@"date" : @"2016-12-02", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-03", @"numberOfNewPages" : @121},
                              @{@"date" : @"2016-12-04", @"numberOfNewPages" : @34},
                              @{@"date" : @"2016-12-05", @"numberOfNewPages" : @65},
                              @{@"date" : @"2016-12-06", @"numberOfNewPages" : @69},
                              @{@"date" : @"2016-12-07", @"numberOfNewPages" : @11},
                              @{@"date" : @"2016-12-08", @"numberOfNewPages" : @26},
                              @{@"date" : @"2016-12-09", @"numberOfNewPages" : @30},
                              @{@"date" : @"2016-12-10", @"numberOfNewPages" : @30},
                              @{@"date" : @"2016-12-11", @"numberOfNewPages" : @57},
                              @{@"date" : @"2016-12-12", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-13", @"numberOfNewPages" : @23},
                              @{@"date" : @"2016-12-14", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-15", @"numberOfNewPages" : @121},
                              @{@"date" : @"2016-12-16", @"numberOfNewPages" : @34},
                              @{@"date" : @"2016-12-17", @"numberOfNewPages" : @65},
                              @{@"date" : @"2016-12-18", @"numberOfNewPages" : @69}
                              ,
                              @{@"date" : @"2016-11-29", @"numberOfNewPages" : @57},
                              @{@"date" : @"2016-11-30", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-01", @"numberOfNewPages" : @23},
                              @{@"date" : @"2016-12-02", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-03", @"numberOfNewPages" : @121},
                              @{@"date" : @"2016-12-04", @"numberOfNewPages" : @34},
                              @{@"date" : @"2016-12-05", @"numberOfNewPages" : @65},
                              @{@"date" : @"2016-12-06", @"numberOfNewPages" : @69},
                              @{@"date" : @"2016-12-07", @"numberOfNewPages" : @11},
                              @{@"date" : @"2016-12-08", @"numberOfNewPages" : @26},
                              @{@"date" : @"2016-12-09", @"numberOfNewPages" : @30},
                              @{@"date" : @"2016-12-10", @"numberOfNewPages" : @30},
                              @{@"date" : @"2016-12-11", @"numberOfNewPages" : @57},
                              @{@"date" : @"2016-12-12", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-13", @"numberOfNewPages" : @23},
                              @{@"date" : @"2016-12-14", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-15", @"numberOfNewPages" : @121},
                              @{@"date" : @"2016-12-16", @"numberOfNewPages" : @34},
                              @{@"date" : @"2016-12-17", @"numberOfNewPages" : @65},
                              @{@"date" : @"2016-12-18", @"numberOfNewPages" : @69}
                              ,
                              @{@"date" : @"2016-11-29", @"numberOfNewPages" : @57},
                              @{@"date" : @"2016-11-30", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-01", @"numberOfNewPages" : @23},
                              @{@"date" : @"2016-12-02", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-03", @"numberOfNewPages" : @121},
                              @{@"date" : @"2016-12-04", @"numberOfNewPages" : @34},
                              @{@"date" : @"2016-12-05", @"numberOfNewPages" : @65},
                              @{@"date" : @"2016-12-06", @"numberOfNewPages" : @69},
                              @{@"date" : @"2016-12-07", @"numberOfNewPages" : @11},
                              @{@"date" : @"2016-12-08", @"numberOfNewPages" : @26},
                              @{@"date" : @"2016-12-09", @"numberOfNewPages" : @30},
                              @{@"date" : @"2016-12-10", @"numberOfNewPages" : @30},
                              @{@"date" : @"2016-12-11", @"numberOfNewPages" : @57},
                              @{@"date" : @"2016-12-12", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-13", @"numberOfNewPages" : @23},
                              @{@"date" : @"2016-12-14", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-15", @"numberOfNewPages" : @121},
                              @{@"date" : @"2016-12-16", @"numberOfNewPages" : @34},
                              @{@"date" : @"2016-12-17", @"numberOfNewPages" : @65},
                              @{@"date" : @"2016-12-18", @"numberOfNewPages" : @69}
                              ,
                              @{@"date" : @"2016-11-29", @"numberOfNewPages" : @57},
                              @{@"date" : @"2016-11-30", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-01", @"numberOfNewPages" : @23},
                              @{@"date" : @"2016-12-02", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-03", @"numberOfNewPages" : @121},
                              @{@"date" : @"2016-12-04", @"numberOfNewPages" : @34},
                              @{@"date" : @"2016-12-05", @"numberOfNewPages" : @65},
                              @{@"date" : @"2016-12-06", @"numberOfNewPages" : @69},
                              @{@"date" : @"2016-12-07", @"numberOfNewPages" : @11},
                              @{@"date" : @"2016-12-08", @"numberOfNewPages" : @26},
                              @{@"date" : @"2016-12-09", @"numberOfNewPages" : @30},
                              @{@"date" : @"2016-12-10", @"numberOfNewPages" : @30},
                              @{@"date" : @"2016-12-11", @"numberOfNewPages" : @57},
                              @{@"date" : @"2016-12-12", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-13", @"numberOfNewPages" : @23},
                              @{@"date" : @"2016-12-14", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-15", @"numberOfNewPages" : @121},
                              @{@"date" : @"2016-12-16", @"numberOfNewPages" : @34},
                              @{@"date" : @"2016-12-17", @"numberOfNewPages" : @65},
                              @{@"date" : @"2016-12-18", @"numberOfNewPages" : @69}
                              ,
                              @{@"date" : @"2016-11-29", @"numberOfNewPages" : @57},
                              @{@"date" : @"2016-11-30", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-01", @"numberOfNewPages" : @23},
                              @{@"date" : @"2016-12-02", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-03", @"numberOfNewPages" : @121},
                              @{@"date" : @"2016-12-04", @"numberOfNewPages" : @34},
                              @{@"date" : @"2016-12-05", @"numberOfNewPages" : @65},
                              @{@"date" : @"2016-12-06", @"numberOfNewPages" : @69},
                              @{@"date" : @"2016-12-07", @"numberOfNewPages" : @11},
                              @{@"date" : @"2016-12-08", @"numberOfNewPages" : @26},
                              @{@"date" : @"2016-12-09", @"numberOfNewPages" : @30},
                              @{@"date" : @"2016-12-10", @"numberOfNewPages" : @30},
                              @{@"date" : @"2016-12-11", @"numberOfNewPages" : @57},
                              @{@"date" : @"2016-12-12", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-13", @"numberOfNewPages" : @23},
                              @{@"date" : @"2016-12-14", @"numberOfNewPages" : @94},
                              @{@"date" : @"2016-12-15", @"numberOfNewPages" : @121},
                              @{@"date" : @"2016-12-16", @"numberOfNewPages" : @34},
                              @{@"date" : @"2016-12-17", @"numberOfNewPages" : @65},
                              @{@"date" : @"2016-12-18", @"numberOfNewPages" : @69}];
    
    [self createRowsUsingAnJSONArray:responseJSON];
    
    [self setTotalNumber];
    
    switch (_multipleType) {
        case MultipleTypeTable:
            [self generateSectionsInBackgroundFromArray:_dailyRows];
            break;
        case MultipleTypeChart:
            [self reloadChart];
            break;
    }
    
    NSLog(@"JSON: %@", responseJSON);
}
#pragma mark -
/**************************************************/

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (_multipleType != MultipleTypeTable && _multipleType != MultipleTypeChart) {
        _multipleType = MultipleTypeTable;
    }
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = self.view.center;
    [self.view addSubview:activityIndicatorView];
    self.activityIndecatorView = activityIndicatorView;
    
    self.months = @[@"Январь", @"Февраль", @"Март", @"Апрель",
                    @"Май", @"Июнь", @"Июль", @"Август",
                    @"Сентябрь", @"Октябрь", @"Ноябрь", @"Декабрь"];
    
    /************* Убрать этот кусок кода *************/
    [self fakeDataMethod];
    /**************************************************/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self changeInfoView];
}

#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        if (_lineChart) {
            [self reloadChart];
        }
        
    }
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     
                                 }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - Requests Methods

- (void)requestStat {
    
    [_activityIndecatorView startAnimating];
    
    extern NSString *gToken;
    extern NSURL *gBaseURL;
    extern NSString *gContentType;
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithBaseURL:gBaseURL];
    [manager.requestSerializer setValue:gToken forHTTPHeaderField:@"Auth-Token"];
    [manager.requestSerializer setValue:gContentType forHTTPHeaderField:@"Content-Type"];
    
    NSString *urlString = [self stringForRequest];
    
    [manager GET:urlString
      parameters:nil
        progress:nil
         success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
             
             NSLog(@"responseObject JSON: %@", responseObject);
             
             if (responseObject) {
                 
                 [self createRowsUsingAnJSONArray:responseObject];
                 [self setTotalNumber];
                 
             } else {
                 
                 _dailyRows = nil;
                 _sections = nil;
                 
                 [self alertActionWithTitle:@"Нет данных" andMessage:nil];
                 
                 /************* Убрать этот кусок кода *************/
                 [self fakeDataMethod];
                 /**************************************************/
             }
             
             switch (_multipleType) {
                 case MultipleTypeTable:
                     [self generateSectionsInBackgroundFromArray:_dailyRows];
                     break;
                 case MultipleTypeChart:
                     [self reloadChart];
                     break;
             }
             
             [_activityIndecatorView stopAnimating];
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             
             switch (error.code) {
                 case -1001:
                     [self alertActionWithTitle:@"Сервер не отвечает" andMessage:@"Время ожидания от сервера истекло, попробуйте позже"];
                     break;
                 default:
                     [self alertActionWithTitle:@"Сервер не отвечает" andMessage:nil];
                     break;
             }
             
             [_activityIndecatorView stopAnimating];
             
             NSLog(@"%ld", error.code);
             NSLog(@"Error: %@", error);
             
             /************* Убрать этот кусок кода *************/
             [self fakeDataMethod];
             /**************************************************/
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

- (void)reloadChart {
    
    [self.tableView removeFromSuperview];
    [self.scrollChartView removeFromSuperview];
    
    UIScrollView *scrollView;
    PNLineChart *lineChart;
    
    CGRect contentFrame = [self contentFrame];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"ru"];
    [dateFormatter setDateFormat:@"d MMM yy"];
    
    if (_dailyRows) {
        
        NSMutableArray *dates = [NSMutableArray array];
        NSMutableArray *numberOfNewPages = [NSMutableArray array];
        
        for (LGDailyRow *row in _dailyRows) {
            [dates addObject:[dateFormatter stringFromDate:row.date]];
            [numberOfNewPages addObject:row.numberOfNewPages];
        }
        
        NSInteger contentWidth;
        NSInteger valueWidth = 20;
        NSInteger maxValuesOnScreen = CGRectGetWidth(contentFrame) / valueWidth;
        
        
        if (dates.count > maxValuesOnScreen) {
            contentWidth = valueWidth * dates.count;
        } else {
            contentWidth = CGRectGetWidth(contentFrame);
        }
        
        // create ScrollView
        scrollView = [[UIScrollView alloc] initWithFrame:contentFrame];
        scrollView.contentSize = CGSizeMake(contentWidth, CGRectGetHeight(contentFrame));
        
        // create Chart
        lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, contentWidth, CGRectGetHeight(contentFrame))];
        lineChart.showCoordinateAxis = YES;
        lineChart.delegate = self;
        lineChart.chartMarginLeft = 30;
        lineChart.chartMarginRight = 0;
        lineChart.chartCavanHeight = CGRectGetHeight(contentFrame) - 100;
        
        [lineChart setXLabels:dates];
        
        // Line Chart No.1
        NSArray * data01Array = numberOfNewPages;
        PNLineChartData *data01 = [PNLineChartData new];
        data01.showPointLabel = NO;
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
        scrollView = [[UIScrollView alloc] initWithFrame:contentFrame];
        scrollView.contentSize = contentFrame.size;
        
        // create Chart
        lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame))];
        lineChart.showCoordinateAxis = YES;
    }
    
    NSLog(@"pathPoints = %@", lineChart.pathPoints);
    
    [lineChart strokeChart];
    
    [self.view insertSubview:scrollView belowSubview:_activityIndecatorView];
    [scrollView addSubview:lineChart];
    
    self.scrollChartView = scrollView;
    self.lineChart = lineChart;
}

#pragma mark - PNChartDelegate

- (void)userClickedOnLineKeyPoint:(CGPoint)point lineIndex:(NSInteger)lineIndex pointIndex:(NSInteger)pointIndex {
    
    if (_currentPoinLabel) {
        
        if ((CGRectGetMidX(_currentPoinLabel.frame) > point.x + 10) ||
            (CGRectGetMidX(_currentPoinLabel.frame) < point.x - 10)) {
            
            [_currentPoinLabel removeFromSuperview];
            _currentPoinLabel = [self createPointLabelWithTitel:_dailyRows[pointIndex].numberOfNewPages
                                                      andCenter:[[_lineChart.pathPoints firstObject][pointIndex] CGPointValue]];
        }
    
    } else {
        
        _currentPoinLabel = [self createPointLabelWithTitel:_dailyRows[pointIndex].numberOfNewPages
                                                  andCenter:[[_lineChart.pathPoints firstObject][pointIndex] CGPointValue]];
    }
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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"ru"];
    [dateFormatter setDateFormat:@"d MMM"];
    
    cell.textLabel.text = [dateFormatter stringFromDate:row.date];
    
    // set detailTextLabel
    cell.detailTextLabel.text = row.numberOfNewPages;
    cell.detailTextLabel.textColor = [UIColor blueColor];
    
    return cell;
}

#pragma mark - Methods

- (void)createRowsUsingAnJSONArray:(NSArray *)responseJSON {
    
    NSMutableArray *dailyRows = [NSMutableArray array];
    
    for (id obj in responseJSON) {
        LGDailyRow *dailyRow = [[LGDailyRow alloc] init];
        
        // create date from string
        NSString *dateString = [obj valueForKey:@"date"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *dateFromString = [[NSDate alloc] init];
        dateFromString = [dateFormatter dateFromString:dateString];
        
        dailyRow.numberOfNewPages = [[obj valueForKey:@"numberOfNewPages"] stringValue];
        dailyRow.date = dateFromString;
        
        [dailyRows addObject:dailyRow];
        
    }
    self.dailyRows = dailyRows;
}

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
    [self.scrollChartView removeFromSuperview];
    
    if (!_sections) {
        [self generateSectionsInBackgroundFromArray:_dailyRows];
    }
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:[self contentFrame]];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.tableView = tableView;
    
    [self.view insertSubview:tableView belowSubview:_activityIndecatorView];
    
    // create constraints
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:tableView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_responseLabel
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:8];
    
    NSLayoutConstraint *bottom =  [NSLayoutConstraint constraintWithItem:tableView
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_totalNumberLabel
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0
                                                                constant:-8];
    
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:tableView
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.view
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1.0
                                                             constant:0];
    
    NSLayoutConstraint *rigth = [NSLayoutConstraint constraintWithItem:tableView
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1.0
                                                              constant:0];
    
    [tableView.superview addConstraints:@[top, bottom, left, rigth]];
}

- (void) createChart {
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
        button.frame = CGRectMake(0, 0, 100, CGRectGetHeight(_responseLabel.frame));
        button.center = _responseLabel.center;
        
        _applyButton = button;
        
        [self.view addSubview:button];
        self.refreshButton = button;
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

- (void)generateSectionsInBackgroundFromArray:(NSArray *)array {
    
    if (array) {
        
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
    
    //NSString *currentYear;
    NSInteger currentMonth = 0;
    
    NSMutableArray *sectionsArray = [NSMutableArray array];
    
    for (LGDailyRow *row in array) {
        
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:row.date]; // Get necessary date components
        
        NSInteger month = [components month];
        
        LGSection *section = nil;
        
        if (currentMonth != month) {
            
            section = [[LGSection alloc] init];
            
            section.name = [NSString stringWithFormat:@"%@ %ld", _months[month - 1], [components year]];
            
            // set rows
            section.rows = [NSMutableArray array];
            
            currentMonth = month;
            
            [sectionsArray addObject:section];
            
        } else {
            
            section = [sectionsArray lastObject];
        }
        
        [section.rows addObject:row];
    }
    
    return sectionsArray;
}

- (CGRect)contentFrame {
    
    CGFloat space = 8;
    CGFloat y;
    CGFloat heigth;
    
    if (_responseLabel) {
        y = CGRectGetMaxY(_responseLabel.frame) + space;
    } else if (_refreshButton) {
        y = CGRectGetMaxY(_refreshButton.frame) + space;
    }
    
    heigth = CGRectGetMinY(_totalNumberLabel.frame) - y - space;
    
    return CGRectMake(0, y, SCREEN_WIDTH, heigth);
}

- (UILabel *)createPointLabelWithTitel:(NSString *)title andCenter:(CGPoint)center {
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor colorWithWhite:1 alpha:0.85];
    label.font = [UIFont systemFontOfSize:20];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    [label sizeToFit];
    label.center = center;
    label.textColor = [UIColor blackColor];
        
    [_lineChart addSubview:label];
    
    return label;
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
    dateFormatter.locale = datePicker.locale;
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
