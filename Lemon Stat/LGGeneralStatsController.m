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

@interface LGGeneralStatsController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, LGPopoverViewControllerDelegate, PNChartDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UIScrollView *scrollChartView;
@property (weak, nonatomic) PNBarChart *barChart;

@property (weak, nonatomic) LGPopoverViewController *popoverViewController;

@property (weak, nonatomic) IBOutlet UITextField *siteLabel;

@property (strong, nonatomic) NSArray<LGGeneralRow *> *generalRows;

@property (weak, nonatomic) UIActivityIndicatorView *activityIndecatorView;

@property (weak, nonatomic) UILabel *currentBarLabel;

@property (weak, nonatomic) PNBar *selectedBar;

@end

@implementation LGGeneralStatsController

/************* Убрать этот кусок кода *************/
#pragma mark - Fake Method
- (void)fakeDataMethod {
    // фейковые данные
    NSArray *responseJSON = @[@{@"numberOfMentions" : @10, @"person" : @"Путин"},
                              @{@"numberOfMentions" : @232, @"person" : @"Навальный"},
                              @{@"numberOfMentions" : @66, @"person" : @"Медведев"},
                              @{@"numberOfMentions" : @1, @"person" : @"Меркель"},
                              @{@"numberOfMentions" : @23, @"person" : @"Лукашенко"},
                              @{@"numberOfMentions" : @53, @"person" : @"Дамблдор"},
                              @{@"numberOfMentions" : @112, @"person" : @"Саакашвилли"},
                              @{@"numberOfMentions" : @34, @"person" : @"Обама"},
                              @{@"numberOfMentions" : @54, @"person" : @"Трамп"},
                              @{@"numberOfMentions" : @99, @"person" : @"Клинтон"},
                              @{@"numberOfMentions" : @150, @"person" : @"Сноуден"},
                              @{@"numberOfMentions" : @34, @"person" : @"Жириновский"},
                              @{@"numberOfMentions" : @123, @"person" : @"Зюганов"},
                              @{@"numberOfMentions" : @12, @"person" : @"Миронов"},
                              @{@"numberOfMentions" : @199, @"person" : @"Олландо"},
                              @{@"numberOfMentions" : @54, @"person" : @"Черчель"},
                              @{@"numberOfMentions" : @74, @"person" : @"Мандела"},
                              @{@"numberOfMentions" : @74, @"person" : @"Наполеон"},
                              @{@"numberOfMentions" : @75, @"person" : @"Гитлер"},
                              @{@"numberOfMentions" : @10, @"person" : @"Путин"},
                              @{@"numberOfMentions" : @232, @"person" : @"Навальный"},
                              @{@"numberOfMentions" : @66, @"person" : @"Медведев"},
                              @{@"numberOfMentions" : @1, @"person" : @"Меркель"},
                              @{@"numberOfMentions" : @23, @"person" : @"Лукашенко"},
                              @{@"numberOfMentions" : @53, @"person" : @"Дамблдор"},
                              @{@"numberOfMentions" : @112, @"person" : @"Саакашвилли"},
                              @{@"numberOfMentions" : @34, @"person" : @"Обама"},
                              @{@"numberOfMentions" : @54, @"person" : @"Трамп"},
                              @{@"numberOfMentions" : @99, @"person" : @"Клинтон"},
                              @{@"numberOfMentions" : @150, @"person" : @"Сноуден"},
                              @{@"numberOfMentions" : @34, @"person" : @"Жириновский"},
                              @{@"numberOfMentions" : @123, @"person" : @"Зюганов"},
                              @{@"numberOfMentions" : @12, @"person" : @"Миронов"},
                              @{@"numberOfMentions" : @199, @"person" : @"Олландо"},
                              @{@"numberOfMentions" : @54, @"person" : @"Черчель"},
                              @{@"numberOfMentions" : @74, @"person" : @"Мандела"},
                              @{@"numberOfMentions" : @74, @"person" : @"Наполеон"},
                              @{@"numberOfMentions" : @75, @"person" : @"Гитлер"}
                              ];
    
    [self createRowsUsingAnJSONArray:responseJSON];
    
    NSLog(@"JSON: %@", responseJSON);
    
    switch (_multipleType) {
        case MultipleTypeTable:
            [self.tableView reloadData];
            break;
        case MultipleTypeChart:
            [self reloadChart];
            break;
    }
}
#pragma mark -
/**************************************************/

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _multipleType = MultipleTypeTable;
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = self.view.center;
    [self.view addSubview:activityIndicatorView];
    self.activityIndecatorView = activityIndicatorView;
    
    /************* Убрать этот кусок кода *************/
    [self fakeDataMethod];
    /**************************************************/
}

