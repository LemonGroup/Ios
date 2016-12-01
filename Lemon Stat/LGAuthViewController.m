//
//  LGAuthViewController.m
//  Lemon Stat
//
//  Created by decidion on 19.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGAuthViewController.h"

#import <AFNetworking/AFNetworking.h>

#import "NSString+Request.h"

#import "LGSiteListSingleton.h"
#import "LGSite.h"
#import "LGPersonListSingleton.h"
#import "LGPerson.h"

#import "LGForgotPasswordView.h"

typedef enum {
    LGAuthViewControllerButtonTypeJoin = 1,
    LGAuthViewControllerButtonTypeChangePass = 2
} LGAuthViewControllerButtonType;

@interface LGAuthViewController () <UITextFieldDelegate, UIResponderStandardEditActions, LGForgotPasswordViewDelegate> {
    NSNumber *_loginID;
}

@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) UITextField *changePasswordTextField;
@property (strong, nonatomic) UITextField *changeRepeatedPasswordTextField;

@property (weak, nonatomic) IBOutlet UILabel *responseLabel;

@property (weak, nonatomic) IBOutlet UIView *yellowAuthLayer;
@property (weak, nonatomic) LGForgotPasswordView *yellowForgotPassLayer;

@property (strong, nonatomic) IBOutlet UIButton *joinButton;

@end

@implementation LGAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // если пользователь заходил в приложение, он минует окно входа
    extern NSString *gToken;
    
    NSLog(@"%@", gToken);
    
    if (gToken) {
        
        if (![gToken isEqualToString:@"notToken"]) {
            [self requestGetSites];
            [self requestGetPersons];
            [self presentNavigationController];
        } else {
            [self archiveCurrentSetting];
        }
    }
    
    /*
    extern NSMutableArray *gTokens;
    NSLog(@"gTokens %@", gTokens);
    
    if ([gTokens containsObject:gToken]) {
        
        [self requestGetSites];
        [self requestGetPersons];
        [self presentNavigationController];
        
    } else {
        
        [self archiveCurrentSetting];
        
    }
     */
}

- (void)onKeyboardHide:(NSNotification *)notification {
    //keyboard will hide
    
    if (_changePasswordTextField) {     // если поле существует
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _yellowAuthLayer.transform = CGAffineTransformMakeTranslation(0, 0);
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIResponderStandardEditActions

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Requests Methods

- (void)requestAuth {
    
    extern NSURL *baseURL;
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithBaseURL:baseURL];
    
    NSString *urlString = [self stringForRequestAuth];
    
    [manager GET:urlString
      parameters:nil
        progress:nil
         success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
             if (responseObject) {
                 
                 NSLog(@"-------------------TOKEN-JSON: %@", responseObject);
                 
                 extern NSString *gToken;
                 gToken = [responseObject valueForKey:@"token"];
                 
                 [self archiveCurrentSetting];
                 [self requestGetSites];
                 [self requestGetPersons];
                 [self presentNavigationController];
                 
                 /*
                 extern NSMutableArray *gTokens;
                 extern NSInteger gGroupID;
                 extern NSInteger gPrivilege;
                 
                 gGroupID = [[responseObject valueForKey:@"groupId"] integerValue];
                 gPrivilege = [[responseObject valueForKey:@"privilege"] integerValue];
                 
                 if (![gTokens containsObject:gToken]) {
                     [gTokens addObject:gToken];
                 }
                 
                 // Архивируем токены
                 
                 // Проверка на первый запуск приложения
                 static NSString* const hasRunAppOnceKey = @"hasRunAppOnceKey";
                 NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                 if ([defaults boolForKey:hasRunAppOnceKey] == NO) {
                     // Some code you want to run on first use...
                     [self setNewPassword];
                     [_passwordTextField resignFirstResponder];
                 }
                 */
                 
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
             _responseLabel.text = @"Неверные логин и/или пароль";
         }];
}

- (NSString *)stringForRequestAuth {
    
    NSString *string = [NSString stringWithFormat:@"user/auth?user=%@&pass=%@",self.loginTextField.text,self.passwordTextField.text];
    
    return [string encodeURLString];
}

- (void)requestGetSites {
    
    extern NSString *gToken;
    extern NSURL *baseURL;
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithBaseURL:baseURL];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:gToken forHTTPHeaderField:@"Auth-Token"];
    
    NSString *string = @"catalog/sites";
    
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

- (void)requestGetPersons {
    
    extern NSString *gToken;
    extern NSURL *baseURL;
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithBaseURL:baseURL];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:gToken forHTTPHeaderField:@"Auth-Token"];
    
    NSString *string = @"catalog/persons";
    
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
    [parameters setObject:_loginID forKey:@"id"];
    [parameters setObject:_changeRepeatedPasswordTextField.text forKey:@"password"];
    
    [manager PUT:string
      parameters:parameters
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             [self alertActionWithTitle:@"Пароль изменен" andMessage:nil];
             
             [self presentNavigationController];
             NSLog(@"%@", responseObject);
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
             
             [self alertActionWithTitle:@"Сервер не отвечает" andMessage:@"Попробуйте позже"];
             
         }];
}

