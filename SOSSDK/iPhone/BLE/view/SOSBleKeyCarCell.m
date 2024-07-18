//
//  SOSBleKeyCarCell.m
//  Onstar
//
//  Created by onstar on 2018/7/30.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleKeyCarCell.h"
#import "SOSBleUtil.h"

@interface SOSBleKeyCarCell ()

@property (weak, nonatomic) IBOutlet UILabel *vinLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorType;
@property (weak, nonatomic) IBOutlet UIImageView *carLogoImageView;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;


@end

@implementation SOSBleKeyCarCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBleEntity:(BLEModel *)bleEntity {
    _bleEntity = bleEntity;
//    NSString *vinText = [bleEntity.BleName stringByReplacingOccurrencesOfString:@"SGM " withString:@"VIN SGM******"];
    
    NSString *vin = [SOSBleUtil getFullVinWithBleName:bleEntity.BleName];
    
    self.vinLabel.text = [SOSBleUtil recodesign:vin];
    NSString *statusLableText = bleEntity.bConnectStatus?@"用车":@"连接";
    [self.statusButton setTitle:statusLableText forState:UIControlStateNormal];
    self.statusButton.backgroundColor = [SOSUtil onstarButtonEnableColor];
}

- (IBAction)opetationButtonTap:(UIButton *)sender {
    !self.operationButtonTapBlock?:self.operationButtonTapBlock(sender);
//    if (!self.bleEntity.bConnectStatus) {
//        [sender setTitle:@"正在连接..." forState:UIControlStateNormal];
//        sender.backgroundColor = [SOSUtil onstarButtonDisableColor];
//    }
}


@end
