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

@property (weak, nonatomic) IBOutlet UIView *layerForgotPass;

@property (weak, nonatomic) IBOutlet UITextField *changePasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *changeRepeatedPasswordTextField;

@property (weak, nonatomic) IBOutlet UILabel *responseLabel;

@end

@implementation LGChangePassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillShowNotification object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Observer

- (void)onKeyboardHide:(NSNotification *)notification {
    //keyboard will hide
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        if (_changePasswordTextField) {     // если поле существует
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
                                     _layerForgotPass.transform = CGAffineTransformMakeTranslation(0, 0);
                                 } else if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
                                     _layerForgotPass.transform = CGAffineTransformMakeTranslation(0, -100);
                                 }
                             }
                             completion:nil];
        }
        
    }
}

#pragma mark - Request Methods

- (void)requestChangePassword {
    
    extern NSString *gToken;
    extern NSURL *gBaseURL;
    extern NSString *gContentType;
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithBaseURL:gBaseURL];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:gToken forHTTPHeaderField:@"Auth-Token"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@; charset=UTF-8", gContentType] forHTTPHeaderField:@"Content-Type"];
    
    NSString *string = @"catalog/accounts/password";
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:_loginID forKey:@"id"];
    [parameters setObject:_changeRepeatedPasswordTextField.text forKey:@"password"];
    
    [manager PUT:string
      parameters:parameters
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSLog(@"%@", responseObject);
             NSLog(@"Пароль изменен");
             
             [self alertActionWithTitle:@"Пароль успешно изменен" andMessage:@"Новый пароль был выслан на e-Mail"];
             
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    _responseLabel.text = @"";
    return YES;
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
