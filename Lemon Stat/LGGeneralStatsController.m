//
//  GeneralStatsController.m
//  Lemon Stat
//
//  Created by decidion on 09.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGGeneralStatsController.h"

#import <AFNetworking/AFNetworking.h>

@interface LGGeneralStatsController () {
    NSArray *_responseJSON;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LGGeneralStatsController

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
    
    [manager GET:@"http://yrsoft.cu.cc:8080/stat/over_stat?site=lenta.ru"
      parameters:nil
        progress:^(NSProgress * _Nonnull downloadProgress) {
            
        }
         success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
             _responseJSON = responseObject;
             
             
             [self.tableView reloadData];
             NSLog(@"JSON: %@", _responseJSON);
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




@end
