//
//  LGPopoverViewController.m
//  Lemon Stat
//
//  Created by Arkadiy Grigoryanc on 17.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGPopoverViewController.h"

@interface LGPopoverViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@end

@implementation LGPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.view.backgroundColor = [UIColor whiteColor];
    
    // create button
    [self createButton];
    
    
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

#pragma mark - Methods

- (void)createButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSInteger heightButton = 50;
    
    button.frame = CGRectMake(0,
                              self.preferredContentSize.height - heightButton,
                              self.preferredContentSize.width,
                              heightButton);
    
    [button setBackgroundColor:[UIColor yellowColor]];
    [button setTitle:@"Применить" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
//    [button addTarget:self
//               action:@selector(actionReturnKey:)
//     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
//    self.returnKeyButton = button;
    
}

@end
