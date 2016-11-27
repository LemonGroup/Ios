//
//  LGTabBarController.m
//  Lemon Stat
//
//  Created by A&A  on 19.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGTabBarController.h"

#import "UIImage+UISegmentIconAndText.h"

NSString *gToken;           // Токен (присваевается при входе в систему)
NSInteger gGroupID;         // ID группы (присваевается при входе в систему)
NSInteger gPrivilege;       // Привелегия (присваевается при входе в систему)

@interface LGTabBarController ()

@end

@implementation LGTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading
    
    // change rendering mode for UITabBar images
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        for (UITabBarItem *tbi in self.tabBar.items) {
            tbi.image = [tbi.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            tbi.selectedImage = [tbi.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
    }
    
    [self createSegmentedControl];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)createSegmentedControl {
    
    UIImage *tableImage = [UIImage imageFromImage:[UIImage imageNamed:@"tableSegment_32"] size:CGSizeMake(32, 32) string:@"Таблица"];// color:[UIColor redColor]];
    UIImage *graphImage = [UIImage imageFromImage:[UIImage imageNamed:@"graphSegment_32"] size:CGSizeMake(32, 32) string:@"График"];// color:[UIColor yellowColor]];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[tableImage,graphImage]];
//    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[[tableImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal], [graphImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]]];
    
    segmentedControl.selectedSegmentIndex = 0;
    
    [segmentedControl addTarget:self
                         action:@selector(changeSegment:)
               forControlEvents:UIControlEventValueChanged];
    
    _multipleOptions = segmentedControl;
    
    self.navigationItem.titleView = segmentedControl;
    
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

- (void)changeSegment:(id)sender {
    
    switch (_multipleOptions.selectedSegmentIndex) {
        case 0: {
            NSLog(@"Segment 0");
        }
            break;
        case 1: {
            NSLog(@"Segment1");
        }
        default:
            break;
    }
    
}

@end
