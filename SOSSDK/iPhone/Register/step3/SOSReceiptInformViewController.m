//
//  SOSReceiptInformViewController.m
//  Onstar
//
//  Created by Onstar on 2017/10/12.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSReceiptInformViewController.h"

@interface SOSReceiptInformViewController ()
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@end

@implementation SOSReceiptInformViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [SOSUtil onstarLightGray];
    self.title = @"上传购车发票";
    [SOSUtil setButtonStateEnableWithButton:_continueButton];
    NSLog(@"%@", NSStringFromCGRect(self.view.frame))

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"%@", NSStringFromCGRect(self.view.frame))

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"%@", NSStringFromCGRect(self.view.frame))
}

- (IBAction)continueClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    if (self.continueCompleteCallBack) {
        self.continueCompleteCallBack();
    }
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
