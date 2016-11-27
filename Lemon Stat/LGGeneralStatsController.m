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

#import "NSString+Request.h"

//#import "LGTabBarController.h"

@interface LGGeneralStatsController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, LGPopoverViewControllerDelegate> {
    NSArray *_responseJSON;
}

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) PNBarChart *barChart;

@property (weak, nonatomic) LGPopoverViewController *popoverViewController;

@property (weak, nonatomic) IBOutlet UITextField *siteLabel;

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
    
    NSString *requestString = [self requestString];
    
    if (requestString) {
        
        [manager GET:requestString
          parameters:nil
            progress:^(NSProgress * _Nonnull downloadProgress) {
                
            }
             success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
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
                 
                 NSLog(@"JSON: %@", _responseJSON);
             }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 NSLog(@"Error: %@", error);
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
    
    //NSString *string = [NSString stringWithFormat:@"stat/over_stat?siteId=%ld", siteID];
    NSString *string = [NSString stringWithFormat:@"stat/over_stat?siteId=1"];
    
    return [string encodeURLString];
}

#pragma mark - Chart Methods

- (void)loadChart {
    
    NSMutableArray *persons = [NSMutableArray array];
    NSMutableArray *numberOfMentions = [NSMutableArray array];
    
    for (id obj in _responseJSON) {
        [persons addObject:[obj valueForKey:@"person"]];
    }
    
    for (id obj in _responseJSON) {
        [numberOfMentions addObject:[obj valueForKey:@"numberOfMentions"]];
    }
    
    self.barChart.labelMarginTop = 30.0;
    self.barChart.barWidth = 40;
    [self.barChart setXLabels:persons];
    [self.barChart setYValues:numberOfMentions];
    [self.barChart strokeChart];
    
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
    
    static NSString *identifier = @"PersonCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    cell.textLabel.text = [_responseJSON[indexPath.row] valueForKey:@"person"];
    
    NSString *numberOfMentions = [_responseJSON[indexPath.row] valueForKey:@"numberOfMentions"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", numberOfMentions];
    
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
        default:
            break;
    }
}

- (void)createTableView {
    [self.barChart removeFromSuperview];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 135.0, SCREEN_WIDTH, 480)];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    self.tableView = tableView;
    
    [self.view addSubview:tableView];
}

- (void) createChart {
    [self.tableView removeFromSuperview];
    
    PNBarChart *barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 135.0, SCREEN_WIDTH, 480)];
    self.barChart = barChart;
    
    [self.view addSubview:barChart];
    [self loadChart];
}

- (void)createPopover:(UIView *)sender {
    
    CGSize contentSize = CGSizeMake(280,280);
    
    LGPopoverViewController *vc= [[LGPopoverViewController alloc] init];
    vc.preferredContentSize = contentSize;
    vc.delegate = self;
    
    [self willChangeValueForKey:@"popoverViewController"];
    self.popoverViewController = vc;
    [self didChangeValueForKey:@"popoverViewController"];
    
    UINavigationController *destNav = [[UINavigationController alloc] initWithRootViewController:vc];
    destNav.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *presentationController = [destNav popoverPresentationController];
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    presentationController.delegate = self;
    presentationController.sourceView = sender;
    presentationController.sourceRect = sender.bounds;
    
    [self presentViewController:destNav animated:YES completion:nil];
    
}

#pragma mark - LGPopoverViewControllerDelegate

- (NSString *)titleForPopoverViewController:(LGPopoverViewController *)popoverViewController {
    return @"Выберите сайт";
}

- (NSArray *)arrayForPopoverViewController:(LGPopoverViewController *)popoverViewController {
    
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

- (void)actionReturn:(UIButton *)button {
    
    [_popoverViewController dismissViewControllerAnimated:YES completion:nil];
     
}

- (BOOL)recognizeDisappearForPopoverViewController:(LGPopoverViewController *)popoverViewController {
    return YES;
}

- (void)disappearedPopoverViewController:(LGPopoverViewController *)popoverViewController {
    [self actionApply:nil];
}

#pragma mark - Actions

- (void)actionApply:(id)sender {
    // Метод заполнения таблицы или графика
    NSLog(@"Вывод информации");
    
    [self requestStat];
    
}

@end
