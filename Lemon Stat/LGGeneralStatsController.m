//
//  GeneralStatsController.m
//  Lemon Stat
//
//  Created by decidion on 09.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGGeneralStatsController.h"

#import "LGPopoverViewController.h"

#import <AFNetworking/AFNetworking.h>
#import <PNChart/PNChart.h>

#import "LGSiteListSingleton.h"
#import "LGSite.h"

#import "LGGeneralRow.h"

#import "NSString+Request.h"

@interface LGGeneralStatsController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, LGPopoverViewControllerDelegate> {
}

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UIScrollView *barChart;

@property (weak, nonatomic) LGPopoverViewController *popoverViewController;

@property (weak, nonatomic) IBOutlet UITextField *siteLabel;

//@property (strong, nonatomic) NSArray *persons;
//@property (strong, nonatomic) NSArray *numberOfMentions;

@property (strong, nonatomic) NSArray<LGGeneralRow *> *generalRows;

@end

@implementation LGGeneralStatsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _multipleType = MultipleTypeTable;
}

- (void)viewDidAppear:(BOOL)animated {
    [self changeInfoView];
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
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *requestString = [self requestString];
    
    if (requestString) {
        
        [manager GET:requestString
          parameters:nil
            progress:^(NSProgress * _Nonnull downloadProgress) {
                
            }
             success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
                 
                 NSLog(@"responseObject JSON: %@", responseObject);
                 
                 if (responseObject) {
                     
                     NSMutableArray *generalRows = [NSMutableArray array];
                     
                     for (id obj in responseObject) {
                         LGGeneralRow *generalRow = [[LGGeneralRow alloc] init];
                         generalRow.person = [obj valueForKey:@"person"];
                         generalRow.numberOfMentions = [[obj valueForKey:@"numberOfMentions"] stringValue];
                         [generalRows addObject:generalRow];
                     }
                     self.generalRows = generalRows;
                     
                     // сортировка persons
                     [generalRows sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                         return [[obj1 person] compare:[obj2 person]];
                     }];
                     
                 } else {
                     
                     _generalRows = nil;
                     
                     [self alertActionWithTitle:@"Нет данных" andMessage:nil];
                     {
                     /************* Убрать этот кусок кода *************/
                     // фейковые данные
                     NSArray *responseJSON = @[@{@"numberOfMentions" : @10, @"person" : @"Путин"},
                                               @{@"numberOfMentions" : @232, @"person" : @"Навальный"},
                                               @{@"numberOfMentions" : @66, @"person" : @"Медведев"},
                                               @{@"numberOfMentions" : @1, @"person" : @"Меркель"},
                                               @{@"numberOfMentions" : @23, @"person" : @"Лукашенко"},
                                               @{@"numberOfMentions" : @112, @"person" : @"Саакашвилли"},
                                               @{@"numberOfMentions" : @34, @"person" : @"Обама"},
                                               @{@"numberOfMentions" : @54, @"person" : @"Трамп"},
                                               @{@"numberOfMentions" : @99, @"person" : @"Клинтон"},
                                               @{@"numberOfMentions" : @150, @"person" : @"Сарксян"},
                                               @{@"numberOfMentions" : @34, @"person" : @"Жириновский"},
                                               @{@"numberOfMentions" : @123, @"person" : @"Зюганов"},
                                               @{@"numberOfMentions" : @12, @"person" : @"Миронов"},
                                               @{@"numberOfMentions" : @199, @"person" : @"Олландо"},
                                               @{@"numberOfMentions" : @54, @"person" : @"Черчель"},
                                               @{@"numberOfMentions" : @74, @"person" : @"Мандела"},
                                               @{@"numberOfMentions" : @74, @"person" : @"Наполеон"},
                                               @{@"numberOfMentions" : @75, @"person" : @"Гитлер"}
                                               ];
                     
                     NSMutableArray *generalRows = [NSMutableArray array];
                     
                     for (id obj in responseJSON) {
                         LGGeneralRow *generalRow = [[LGGeneralRow alloc] init];
                         generalRow.person = [obj valueForKey:@"person"];
                         generalRow.numberOfMentions = [[obj valueForKey:@"numberOfMentions"] stringValue];
                         [generalRows addObject:generalRow];
                     }
                     self.generalRows = generalRows;
                     
                     // сортировка persons
                     [generalRows sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                         return [[obj1 person] compare:[obj2 person]];
                     }];
                     
                     NSLog(@"JSON: %@", responseJSON);
                     /**************************************************/
                     }
                 }
                 
                 switch (_multipleType) {
                     case MultipleTypeTable:
                         [self.tableView reloadData];
                         break;
                     case MultipleTypeChart:
                         [self reloadChart];
                         break;
                 }
             }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 NSLog(@"Error: %@", error);
                 
                 [self alertActionWithTitle:@"Сервер не отвечает" andMessage:@"Попробуйте позже"];
                 {
                 /************* Убрать этот кусок кода *************/
                 // фейковые данные
                 NSArray *responseJSON = @[@{@"numberOfMentions" : @10, @"person" : @"Путин"},
                                           @{@"numberOfMentions" : @232, @"person" : @"Навальный"},
                                           @{@"numberOfMentions" : @66, @"person" : @"Медведев"},
                                           @{@"numberOfMentions" : @1, @"person" : @"Меркель"},
                                           @{@"numberOfMentions" : @23, @"person" : @"Лукашенко"},
                                           @{@"numberOfMentions" : @112, @"person" : @"Саакашвилли"},
                                           @{@"numberOfMentions" : @34, @"person" : @"Обама"},
                                           @{@"numberOfMentions" : @54, @"person" : @"Трамп"},
                                           @{@"numberOfMentions" : @99, @"person" : @"Клинтон"},
                                           @{@"numberOfMentions" : @150, @"person" : @"Сарксян"},
                                           @{@"numberOfMentions" : @34, @"person" : @"Жириновский"},
                                           @{@"numberOfMentions" : @123, @"person" : @"Зюганов"},
                                           @{@"numberOfMentions" : @12, @"person" : @"Миронов"},
                                           @{@"numberOfMentions" : @199, @"person" : @"Олландо"},
                                           @{@"numberOfMentions" : @54, @"person" : @"Черчель"},
                                           @{@"numberOfMentions" : @74, @"person" : @"Мандела"},
                                           @{@"numberOfMentions" : @74, @"person" : @"Наполеон"},
                                           @{@"numberOfMentions" : @75, @"person" : @"Гитлер"}
                                           ];
                     
                 NSMutableArray *generalRows = [NSMutableArray array];
                 
                 for (id obj in responseJSON) {
                     LGGeneralRow *generalRow = [[LGGeneralRow alloc] init];
                     generalRow.person = [obj valueForKey:@"person"];
                     generalRow.numberOfMentions = [[obj valueForKey:@"numberOfMentions"] stringValue];
                     [generalRows addObject:generalRow];
                 }
                 self.generalRows = generalRows;
                 
                 // сортировка persons
                 [generalRows sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                     return [[obj1 person] compare:[obj2 person]];
                 }];
                 
                 NSLog(@"JSON: %@", responseJSON);
         
                 switch (_multipleType) {
                     case MultipleTypeTable:
                         [self.tableView reloadData];
                         break;
                     case MultipleTypeChart:
                         [self reloadChart];
                         break;
                 }
                 /**************************************************/
                 }
             }];
    }
}

