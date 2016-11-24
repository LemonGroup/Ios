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

@interface LGAuthViewController () <UITextFieldDelegate, UIResponderStandardEditActions>

@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *responseLabel;

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

#pragma mark - UIResponderStandardEditActions

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Requests Methods

- (void)requestAuth {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *requestString = [self requestString];
    
    [manager GET:requestString
      parameters:nil
        progress:nil
         success:^(NSURLSessionTask * _Nonnull task, id  _Nullable responseObject) {
             if (responseObject) {
                 
                 NSLog(@"-------------------TOKEN-JSON: %@", responseObject);
                 extern NSString *gToken;
                 extern NSInteger gGroupID;
                 extern NSInteger gPrivilege;
                 
                 gToken = [responseObject valueForKey:@"token"];
                 gGroupID = [[responseObject valueForKey:@"groupId"] integerValue];
                 gPrivilege = [[responseObject valueForKey:@"privilege"] integerValue];
                 
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

- (NSString *)requestString {
    
    NSString *string = [NSString stringWithFormat:@"http://yrsoft.cu.cc:8080/user/auth?user=%@&pass=%@",self.loginTextField.text,self.passwordTextField.text];
    
    return [string encodeURLString];
}

- (void)requestGetSites {
    
    extern NSString *gToken;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:gToken forHTTPHeaderField:@"Auth-Token"];
    
    NSString *string = @"http://yrsoft.cu.cc:8080/catalog/sites";
    
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

- (void)createSiteListWithJSONArray:(NSArray *)responseJSON {
    
    LGSiteListSingleton *siteList = [LGSiteListSingleton sharedSiteList];
    
    for (id obj in responseJSON) {
        
        LGSite *site = [LGSite siteWithID:[obj valueForKey:@"id"] andURL:[obj valueForKey:@"site"]];
        
        [siteList.sites addObject:site];
    }
}

- (void)requestGetPersons {
    
    extern NSString *gToken;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:gToken forHTTPHeaderField:@"Auth-Token"];
    
    NSString *string = @"http://yrsoft.cu.cc:8080/catalog/persons";
    
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

- (void)createPersonListWithJSONArray:(NSArray *)responseJSON {
    
    LGPersonListSingleton *personList = [LGPersonListSingleton sharedPersonList];
    
    for (id obj in responseJSON) {
        
        LGPerson *person = [LGPerson personWithID:[obj valueForKey:@"id"] andName:[obj valueForKey:@"personName"]];
        
        [personList.persons addObject:person];
    }
}

#pragma mark - Methods

- (void)presentNavigationController {
    
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
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

@end
