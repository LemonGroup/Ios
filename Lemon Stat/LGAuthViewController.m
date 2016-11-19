//
//  LGAuthViewController.m
//  Lemon Stat
//
//  Created by decidion on 19.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGAuthViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface LGAuthViewController ()
@property (weak, nonatomic) IBOutlet UIView *yellowLayer;

@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@end

@implementation LGAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.enterButton.layer.cornerRadius = 5;
    self.yellowLayer.layer.cornerRadius = 5;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)enterButton:(id)sender {
    
    NSString * urlString = [NSString stringWithFormat:@"http://yrsoft.cu.cc:8080/user/auth?user=%@&pass=%@",self.loginTextField.text,self.passwordTextField.text];
    //NSString * token;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:urlString
      parameters:nil
        progress:^(NSProgress * _Nonnull downloadProgress) {
            
        }
         success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
             
             NSLog(@"TOKEN-JSON: %@", responseObject[@"token"]);
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
         }];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
