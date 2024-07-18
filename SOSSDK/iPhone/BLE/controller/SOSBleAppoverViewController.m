//
//  SOSBleAppoverViewController.m
//  Onstar
//
//  Created by onstar on 2018/11/23.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleAppoverViewController.h"

@interface SOSBleAppoverViewController ()
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *remindButton;

@end

@implementation SOSBleAppoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.infoLabel.text = [NSString stringWithFormat:@"被授权人 %@",[Util recodesign:self.phone]];
}
- (IBAction)acceptButtonClick:(id)sender {
    
    if (self.remindButton.selected) {
        NSTimeInterval date = [NSDate date].timeIntervalSince1970;
        UserDefaults_Set_Object([NSNumber numberWithDouble:date], @"bleAcceptRemindKey");
    }
    !self.acceptBlock?:self.acceptBlock();
    [self dismiss:nil];
}

- (IBAction)remindButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
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
