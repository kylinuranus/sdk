//
//  NameInputViewController.m
//  Onstar
//
//  Created by lizhipan on 17/3/14.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "NameInputViewController.h"

@interface NameInputViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIImageView *warningImage;

@end

@implementation NameInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSDictionary *dict = @{NSForegroundColorAttributeName:[UIColor blackColor],
                           NSFontAttributeName : [UIFont systemFontOfSize:17]
                           };
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
//    self.navigationController.//navigationBar.translucent = NO;
    self.title = @"用户信息";
    _firstNameField.placeholder = @"请输入您的姓";
    _lastNameField.placeholder = @"请输入您的名";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)showWarning
{
    _tipLabel.hidden = NO;
    _warningImage.hidden = NO;
}
- (void)hideWarning
{
    _tipLabel.hidden = YES;
    _warningImage.hidden = YES;
}

- (IBAction)submitName:(id)sender {
    if ([Util trim:_firstNameField].length >0 && [Util trim:_lastNameField].length >0) {
        //submit
        //[[SOSReportService shareInstance] recordActionWithFunctionID:SwitchInfo3Vehicles_SubmitName];
        if (_completeBlock) {
            _completeBlock(_firstNameField.text,_lastNameField.text);
        }
        [self.navigationController popViewControllerAnimated:NO];

    }
    else
    {
        [self showWarning];
    }
}

#pragma mark ---UITextfield Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{
    if (!_tipLabel.hidden) {
        [self hideWarning];
    }
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
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
