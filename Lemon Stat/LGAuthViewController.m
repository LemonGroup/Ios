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

typedef enum {
    LGAuthViewControllerButtonTypeJoin = 1,
    LGAuthViewControllerButtonTypeChangePass = 2
} LGAuthViewControllerButtonType;

@interface LGAuthViewController () <UITextFieldDelegate, UIResponderStandardEditActions>

@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) UITextField *changePasswordTextField;
@property (strong, nonatomic) UITextField *changeRepeatedPasswordTextField;
@property (weak, nonatomic) IBOutlet UILabel *responseLabel;

@property (strong, nonatomic) IBOutlet UIView *yellowLayer;
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
//    extern NSMutableArray *gTokens;
    extern NSString *gToken;
    
    if (![gToken isEqualToString:@"notToken"]) {
        [self requestGetSites];
        [self requestGetPersons];
        [self presentNavigationController];
    } else {
        [self archiveCurrentSetting];
    }
    
//    NSLog(@"gTokens %@", gTokens);
    
//    if ([gTokens containsObject:gToken]) {
//        
//        [self requestGetSites];
//        [self requestGetPersons];
//        [self presentNavigationController];
//        
//    } else {
//        
//        [self archiveCurrentSetting];
//        
//    }
}

- (void)onKeyboardHide:(NSNotification *)notification {
    //keyboard will hide
    
    if (_changePasswordTextField) {     // если поле существует
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _yellowLayer.transform = CGAffineTransformMakeTranslation(0, 0);
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
//                 extern NSMutableArray *gTokens;
                 extern NSString *gToken;
                 extern NSInteger gGroupID;
                 extern NSInteger gPrivilege;
                 
                 gToken = [responseObject valueForKey:@"token"];
                 gGroupID = [[responseObject valueForKey:@"groupId"] integerValue];
                 gPrivilege = [[responseObject valueForKey:@"privilege"] integerValue];
                 
//                 if (![gTokens containsObject:gToken]) {
//                     [gTokens addObject:gToken];
//                 }
                 
                 // Архивируем токены
                 [self archiveCurrentSetting];
                 
//                 // Проверка на первый запуск приложения
//                 static NSString* const hasRunAppOnceKey = @"hasRunAppOnceKey";
//                 NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
//                 if ([defaults boolForKey:hasRunAppOnceKey] == NO) {
//                     // Some code you want to run on first use...
//                     [self setNewPassword];
//                     [_passwordTextField resignFirstResponder];
//                 }
                 
                 [self requestGetSites];
                 [self requestGetPersons];
                 
                 [self presentNavigationController];
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
//    [manager.requestSerializer setValue:@"this-is-fake-token" forHTTPHeaderField:@"Auth-Token"];
    
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
//    [manager.requestSerializer setValue:@"this-is-fake-token" forHTTPHeaderField:@"Auth-Token"];
    
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
    [manager.requestSerializer setValue:@"application/json; charset: UTF-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:gToken forHTTPHeaderField:@"Auth-Token"];
    
    NSString *string = @"catalog/accounts/password";
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@10 forKey:@"id"];
    [parameters setObject:_changeRepeatedPasswordTextField.text forKey:@"password"];
    
    [manager PUT:string
      parameters:parameters
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             [self presentNavigationController];
             NSLog(@"%@", responseObject);
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
         }];
}

#pragma mark - Methods

- (void)createSiteListWithJSONArray:(NSArray *)responseJSON {
    
    LGSiteListSingleton *siteList = [LGSiteListSingleton sharedSiteList];
    
    for (id obj in responseJSON) {
        
        LGSite *site = [LGSite siteWithID:[obj valueForKey:@"id"] andURL:[obj valueForKey:@"site"]];
        
        [siteList.sites addObject:site];
    }
}

- (void)createPersonListWithJSONArray:(NSArray *)responseJSON {
    
    LGPersonListSingleton *personList = [LGPersonListSingleton sharedPersonList];
    
    for (id obj in responseJSON) {
        
        LGPerson *person = [LGPerson personWithID:[obj valueForKey:@"id"] andName:[obj valueForKey:@"personName"]];
        
        [personList.persons addObject:person];
    }
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
    [_yellowLayer addSubview:newPasswordTextField];
    _changePasswordTextField = newPasswordTextField;
    
    UITextField *newRepeatedPasswordTextField = [self createTextField];
    newRepeatedPasswordTextField.returnKeyType = UIReturnKeyJoin;
    [_yellowLayer addSubview:newRepeatedPasswordTextField];
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
                         
                         _yellowLayer.transform = CGAffineTransformMakeTranslation(0, -155);
                         _yellowLayer.frame = CGRectMake(CGRectGetMinX(_yellowLayer.frame),
                                                         CGRectGetMinY(_yellowLayer.frame),
                                                         CGRectGetWidth(_yellowLayer.frame),
                                                         CGRectGetHeight(_yellowLayer.frame) + CGRectGetHeight(_passwordTextField.frame) * 2 + space * 2);
                         
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

#pragma mark - Archiving

- (void)archiveCurrentSetting {
    
//    extern NSMutableArray *gTokens;
    extern NSString *gToken;
    
    NSDictionary *dict = @{@"currentToken" : gToken};
    
//    NSDictionary *dict = @{@"tokens" : gTokens,
//                           @"currentToken" : gToken};
    
    NSLog(@"dict %@", dict);
    
    NSString *path = [NSString stringWithFormat:@"%@/tokens.arch", NSTemporaryDirectory()];
    [NSKeyedArchiver archiveRootObject:dict toFile:path];
    
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
            default:
                break;
        }
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _responseLabel.text = @"";
    
    if (_changePasswordTextField) {     // если поле существует
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _yellowLayer.transform = CGAffineTransformMakeTranslation(0, -155);
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
