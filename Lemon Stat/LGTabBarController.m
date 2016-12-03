//
//  LGTabBarController.m
//  Lemon Stat
//
//  Created by A&A  on 19.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGTabBarController.h"

#import <AFNetworking/AFNetworking.h>

#import "UIImage+UISegmentIconAndText.h"

#import "LGSiteListSingleton.h"
#import "LGSite.h"
#import "LGPersonListSingleton.h"
#import "LGPerson.h"

#import "LGGeneralStatsController.h"
#import "LGDailyStatsController.h"

NSMutableArray *gTokens;    // Все токены
NSString *gToken;           // Токен (присваевается при входе в систему)

@interface LGTabBarController () <UITabBarDelegate>

@property (strong, nonatomic) LGGeneralStatsController *generalStatController;
@property (strong, nonatomic) LGDailyStatsController *dailyStatsController;

@property (assign, nonatomic) MultipleType multipleType;
@property (weak, nonatomic) UISegmentedControl *multipleOptions;

@end

@implementation LGTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading
    
    _generalStatController = self.viewControllers[0];
    _dailyStatsController = self.viewControllers[1];
    
    [self createSegmentedControl];
    
    // отслеживаем контрол таблица/график
    [self addObserver:self
           forKeyPath:@"_multipleOptions.selectedSegmentIndex"
              options:NSKeyValueObservingOptionNew
              context:NULL];
    
    [self requestGetSites];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"_multipleOptions.selectedSegmentIndex"];
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"_multipleOptions.selectedSegmentIndex"] &&
        [object isKindOfClass:[LGTabBarController class]]) {
        
        LGGeneralStatsController *generalStatsController = self.viewControllers[0];
        LGDailyStatsController *dailyStatsController = self.viewControllers[1];
        
        generalStatsController.multipleType = _multipleType;
        dailyStatsController.multipleType = _multipleType;
        
        if ([self.selectedViewController isKindOfClass:[LGGeneralStatsController class]]) {
            
            [generalStatsController changeInfoView];
            
        } else if ([self.selectedViewController isKindOfClass:[LGDailyStatsController class]]) {
            
            [dailyStatsController changeInfoView];
        }
    }
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    [self requestGetSites];
    
    if ([tabBar.items indexOfObject:item] == 1) {
        [self requestGetPersons];
    }
}

#pragma mark - Request Methods

- (void)requestGetSites {
    
    extern NSString *gToken;
    extern NSURL *gBaseURL;
    extern NSString *gContentType;
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithBaseURL:gBaseURL];
    [manager.requestSerializer setValue:gContentType forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:gToken forHTTPHeaderField:@"Auth-Token"];
    
    NSString *string = @"catalog/sites";
    
    [manager GET:string
      parameters:nil
        progress:nil
         success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
             
             [self createSiteListUsingAnJSONArray:responseObject];
             
             NSLog(@"JSON: %@", responseObject);
             
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
         }];
}

- (void)requestGetPersons {
    
    extern NSString *gToken;
    extern NSURL *gBaseURL;
    extern NSString *gContentType;
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithBaseURL:gBaseURL];
    [manager.requestSerializer setValue:gContentType forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:gToken forHTTPHeaderField:@"Auth-Token"];
    
    NSString *string = @"catalog/persons";
    
    [manager GET:string
      parameters:nil
        progress:nil
         success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
             
             [self createPersonListUsingAnJSONArray:responseObject];
             
             NSLog(@"JSON: %@", responseObject);
             
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
         }];
}

#pragma mark - Methods

- (void)createSiteListUsingAnJSONArray:(NSArray *)responseJSON {
    
    if (responseJSON) {
        
        NSMutableArray<LGSite *> *array = [NSMutableArray array];
        
        for (id obj in responseJSON) {
            LGSite *site = [LGSite siteWithID:[obj valueForKey:@"id"] andURL:[obj valueForKey:@"site"]];
            [array addObject:site];
        }
        
        LGSiteListSingleton *siteList = [LGSiteListSingleton sharedSiteList];
        if (![siteList.sites isEqual:array]) {
            siteList.sites = array;
            [siteList sortList];
        }
    }
}

- (void)createPersonListUsingAnJSONArray:(NSArray *)responseJSON {
    
    if (responseJSON) {
        
        NSMutableArray<LGPerson *> *array = [NSMutableArray array];
        
        for (id obj in responseJSON) {
            LGPerson *person = [LGPerson personWithID:[obj valueForKey:@"id"] andName:[obj valueForKey:@"personName"]];
            [array addObject:person];
        }
        
        LGPersonListSingleton *personList = [LGPersonListSingleton sharedPersonList];
        if (![personList.persons isEqual:array]) {
            personList.persons = array;
            [personList sortList];
        }
    }
}

- (void)createSegmentedControl {
    
    UIImage *tableImage = [UIImage imageFromImage:[UIImage imageNamed:@"tableSegment_32"] size:CGSizeMake(32, 32) string:@"Таблица"];
    UIImage *graphImage = [UIImage imageFromImage:[UIImage imageNamed:@"graphSegment_32"] size:CGSizeMake(32, 32) string:@"График"];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[tableImage,graphImage]];
    
    segmentedControl.selectedSegmentIndex = 0;
    
    [segmentedControl addTarget:self
                         action:@selector(changeMultipleOptions:)
               forControlEvents:UIControlEventValueChanged];
    
    _multipleOptions = segmentedControl;
    
    self.navigationItem.titleView = segmentedControl;
}

#pragma mark - Alert Methods

- (void)alertActionWithTitle:(NSString *)title andMessage:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ок"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)alertActionExit {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Подтвердите выход из приложения"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Отмена"
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    
    UIAlertAction *agreeAction = [UIAlertAction actionWithTitle:@"Подтвердить"
                                                          style:UIAlertActionStyleDestructive
                                                        handler:^(UIAlertAction *action) {
                                                            gToken = @"notToken";
                                                            [self dismissViewControllerAnimated:YES completion:nil];
                                                        }];
    
    [alert addAction:cancelAction];
    [alert addAction:agreeAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"ShowSettings"]) {
        
        [segue destinationViewController].navigationItem.title = @"Личные данные";
        
    } else {
        [self requestGetSites];
        [self requestGetPersons];
    }
}

#pragma mark - Actions

- (void)changeMultipleOptions:(id)sender {
    
    switch (_multipleOptions.selectedSegmentIndex) {
        case 0: {
            _multipleType = MultipleTypeTable;
            NSLog(@"Segment 0");
        }
            break;
        case 1: {
            _multipleType = MultipleTypeChart;
            NSLog(@"Segment1");
        }
    }
}

- (IBAction)actionLogOut:(id)sender {
    
    [self alertActionExit];
    
}

@end
