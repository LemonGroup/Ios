//
//  LGAuthViewController.m
//  Lemon Stat
//
//  Created by decidion on 19.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGAuthViewController.h"
#import <AFNetworking/AFNetworking.h>

#import "LGTabBarController.h"

#import "NSString+Request.h"

@interface LGAuthViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *responseLabel;

@property (strong, nonatomic) NSString *token;
@property (assign, nonatomic) NSInteger groupID;
@property (assign, nonatomic) NSInteger privilege;

@end

@implementation LGAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Requests

- (void)requestAuth {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *requestString = [self requestString];
    
    [manager GET:requestString
      parameters:nil
        progress:nil
         success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
             NSLog(@"success");
             if (responseObject) {
                                  
                 _token = [responseObject valueForKey:@"token"];
                 _groupID = [[responseObject valueForKey:@"groupId"] integerValue];
                 _privilege = [[responseObject valueForKey:@"privilege"] integerValue];
                 
                 [self presentNavigationController];
                 NSLog(@"++");
             } else {
                 
                 _responseLabel.text = @"Неверное сочитание логина и пароля";
                 NSLog(@"--");
             }
             
             NSLog(@"-------------------TOKEN-JSON: %@", responseObject);
             
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
         }];
}

- (NSString *)requestString {
    
    NSString *string = [NSString stringWithFormat:@"http://yrsoft.cu.cc:8080/user/auth?user=%@&pass=%@",self.loginTextField.text,self.passwordTextField.text];
    
    return [string encodeURLString];
}

#pragma mark - Actions

- (BOOL)verificationFillingOfFields {
    
    if ([_loginTextField.text length] == 0 && [_passwordTextField.text length] == 0) {
        _responseLabel.text = @"Введите логин и пароль";
        return NO;
    } else if ([_loginTextField.text length] == 0) {
        _responseLabel.text = @"Введите логин";
        return NO;
    } else if ([_passwordTextField.text length] == 0) {
        _responseLabel.text = @"Введите пароль";
        return NO;
    }
    
    return YES;
}

- (IBAction)actionJoin:(id)sender {
    
    if ([self verificationFillingOfFields]) {
        [self requestAuth];
    }
}

- (void)presentNavigationController {
        
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _responseLabel.text = @"";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:_loginTextField]) {
        
        [_passwordTextField becomeFirstResponder];
        
    } else if ([textField isEqual:_passwordTextField]) {
        
        [_passwordTextField resignFirstResponder];
        
        [self actionJoin:nil];
        
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (IBAction)loginpassEdittingChanged:(id)sender {
//    
//    if([self.loginTextField.text length] == 0 || [self.passwordTextField.text length] == 0) {
//        self.enterButton.userInteractionEnabled = NO;
//    } else {
//        self.enterButton.userInteractionEnabled = YES;
//    }
//}

@end
