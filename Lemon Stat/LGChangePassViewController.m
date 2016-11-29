//
//  LGChangePassViewController.m
//  Lemon Stat
//
//  Created by Arkadiy Grigoryanc on 27.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGChangePassViewController.h"

#import <AFNetworking/AFNetworking.h>

#import "NSString+Request.h"

@interface LGChangePassViewController () <UITextFieldDelegate, UIResponderStandardEditActions>

@property (weak, nonatomic) IBOutlet UITextField *changePasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *changeRepeatedPasswordTextField;

@property (weak, nonatomic) IBOutlet UILabel *responseLabel;

@end

@implementation LGChangePassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //_currentPasswordTextField.text = _currentPassword;
    
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

#pragma mark - Request Methods

- (void)requestChangePassword {
    
    extern NSString *gToken;
    extern NSURL *baseURL;
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithBaseURL:baseURL];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:gToken forHTTPHeaderField:@"Auth-Token"];
    
    NSString *string = @"catalog/accounts/password";
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@30 forKey:@"id"];
    [parameters setObject:_changeRepeatedPasswordTextField.text forKey:@"password"];
    
    [manager PUT:string
      parameters:parameters
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSLog(@"%@", responseObject);
             NSLog(@"Пароль изменен");
             
             [self alertActionWithTitle:@"Пароль успешно изменен" andMessage:nil];
             
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
             
             [self alertActionWithTitle:@"Сервер не отвечает" andMessage:@"Попробуйте позже"];
             
         }];
}

#pragma mark - Methods

- (BOOL)verificationFillingOfFieldsForChangePassword {
    
    if (_changePasswordTextField.text.length == 0 || _changeRepeatedPasswordTextField.text.length == 0) {
        _responseLabel.text = @"Заполните все поля";
        return NO;
    } else if (![_changePasswordTextField.text isEqualToString:_changeRepeatedPasswordTextField.text]) {
        _responseLabel.text = @"Пароли не совпадают";
        return NO;
    }
    
    return YES;
}

#pragma mark - Alert Methods

- (void)alertActionWithTitle:(NSString *)title andMessage:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Ок"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - Actions

- (IBAction)actionChangeAndBack:(id)sender {
    
    if ([self verificationFillingOfFieldsForChangePassword]) {
        [self.view endEditing:YES];
        [self requestChangePassword];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _responseLabel.text = @"";
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:_changePasswordTextField]) {
        
        [_changeRepeatedPasswordTextField becomeFirstResponder];
        
    } else {
        
        [self actionChangeAndBack:nil];
        
    }
    return YES;
}

#pragma mark - UIResponderStandardEditActions

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
