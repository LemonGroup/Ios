//
//  LGForgotPasswordView.h
//  Lemon Stat
//
//  Created by Arkadiy Grigoryanc on 30.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LGForgotPasswordViewDelegate;

@interface LGForgotPasswordView : UIView

@property (weak, nonatomic) UITextField *eMailTextField;
@property (weak, nonatomic) UILabel *responseLabel;

@property (weak, nonatomic) id<LGForgotPasswordViewDelegate, UITextFieldDelegate> delegate;

@end

@protocol LGForgotPasswordViewDelegate <NSObject>

- (void)actionRecoveryPassword:(id)sender;
- (void)actionBackToAuth:(id)sender;

@end
