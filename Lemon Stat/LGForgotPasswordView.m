//
//  LGForgotPasswordView.m
//  Lemon Stat
//
//  Created by Arkadiy Grigoryanc on 30.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGForgotPasswordView.h"

@implementation LGForgotPasswordView

- (void)dealloc {
    NSLog(@"LGForgotPasswordView dealocated");
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    NSInteger space = 8;
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                space,
                                                                CGRectGetWidth(rect),
                                                                21)];
    header.font = [UIFont boldSystemFontOfSize:21];
    header.textAlignment = NSTextAlignmentCenter;
    header.text = @"Всосстановление пароля";
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                CGRectGetMaxY(header.frame) + space,
                                                                CGRectGetWidth(rect),
                                                                30)];
    label1.font = [UIFont systemFontOfSize:10];
    label1.numberOfLines = 2;
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text = @"Введите адрес электронной почты, чтобы восстановить пароль";
    
    UITextField *eMailTextField = [[UITextField alloc] initWithFrame:CGRectMake(34,
                                                                                CGRectGetMaxY(label1.frame) + space,
                                                                                220,
                                                                                30)];
    eMailTextField.borderStyle = UITextBorderStyleRoundedRect;
    eMailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    eMailTextField.returnKeyType = UIReturnKeySend;
    eMailTextField.placeholder = @"Введите e-Mail";
    eMailTextField.delegate = self.delegate;
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                CGRectGetMaxY(eMailTextField.frame) + space,
                                                                CGRectGetWidth(rect),
                                                                30)];
    label2.font = [UIFont systemFontOfSize:10];
    label2.numberOfLines = 2;
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"На указанную почту будет отправленно письмо с новым паролем";
    
    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(34,
                                                                      CGRectGetMaxY(label2.frame) + space,
                                                                      220,
                                                                      39)];
    sendButton.backgroundColor = [UIColor colorWithRed:118/255 green:116/255 blue:93/255 alpha:1];
    sendButton.titleLabel.textColor = [UIColor whiteColor];
    sendButton.layer.cornerRadius = 5;
    [sendButton setTitle:@"Отправить" forState:UIControlStateNormal];
    
    if ([self.delegate respondsToSelector:@selector(actionRecoveryPassword:)]) {
        
        [sendButton addTarget:self.delegate
                       action:@selector(actionRecoveryPassword:)
             forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    UILabel *responseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                       CGRectGetMaxY(sendButton.frame) + space,
                                                                       CGRectGetWidth(rect),
                                                                       15)];
    responseLabel.font = [UIFont systemFontOfSize:10];
    responseLabel.numberOfLines = 2;
    responseLabel.textAlignment = NSTextAlignmentCenter;
    responseLabel.text = @"";
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.frame = CGRectMake(0,
                                  CGRectGetMaxY(responseLabel.frame) + space,
                                  50,
                                  30);
    backButton.center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(backButton.frame));
    [backButton setTitle:@"Назад" forState:UIControlStateNormal];
    
    if ([self.delegate respondsToSelector:@selector(actionBackToAuth:)]) {
        
        [backButton addTarget:self.delegate
                       action:@selector(actionBackToAuth:)
             forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    [self addSubview:header];
    [self addSubview:label1];
    [self addSubview:eMailTextField];
    [self addSubview:label2];
    [self addSubview:sendButton];
    [self addSubview:responseLabel];
    [self addSubview:backButton];
    
    self.eMailTextField = eMailTextField;
    self.responseLabel = responseLabel;
    
}

@end