- (NSString *)requestString {
    
    NSInteger siteID = 0;
    
    for (LGSite *site in [[LGSiteListSingleton sharedSiteList] sites]) {
        
        if ([site.siteURL isEqualToString:_siteLabel.text]) {
            siteID = [site.siteID integerValue];
            continue;
        }
    }
    
    NSString *string = [NSString stringWithFormat:@"stat/over_stat?siteId=%ld", siteID];
//    NSString *string = [NSString stringWithFormat:@"stat/over_stat?siteId=323"];
    
    return [string encodeURLString];
}

#pragma mark - Chart Methods

- (void)reloadChart {
    
    [self.barChart removeFromSuperview];
    
    UIScrollView *scrollView;
    PNBarChart *barChart;
    
    CGRect contentFrame = [self contentFrame];
    
    if (_generalRows) {
        
        NSMutableArray *persons = [NSMutableArray array];
        NSMutableArray *numberOfMentions = [NSMutableArray array];
        
        for (LGGeneralRow *row in _generalRows) {
            [persons addObject:row.person];
            [numberOfMentions addObject:row.numberOfMentions];
        }
        
        NSInteger valueWidth = 60;
        NSInteger maxValuesOnScreen = 6;
        NSInteger contentWidth;
        
        if (persons.count > maxValuesOnScreen) {
            contentWidth = valueWidth * (persons.count + 1);
        } else {
            contentWidth = CGRectGetWidth(contentFrame);
        }
        
        // create ScrollView
        scrollView = [[UIScrollView alloc] initWithFrame:contentFrame];
        scrollView.contentSize = CGSizeMake(contentWidth, CGRectGetHeight(contentFrame));
        
        // create Chart
        barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 0, contentWidth, CGRectGetHeight(contentFrame))];
        barChart.isGradientShow = NO;
        barChart.strokeColor = [UIColor blueColor];
        barChart.showChartBorder = YES;
        
        if (persons.count > 4) {
            barChart.rotateForXAxisText = YES;
            barChart.labelMarginTop = -20.0;
            barChart.chartMarginBottom = 70;
        } else if (persons.count > maxValuesOnScreen) {
            barChart.xLabelWidth = valueWidth;
        } else {
            barChart.chartMarginBottom = 50;
        }
        
        [barChart setXLabels:persons];
        [barChart setYValues:numberOfMentions];
        
    } else {
        
        // create ScrollView
        scrollView = [[UIScrollView alloc] initWithFrame:contentFrame];
        scrollView.contentSize = contentFrame.size;
        
        // create Chart
        barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(contentFrame), CGRectGetHeight(contentFrame))];
        barChart.showChartBorder = YES;
        
    }
    
    [barChart strokeChart];
    
    [self.view addSubview:scrollView];
    [scrollView addSubview:barChart];
    self.barChart = scrollView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _generalRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"PersonCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    
    // Configure the cell...
    
    LGGeneralRow *row = _generalRows[indexPath.row];
    
    // set textLabel
    cell.textLabel.text = row.person;
    
    // set detailTextLabel
    cell.detailTextLabel.text = row.numberOfMentions;
    cell.detailTextLabel.textColor = [UIColor blueColor];
    
    return cell;
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

