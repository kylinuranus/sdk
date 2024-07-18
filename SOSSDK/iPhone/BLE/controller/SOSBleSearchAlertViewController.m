//
//  SOSBleSearchAlertViewController.m
//  Onstar
//
//  Created by onstar on 2018/10/18.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleSearchAlertViewController.h"

@interface SOSBleSearchAlertViewController ()
@property (weak, nonatomic) IBOutlet UILabel *attLabel1;
@property (weak, nonatomic) IBOutlet UILabel *attLabel2;
@property (weak, nonatomic) IBOutlet UILabel *attLabel3;

@end

@implementation SOSBleSearchAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc] initWithString:@"请打开\"收到的共享\"查看共享状态。"];
    NSMutableAttributedString *att2 = [[NSMutableAttributedString alloc] initWithString:@"请打开\"收到的共享\",找到想要使用的车并点"];
    NSMutableAttributedString *att3 = [[NSMutableAttributedString alloc] initWithString:@"击\"下载并连接\""];
    [att1 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"107fe0"] range:[att1.string rangeOfString:@"收到的共享"]];
    [att2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"107fe0"] range:[att2.string rangeOfString:@"收到的共享"]];
    [att3 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"107fe0"] range:[att3.string rangeOfString:@"下载并连接"]];
    
    self.attLabel1.attributedText = att1;
    self.attLabel2.attributedText = att2;
    self.attLabel3.attributedText = att3;

}
- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{

    }];
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
