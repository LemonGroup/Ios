//
//  SecondViewController.m
//  Lemon Stat
//
//  Created by decidion on 09.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "SecondViewController.h"

#import <AFNetworking/AFNetworking.h>

//**************** Временный код ******************//
//*********** выбор персонажа и сайта *************//
static NSString *kPerson = @"Навальный"; // Путин, Медведев, Навальный
static NSString *kSite = @"www.lenta.ru"; // www.lenta.ru, www.rbk.ru, www.vesti.ru
//*************************************************//

@interface SecondViewController () {
    NSArray *responseJSON;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *totalNumberLabel;

@property (strong, nonatomic) NSArray *dateArray;
@property (strong, nonatomic) NSArray *numberArray;

@end

@implementation SecondViewController

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
    
    [manager GET:@"http://lemonstat.usite.pro/DetailStatisticFake.json"
      parameters:nil
        progress:^(NSProgress * _Nonnull downloadProgress) {
            
        }
         success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
             responseJSON = [responseObject valueForKey:@"response"];
             
             // create data arrays for site and person
             _dateArray = [self arrayForSite:kSite
                                   andPerson:kPerson
                                      forKey:@"date"];
             _numberArray = [self arrayForSite:kSite
                                     andPerson:kPerson
                                        forKey:@"number"];
             
             [self.tableView reloadData];
             [self setTotalNumber];
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
    return _dateArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"DateCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    // set textLabel
    cell.textLabel.text = _dateArray[indexPath.row];
    
    // set detailTextLabel
    cell.detailTextLabel.text = _numberArray[indexPath.row];
    
    return cell;
}

#pragma mark - Methods

- (void)setTotalNumber {
    
    NSInteger totalNumber = 0;
    
    for (NSString *number in _numberArray) {
        
        totalNumber += [number integerValue];
        
    }
    
    _totalNumberLabel.text = [NSString stringWithFormat:@"%ld", totalNumber];
    
}

- (NSArray *)arrayForSite:(NSString *)site andPerson:(NSString *)person forKey:(NSString *)key {
    
    NSArray *dates;
    
    for (id sites in responseJSON) {
        
        if ([[sites valueForKey:@"site"] isEqualToString:kSite]) {
            
            dates = [sites valueForKey:@"dates"];
            continue;
        }
    }
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (id obj in dates) {
        
        NSArray *persons = [obj valueForKey:@"persons"];
        
        for (id person in persons) {
            
            NSString *personName = [person valueForKey:@"person"];
            
            if ([personName isEqualToString:kPerson]) {
                
                if ([key isEqualToString:@"date"]) {
                    
                    [array addObject:[obj valueForKey:key]];
                    
                } else if ([key isEqualToString:@"number"]) {
                    
                    [array addObject:[person valueForKey:key]];
                    
                }
            }
        }
    }
    
    return array;
}

@end
