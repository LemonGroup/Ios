//
//  LGTabBarController.m
//  Lemon Stat
//
//  Created by A&A  on 19.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGTabBarController.h"

#import <AFNetworking/AFNetworking.h>

#import "NSString+Request.h"

NSString *gToken;
NSInteger gGroupID;
NSInteger gPrivilege;


@interface LGTabBarController ()

@end

@implementation LGTabBarController

@synthesize multipleOptions;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading 
    
//    [self requestGetSites];
//    [self requestGetPersons];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)changeSegment:(id)sender {
    
    switch (multipleOptions.selectedSegmentIndex) {
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