- (void)viewDidAppear:(BOOL)animated {
    [self changeInfoView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        if (_barChart) {
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
    
    NSString *requestString = [self requestString];
    
    if (requestString) {
        
        [manager GET:requestString
          parameters:nil
            progress:nil
             success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
                 
                 NSLog(@"responseObject JSON: %@", responseObject);
                 
                 if (responseObject) {
                     
                     [self createRowsUsingAnJSONArray:responseObject];
                     
                 } else {
                     
                     _generalRows = nil;
                     
                     [self alertActionWithTitle:@"Нет данных" andMessage:nil];
                     
                     /************* Убрать этот кусок кода *************/
                     [self fakeDataMethod];
                     /**************************************************/
                 }
                 
                 switch (_multipleType) {
                     case MultipleTypeTable:
                         [self.tableView reloadData];
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
    
    return [string encodeURLString];
}

#pragma mark - Chart Methods

- (void)reloadChart {
    
    [self.tableView removeFromSuperview];
    [self.scrollChartView removeFromSuperview];
    
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
        
        NSInteger contentWidth;
        NSInteger valueWidth = 30;
        NSInteger maxValuesOnScreen = CGRectGetWidth(contentFrame) / valueWidth;
        NSInteger minValuesOnScreenForRotateLabel = 5;
        
        if (persons.count > maxValuesOnScreen) {
            contentWidth = valueWidth * persons.count;
        } else {
            contentWidth = CGRectGetWidth(contentFrame);
        }
        
        // create ScrollView
        scrollView = [[UIScrollView alloc] initWithFrame:contentFrame];
        scrollView.contentSize = CGSizeMake(contentWidth, 0);
        
        // create Chart
        barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 0, contentWidth, CGRectGetHeight(contentFrame))];
        barChart.delegate = self;
        barChart.showChartBorder = YES;
        barChart.isGradientShow = NO;
        barChart.isShowNumbers = NO;
        barChart.strokeColor = [UIColor blueColor];
        
        if (persons.count >= minValuesOnScreenForRotateLabel) {
            barChart.rotateForXAxisText = YES;
            barChart.labelMarginTop = -30;
            barChart.chartMarginBottom = 100;
        } else {
            barChart.labelMarginTop = 20;
            barChart.chartMarginBottom = 40;
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
    
    [self.view insertSubview:scrollView belowSubview:_activityIndecatorView];
    [scrollView addSubview:barChart];
    
    self.scrollChartView = scrollView;
    self.barChart = barChart;
    
}

#pragma mark - PNChartDelegate;

- (void)userClickedOnBarAtIndex:(NSInteger)barIndex {
    
    PNBar *currentBar = _barChart.bars[barIndex];
    
    if (![currentBar isEqual:_selectedBar]) {
        
        if (_currentBarLabel) {
            [_currentBarLabel removeFromSuperview];
        }
        
        [self animateWhenTouchOnBar:currentBar];
        
        self.selectedBar = currentBar;
    }
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

- (void)createRowsUsingAnJSONArray:(NSArray *)responseJSON {
    
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
}

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
    [self.scrollChartView removeFromSuperview];
    
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
                                                              toItem:_siteLabel
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:8];
    
    NSLayoutConstraint *bottom =  [NSLayoutConstraint constraintWithItem:tableView
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0
                                                                constant:-CGRectGetHeight(self.tabBarController.tabBar.frame)];
    
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

- (UILabel *)createPointLabelWithTitel:(NSString *)title andCenter:(CGPoint)center {
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor colorWithWhite:1 alpha:0.65];
    label.font = [UIFont systemFontOfSize:30];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    [label sizeToFit];
    label.center = center;
    label.textColor = [UIColor blackColor];
    
    // set shadow
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowOffset = CGSizeMake(0.5, 0.4);  //Here you control x and y
    label.layer.shadowOpacity = 0.5;
    label.layer.shadowRadius = 5.0; //Here your control your blur
    label.layer.masksToBounds =  NO;
    
    [_barChart addSubview:label];
    
    return label;
}

#pragma mark - Animation Methods

- (void)animateWhenTouchOnBar:(PNBar *)bar {
    
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         // remove all animate
                         if (_selectedBar) {
                             CGAffineTransform scale2 = CGAffineTransformMakeScale(1, 1);
                             CGAffineTransform translate2 = CGAffineTransformMakeTranslation(0, 0);
                             CGAffineTransform concat2 = CGAffineTransformConcat(scale2, translate2);
                             _selectedBar.transform = concat2;
                             _selectedBar.chartLine.strokeColor = bar.chartLine.strokeColor;
                             _selectedBar.layer.masksToBounds =  YES;
                         }
                         
                         //set shadow
                         bar.layer.shadowColor = [UIColor blackColor].CGColor;
                         bar.layer.shadowOffset = CGSizeMake(0.5, 0.4);  //Here you control x and y
                         bar.layer.shadowOpacity = 0.5;
                         bar.layer.shadowRadius = 5.0; //Here your control your blur
                         bar.layer.masksToBounds =  NO;
                         // set color filling
                         bar.chartLine.strokeColor = [UIColor redColor].CGColor;
                         // set scale and translate
                         CGAffineTransform scale = CGAffineTransformMakeScale(1.3, 1.05);
                         CGAffineTransform translate = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(bar.frame) / 40);
                         CGAffineTransform concat = CGAffineTransformConcat(scale, translate);
                         bar.transform = concat;
                     }
                     completion:^(BOOL finished) {
                         _currentBarLabel = [self createPointLabelWithTitel:_generalRows[[_barChart.bars indexOfObject:bar]].numberOfMentions
                                                                  andCenter:bar.center];
                     }];
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
