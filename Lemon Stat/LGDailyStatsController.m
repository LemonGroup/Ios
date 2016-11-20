//
//  LGDailyStatsController.m
//  Lemon Stat
//
//  Created by decidion on 09.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGDailyStatsController.h"

#import "LGPopoverViewController.h"

#import <AFNetworking/AFNetworking.h>

//**************** Временный код ******************//
//*********** выбор персонажа и сайта *************//
static NSString *kPerson = @"Навальный"; // Путин, Медведев, Навальный
static NSString *kSite = @"www.lenta.ru"; // www.lenta.ru, www.rbk.ru, www.vesti.ru
//*************************************************//

@interface LGDailyStatsController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, LGPopoverViewControllerDelegate> {
    NSArray *_responseJSON;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) LGPopoverViewController *popoverViewController;

@property (weak, nonatomic) UITextField *currentTextField;

@property (strong, nonatomic) NSArray *dateArray;
@property (strong, nonatomic) NSArray *numberArray;

// Fake Data //
@property (strong, nonatomic) NSArray *personsFake;
@property (strong, nonatomic) NSArray *sitesFake;

@end

@implementation LGDailyStatsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // filling fake data
    _personsFake = @[@"Путин", @"Медведев", @"Навальный"];
    _sitesFake = @[@"lenta.ru", @"vesti.ru", @"rbk.ru"];
    
//    [self loadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AFNetworking

- (void)loadData {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *requestString = [self requestString];
    
    [manager GET:requestString
      parameters:nil
        progress:nil
         success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
             
             _responseJSON = responseObject;
             
             [self.tableView reloadData];
             [self setTotalNumber];
             NSLog(@"JSON: %@", _responseJSON);
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
         }];
    
}

#pragma mark - Requests Methods

