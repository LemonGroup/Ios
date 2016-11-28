//
//  LGTabBarController.m
//  Lemon Stat
//
//  Created by A&A  on 19.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGTabBarController.h"

#import "UIImage+UISegmentIconAndText.h"

#import "LGGeneralStatsController.h"
#import "LGDailyStatsController.h"

NSMutableArray *gTokens;    // Все токены
NSString *gToken;           // Токен (присваевается при входе в систему)
NSInteger gGroupID;         // ID группы (присваевается при входе в систему)
NSInteger gPrivilege;       // Привелегия (присваевается при входе в систему)

@interface LGTabBarController ()

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
    
    // change rendering mode for UITabBar images
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        for (UITabBarItem *tbi in self.tabBar.items) {
            tbi.image = [tbi.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            tbi.selectedImage = [tbi.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
    }
    
    [self createSegmentedControl];
    
    // отслеживаем контрол таблица/график
    [self addObserver:self
           forKeyPath:@"_multipleOptions.selectedSegmentIndex"
              options:NSKeyValueObservingOptionNew
              context:NULL];
    
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
    NSLog(@"\nobserveValueForKeyPath: %@\nofObject: %@\nchange: %@", keyPath, object, change);
    
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

#pragma mark - Methods

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

- (void)alertAction {
    
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
    
    [self alertAction];
    
}

@end
