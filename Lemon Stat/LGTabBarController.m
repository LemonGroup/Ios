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

#import "LGSiteListSingleton.h"
#import "LGSite.h"
#import "LGPersonListSingleton.h"
#import "LGPerson.h"

@interface LGTabBarController ()

@end

@implementation LGTabBarController

@synthesize multipleOptions;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self requestGetSites];
    [self requestGetPersons];
    
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
        case 0:
            NSLog(@"Segment 0");
            break;
        case 1:
            NSLog(@"Segment1");
        default:
            break;
    }
    
}


#pragma mark - Requests Methods

- (void)requestGetSites {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *string = @"http://yrsoft.cu.cc:8080/catalog/sites";
    
    [manager GET:[string encodeURLString]
      parameters:nil
        progress:nil
         success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
             
             [self createSiteListWithJSONArray:responseObject];
             
             NSLog(@"JSON: %@", responseObject);
             
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
         }];
    
}

- (void)createSiteListWithJSONArray:(NSArray *)responseJSON {
    
    LGSiteListSingleton *siteList = [LGSiteListSingleton sharedSiteList];
    
    for (id obj in responseJSON) {
        
        LGSite *site = [LGSite siteWithID:[obj valueForKey:@"id"] andURL:[obj valueForKey:@"site"]];
        
        [siteList.sites addObject:site];
        
    }
    
}

- (void)requestGetPersons {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *string = @"http://yrsoft.cu.cc:8080/catalog/persons";
    
    [manager GET:[string encodeURLString]
      parameters:nil
        progress:nil
         success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
             
             [self createPersonListWithJSONArray:responseObject];
             
             NSLog(@"JSON: %@", responseObject);
             
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
         }];
    
}

- (void)createPersonListWithJSONArray:(NSArray *)responseJSON {
    
    LGPersonListSingleton *personList = [LGPersonListSingleton sharedPersonList];
    
    for (id obj in responseJSON) {
        
        LGPerson *person = [LGPerson personWithID:[obj valueForKey:@"id"] andName:[obj valueForKey:@"personName"]];
        
        [personList.persons addObject:person];
        
    }
    
}

@end
