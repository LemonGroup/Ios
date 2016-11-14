//
//  GeneralStatsController.m
//  Lemon Stat
//
//  Created by decidion on 09.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "GeneralStatsController.h"

#import <AFNetworking/AFNetworking.h>

@interface GeneralStatsController () {
    NSArray *responseJSON;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GeneralStatsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self loadData];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AFNetworking

- (void)loadData {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:@"http://lemonstat.usite.pro/StatisticFake.json"
      parameters:nil
        progress:^(NSProgress * _Nonnull downloadProgress) {
            
        }
         success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
             responseJSON = [responseObject valueForKey:@"response"];
             [self.tableView reloadData];
             NSLog(@"JSON: %@", responseObject);
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
         }];
    
}

#pragma mark - UITableViewDelegate



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return responseJSON.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"PersonCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    cell.textLabel.text = [responseJSON[indexPath.row] valueForKey:@"person"];
    cell.detailTextLabel.text = [responseJSON[indexPath.row] valueForKey:@"number"];
    
    return cell;
}




@end