#pragma mark - Methods

- (void)changeInfoView {
    
    NSLog(@"LGGeneralViewController %d", _multipleType);
    
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
    [self.barChart removeFromSuperview];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:[self contentFrame]];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    self.tableView = tableView;
    
    [self.view addSubview:tableView];
}

- (void) createChart {
    [self.tableView removeFromSuperview];
    [self.barChart removeFromSuperview];
    [self reloadChart];
}

- (void)createPopover:(UIView *)sender {
    
    CGSize contentSize = CGSizeMake(280,280);
    
    LGPopoverViewController *vc= [[LGPopoverViewController alloc] init];
    vc.preferredContentSize = contentSize;
    vc.delegate = self;
    
    self.popoverViewController = vc;
    
    UINavigationController *destNav = [[UINavigationController alloc] initWithRootViewController:vc];
    destNav.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *presentationController = [destNav popoverPresentationController];
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    presentationController.delegate = self;
    presentationController.sourceView = sender;
    presentationController.sourceRect = sender.bounds;
    
    [self presentViewController:destNav animated:YES completion:nil];
}

- (CGRect)contentFrame {
    
    CGFloat space = 8;
    CGFloat y;
    CGFloat heigth;
    
    y = CGRectGetMaxY(_siteLabel.frame) + space;
    
    heigth = CGRectGetMinY(self.tabBarController.tabBar.frame) - y;
    
    return CGRectMake(0, y, SCREEN_WIDTH, heigth);
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

#pragma mark - LGPopoverViewControllerDelegate

- (NSString *)titleForPopoverViewController:(LGPopoverViewController *)popoverViewController {
    return @"Выберите сайт";
}

- (NSArray<NSString *> *)arrayForPopoverViewController:(LGPopoverViewController *)popoverViewController {
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (LGSite *site in [[LGSiteListSingleton sharedSiteList] sites]) {
        
        [array addObject:site.siteURL];
        
    }
    
    return array;
}

- (NSString *)labelCurrentRowForPopoverViewController:(LGPopoverViewController *)popoverViewController {
    return _siteLabel.text;
}

- (void)stringChange:(NSString *)string {
    self.siteLabel.text = string;
}

- (NSString *)titleButtonForPopoverViewController:(LGPopoverViewController *)popoverViewController {
    return @"Применить";
}

- (UIColor *)colorBackgroundForReturnButton {
    return [UIColor blueColor];
}

- (UIColor *)colorTextForReturnButton{
    return [UIColor whiteColor];
}

- (void)disappearedPopoverViewController:(LGPopoverViewController *)popoverViewController {
    [self actionApply:nil];
}

- (void)actionReturn:(UIButton *)button {
    
    [_popoverViewController dismissViewControllerAnimated:YES
                                               completion:nil];
     
}

#pragma mark - Actions

- (void)actionApply:(id)sender {
    // Метод заполнения таблицы или графика
    NSLog(@"Вывод информации");
    
    [self requestStat];
    
}

@end
