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

@interface LGGeneralStatsController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPopoverPresentationControllerDelegate> {
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

#pragma mark - UITextFieldDelegate

//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//
//    [textField resignFirstResponder];
//
//    return YES;
//}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [self createPopover:textField];
    
    return NO;
}

#pragma mark - UIAdaptivePresentationControllerDelegate

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}

#pragma mark - Methods

- (void)createPopover:(UIView *)sender {
    
    CGSize contentSize = CGSizeMake(280,200);
    
    LGPopoverViewController *vc= [[LGPopoverViewController alloc] init];
    vc.preferredContentSize = contentSize;
    
    UINavigationController *destNav = [[UINavigationController alloc] initWithRootViewController:vc];
    destNav.modalPresentationStyle = UIModalPresentationPopover;
    destNav.navigationBarHidden = YES;
    
    UIPopoverPresentationController *presentationController = [destNav popoverPresentationController];
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    presentationController.delegate = self;
    presentationController.sourceView = sender;
    presentationController.sourceRect = sender.bounds;
    
//    destNav.navigationBarHidden = YES;
//    _infoPopoverController = destNav.popoverPresentationController;
//    self.infoPopoverController.delegate = self;
//    self.infoPopoverController.sourceView = textField;
//    self.infoPopoverController.sourceRect = textField.bounds;

//    if (sender.tag == InfoControllerButtonInfoHourglass) {
//        infoController.buttonInfo = InfoControllerButtonInfoHourglass;
//    } else if (sender.tag == InfoControllerButtonInfoDelay) {
//        infoController.buttonInfo = InfoControllerButtonInfoDelay;
//    }
//    infoController.contentSize = contentSize;
    
    [self presentViewController:destNav animated:YES completion:nil];
    
}

@end
