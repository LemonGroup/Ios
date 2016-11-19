//
//  LGAuthViewController.m
//  Lemon Stat
//
//  Created by decidion on 19.11.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import "LGAuthViewController.h"

@interface LGAuthViewController ()
@property (weak, nonatomic) IBOutlet UIButton *yellowLayerButton;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;

@end

@implementation LGAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.enterButton.layer.cornerRadius = 5;
    self.yellowLayerButton.layer.cornerRadius = 5;

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

@end