- (void)requestRecoveryPassword {
    
    extern NSURL *baseURL;
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithBaseURL:baseURL];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *string = @"catalog/accounts/reset_password";
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:_yellowForgotPassLayer.eMailTextField.text forKey:@"email"];
    
    [manager PUT:string
      parameters:parameters
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             [self alertActionWithTitle:@"Новый пароль выслан на указанный eMail" andMessage:nil];
             
             NSLog(@"%@", responseObject);
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
             
             [self alertActionWithTitle:@"Сервер не отвечает" andMessage:@"Попробуйте позже"];
             
         }];
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

#pragma mark - Methods

- (void)createSiteListWithJSONArray:(NSArray *)responseJSON {
    
    LGSiteListSingleton *siteList = [LGSiteListSingleton sharedSiteList];
    
    for (id obj in responseJSON) {
        
        LGSite *site = [LGSite siteWithID:[obj valueForKey:@"id"] andURL:[obj valueForKey:@"site"]];
        
        [siteList.sites addObject:site];
    }
    
    [siteList sortList];
}

- (void)createPersonListWithJSONArray:(NSArray *)responseJSON {
    
    LGPersonListSingleton *personList = [LGPersonListSingleton sharedPersonList];
    
    for (id obj in responseJSON) {
        
        LGPerson *person = [LGPerson personWithID:[obj valueForKey:@"id"] andName:[obj valueForKey:@"personName"]];
        
        [personList.persons addObject:person];
    }
    
    [personList sortList];
}

- (UITextField *)createTextField {
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0,
                                                                           CGRectGetWidth(_passwordTextField.frame),
                                                                           CGRectGetHeight(_passwordTextField.frame))];
    
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.center = _passwordTextField.center;
    textField.secureTextEntry = YES;
    textField.delegate = self;
    
    return textField;
}

- (void)setNewPassword {
    
    _loginTextField.enabled = NO;
    _passwordTextField.enabled = NO;
    
    UITextField *newPasswordTextField = [self createTextField];
    newPasswordTextField.returnKeyType = UIReturnKeyNext;
    [_yellowAuthLayer addSubview:newPasswordTextField];
    _changePasswordTextField = newPasswordTextField;
    
    UITextField *newRepeatedPasswordTextField = [self createTextField];
    newRepeatedPasswordTextField.returnKeyType = UIReturnKeyJoin;
    [_yellowAuthLayer addSubview:newRepeatedPasswordTextField];
    _changeRepeatedPasswordTextField = newRepeatedPasswordTextField;
    
    [_changePasswordTextField becomeFirstResponder];
    
    [self animationYellowLayout];
    
}

- (void)animationYellowLayout {
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         NSInteger space = 9;
                         
                         _yellowAuthLayer.transform = CGAffineTransformMakeTranslation(0, -155);
                         _yellowAuthLayer.frame = CGRectMake(CGRectGetMinX(_yellowAuthLayer.frame),
                                                             CGRectGetMinY(_yellowAuthLayer.frame),
                                                             CGRectGetWidth(_yellowAuthLayer.frame),
                                                             CGRectGetHeight(_yellowAuthLayer.frame) + CGRectGetHeight(_passwordTextField.frame) * 2 + space * 2);
                         
                         _joinButton.center = CGPointMake(CGRectGetMidX(_joinButton.frame),
                                                          CGRectGetMidY(_joinButton.frame) + CGRectGetHeight(_passwordTextField.frame) * 2 + space * 2);
                         
                         _responseLabel.center = CGPointMake(CGRectGetMidX(_responseLabel.frame),
                                                             CGRectGetMidY(_responseLabel.frame) + CGRectGetHeight(_passwordTextField.frame) * 2 + space * 2);
                         
                         _changePasswordTextField.center = CGPointMake(CGRectGetMidX(_changePasswordTextField.frame),
                                                                       CGRectGetMidY(_changePasswordTextField.frame) + CGRectGetHeight(_passwordTextField.frame) + space);
                         _changePasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Введите новый пароль"
                                                                                                      attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f]}];
                         
                         
                         _changeRepeatedPasswordTextField.center = CGPointMake(CGRectGetMidX(_changeRepeatedPasswordTextField.frame),
                                                                               CGRectGetMidY(_changeRepeatedPasswordTextField.frame) + CGRectGetHeight(_passwordTextField.frame) * 2 + space * 2);
                         _changeRepeatedPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Повторите новый пароль"
                                                                                                              attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f]}];
                         
                     }
                     completion:^(BOOL finished) {
                         _joinButton.titleLabel.text = @"Изменить";
                         _joinButton.tag = LGAuthViewControllerButtonTypeChangePass;
                     }];
    
}