- (NSString *)requestString {
    
    NSString *site = _siteLabel.text;
    NSString *person = [_personLabel.text lowercaseString];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *startDate = [formatter stringFromDate:_selectedStartDate];
    NSString *endDate = [formatter stringFromDate:_selectedEndDate];
    
    NSString *notEncoded = [NSString stringWithFormat:@"http://yrsoft.cu.cc:8080/stat/daily_stat?site=%@&person=%@&start_date=%@&end_date=%@", site, person, startDate, endDate];
    
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:notEncoded];
    NSString *encoded = [notEncoded stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    
    return encoded;
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
    
    static NSString *identifier = @"DateCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    // set textLabel
    cell.textLabel.text = [_responseJSON[indexPath.row] valueForKey:@"date"];
    
    // set detailTextLabel
    NSString *numberOfNewPages = [_responseJSON[indexPath.row] valueForKey:@"numberOfNewPages"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", numberOfNewPages];
    
    return cell;
}

#pragma mark - Methods

- (void)setTotalNumber {
    
    NSInteger totalNumber = 0;
    
    for (id obj in _responseJSON) {
        
        NSNumber *number = [obj valueForKey:@"numberOfNewPages"];
        
        totalNumber += [number integerValue];
    }
    
    _totalNumberLabel.text = [NSString stringWithFormat:@"%ld", totalNumber];
}

- (NSArray *)arrayForSite:(NSString *)site andPerson:(NSString *)person forKey:(NSString *)key {
    
    NSArray *dates;
    
    for (id sites in _responseJSON) {
        
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

- (void)createPopover:(UITextField *)sender {
    
    CGSize contentSize = CGSizeMake(280,280);
    
    LGPopoverViewController *vc= [[LGPopoverViewController alloc] init];
    vc.preferredContentSize = contentSize;
    vc.delegate = self;
    //vc.type = (LGPopoverType)sender.tag;
    
    switch (sender.tag) {
        case TextFieldTypeSites:
            vc.currentString = self.siteLabel.text;
            break;
        case TextFieldTypePersons:
            vc.currentString = self.personLabel.text;
            break;
        case TextFieldTypeStartDate:
            vc.currentDate = _selectedStartDate;
            break;
        case TextFieldTypeEndDate:
            vc.currentDate = _selectedEndDate;
            break;
        default:
            break;
    }
    
    self.popoverViewController = vc;
    self.currentTextField = sender;
    
    UINavigationController *destNav = [[UINavigationController alloc] initWithRootViewController:vc];
    destNav.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *presentationController = [destNav popoverPresentationController];
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    presentationController.delegate = self;
    presentationController.sourceView = sender;
    presentationController.sourceRect = sender.bounds;
    
    [self presentViewController:destNav animated:YES completion:nil];
    
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

#pragma mark - LGPopoverViewControllerDelegate

- (NSString *)titleForPopoverViewController:(LGPopoverViewController *)popoverViewController {
    
    switch (self.currentTextField.tag) {
        case TextFieldTypeSites:
            return @"Выберите сайт";
            break;
        case TextFieldTypePersons:
            return @"Выберите личность";
            break;
        case TextFieldTypeStartDate:
            return @"Выберите начальную дату";
            break;
        case TextFieldTypeEndDate:
            return @"Выберите конечную дату";
            break;
            
            
        default:
            return nil;
            break;
    }
}

- (NSArray *)arrayForPopoverViewController:(LGPopoverViewController *)popoverViewController {
    
    switch (self.currentTextField.tag) {
        case TextFieldTypeSites:
            return _sitesFake;
            break;
        case TextFieldTypePersons:
            return _personsFake;
            break;
        default:
            return nil;
            break;
    }
}

- (NSString *)labelCurrentRowForPopoverViewController:(LGPopoverViewController *)popoverViewController {
    
    switch (self.currentTextField.tag) {
        case TextFieldTypeSites:
            return _siteLabel.text;
            break;
        case TextFieldTypePersons:
            return _personLabel.text;
            break;
        default:
            return nil;
            break;
    }
    
}

- (void)stringChange:(NSString *)string {
    
    switch (self.currentTextField.tag) {
        case TextFieldTypeSites: {
            self.siteLabel.text = string;
        }
            break;
        case TextFieldTypePersons: {
            self.personLabel.text = string;
        }
            break;
        default:
            break;
    }
}

- (void)dateChange:(UIDatePicker *)datePicker {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMMM YYYY"];
    
    switch (self.currentTextField.tag) {
        case TextFieldTypeStartDate: {
            self.selectedStartDate = datePicker.date;
            self.startDateLabel.text = [dateFormatter stringFromDate:datePicker.date];
        }
            break;
        case TextFieldTypeEndDate: {
            self.selectedEndDate = datePicker.date;
            self.endDateLabel.text = [dateFormatter stringFromDate:datePicker.date];
        }
            break;
        default:
            break;
    }
}

- (void)dateRangeForDatePicker:(UIDatePicker *)datePicker forPopoverViewController:(LGPopoverViewController *)popoverViewController {
    
    switch (self.currentTextField.tag) {
        case TextFieldTypeStartDate: {
            
            datePicker.minimumDate = [[NSDate alloc] initWithTimeIntervalSince1970:0];
            
            if (self.selectedEndDate) {         // если установлена конечная дата
                datePicker.maximumDate = _selectedEndDate;
            } else {
                datePicker.maximumDate = [NSDate date];
            }
        }
            break;
        case TextFieldTypeEndDate: {
            
            if (self.selectedStartDate) {         // если установлена начальная дата
                datePicker.minimumDate = _selectedStartDate;
            } else {
                datePicker.minimumDate = [[NSDate alloc] initWithTimeIntervalSince1970:0];
            }
            
            datePicker.maximumDate = [NSDate date];
            
        }
            break;
        default:
            break;
    }
}

- (NSString *)titleButtonForPopoverViewController:(LGPopoverViewController *)popoverViewController {
    
    if (self.currentTextField.tag == TextFieldTypeEndDate) {
        return @"Применить";
    } else {
        return @"Дальше";
    }
}

- (void)actionReturn:(UIButton *)button {
    
    switch (self.currentTextField.tag) {
        case TextFieldTypeSites: {
            [_popoverViewController dismissViewControllerAnimated:YES completion:^{
                [self.personLabel becomeFirstResponder];
            }];
        }
            break;
        case TextFieldTypePersons: {
            [_popoverViewController dismissViewControllerAnimated:YES completion:^{
                [self.startDateLabel becomeFirstResponder];
            }];
        }
            break;
        case TextFieldTypeStartDate: {
            [_popoverViewController dismissViewControllerAnimated:YES completion:^{
                [self.endDateLabel becomeFirstResponder];
            }];
        }
            break;
        case TextFieldTypeEndDate: {
            [_popoverViewController dismissViewControllerAnimated:YES completion:^{
                [self actionApply:nil];
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Actions

- (IBAction)actionApply:(id)sender {
    // Метод заполнения таблицы или графика
    
    [self loadData];
}

#pragma mark - Segment Control



@end