- (void)presentNavigationController {
    
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

- (BOOL)verificationFillingOfFields {
    
    if ([_loginTextField.text length] == 0 && [_passwordTextField.text length] == 0) {
        _responseLabel.text = @"Введите логин и пароль";
    } else if ([_loginTextField.text length] == 0) {
        _responseLabel.text = @"Введите логин";
    } else if ([_passwordTextField.text length] == 0) {
        _responseLabel.text = @"Введите пароль";
    } else {
        return YES;
    }
    
    return NO;
}

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

- (void)createYellowForgotPassLayer {
    
    LGForgotPasswordView *yellowForgodPassLayer = [[LGForgotPasswordView alloc] initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds),
                                                                                                         CGRectGetMinY(_yellowAuthLayer.frame),
                                                                                                         CGRectGetWidth(_yellowAuthLayer.frame),
                                                                                                         CGRectGetHeight(_yellowAuthLayer.frame))];
    yellowForgodPassLayer.backgroundColor = _yellowAuthLayer.backgroundColor;
    yellowForgodPassLayer.delegate = self;
    
    [self.view addSubview:yellowForgodPassLayer];
    self.yellowForgotPassLayer = yellowForgodPassLayer;
    
}

- (void)disablTouch {
    /* Отключить тачи на время */
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
    });
}

#pragma mark - Animate Methods

- (void)animateForgotPasswordOpen:(BOOL)flag {
    
    [self disablTouch];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         NSInteger spaceTranslation = CGRectGetWidth(_yellowAuthLayer.frame) + (CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth(_yellowAuthLayer.frame)) / 2;
                         
                         CGAffineTransform traslation;
                         
                         if (flag) {
                             traslation = CGAffineTransformMakeTranslation(-spaceTranslation, 0);
                         } else {
                             traslation = CGAffineTransformMakeTranslation(0, 0);
                         }
                         
                         _yellowAuthLayer.transform = traslation;
                         _yellowForgotPassLayer.transform = traslation;
                     }
                     completion:^(BOOL finished) {
                         if (!flag) {
                             [_yellowForgotPassLayer removeFromSuperview];
                         }
                     }];
}

#pragma mark - Archiving

- (void)archiveCurrentSetting {
    
    extern NSString *gToken;
    NSDictionary *dict = @{@"currentToken" : gToken};
    
    NSLog(@"dict %@", dict);
    
    NSString *path = [NSString stringWithFormat:@"%@/tokens.arch", NSTemporaryDirectory()];
    [NSKeyedArchiver archiveRootObject:dict toFile:path];
    
    /*
    extern NSMutableArray *gTokens;
    NSDictionary *dict = @{@"tokens" : gTokens,
                           @"currentToken" : gToken};
    */
}

#pragma mark - Actions

- (IBAction)actionJoin:(UIButton *)sender {
    
    if ([self verificationFillingOfFields]) {
        
        switch (sender.tag) {
            
            case LGAuthViewControllerButtonTypeJoin: {
                
                [self requestAuth];
            }
                break;
            
            case LGAuthViewControllerButtonTypeChangePass: {
                
                if ([self verificationFillingOfFieldsForChangePassword]) {
                    
                    [_changeRepeatedPasswordTextField resignFirstResponder];
                    [self requestChangePassword];
                    
                }
                
            }
                break;
        }
    }
}

- (IBAction)actionForgotPassword:(UIButton *)sender {
    
    if (!_yellowForgotPassLayer) {
        
        [self createYellowForgotPassLayer];
        
        [self animateForgotPasswordOpen:YES];
        
    } else {
        
        [self animateForgotPasswordOpen:NO];
    
    }
}

- (void)actionRecoveryPassword:(id)sender {
    [self requestRecoveryPassword];
}

- (void)actionBackToAuth:(id)sender {
    [self animateForgotPasswordOpen:NO];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    _responseLabel.text = @"";
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (_changePasswordTextField) {     // если поле существует
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _yellowAuthLayer.transform = CGAffineTransformMakeTranslation(0, -155);
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:_loginTextField]) {
        
        [_passwordTextField becomeFirstResponder];
        
    } else if ([textField isEqual:_passwordTextField]) {
        
        [self actionJoin:_joinButton];
        
    } else if ([textField isEqual:_changePasswordTextField]) {
        
        [_changeRepeatedPasswordTextField becomeFirstResponder];
        
    } else if ([textField isEqual:_changeRepeatedPasswordTextField]) {
        
        [self actionJoin:_joinButton];
        
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

@end
