//
//  SOSPreferredTableViewCell.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/2.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSPreferredTableViewCell.h"
#import "SOSCustomAlertView.h"

@interface SOSPreferredTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *locateFailedLabel;
@end

@implementation SOSPreferredTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPushMapView:)];
    [_distanceLb addGestureRecognizer:tapGes];
    self.shouldShowDistance = YES;
    //在xib上拖拽手势会让tableView registerNib崩溃...系统bug
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPushMapView:)];
    [_detailLb addGestureRecognizer:tapGesture];
}


- (void)setFrame:(CGRect)frame{
    if (_switchToSearchStyle) {
        [super setFrame:frame];
        return;
    }
    frame.origin.y += 10;
    frame.size.height -= 10;
    [super setFrame:frame];
}

- (void)initCellWithResponse:(NNPreferDealerDataResponse *)response  {
    self.titleLb.text = response.dealerName;
    self.detailLb.text = response.address;
    [self.phoneNo setTitle:response.telephone forState:0];
    self.distanceLb.text = response.distance;
    self.distanceLb.adjustsFontSizeToFitWidth = YES;
    self.arrowImageView.image = [UIImage imageNamed:@"LBS_icon_arrow_right_passion_blue_idle"];
    _showArrow = YES;
    
}

- (void)initCellWithDealersResponse:(NSArray *)array withPath:(NSIndexPath *)path
{
    [self initCellWithDealersResponse:array
                             withPath:path
                      selectIndexPath:nil];
}

- (void)initCellWithDealersResponse:(NSArray *)array
                            withPath:(NSIndexPath *)path
                        selectIndexPath:(NSIndexPath *)selectIndexPath {
    NNDealers *response = [array objectAtIndex:path.section];
    self.titleLb.text = response.dealerName;
    self.detailLb.text = response.address;
    [self.phoneNo setTitle:response.telephone forState:0];
    self.distanceLb.text = [NSString stringWithFormat:@"%ld",(long)response.distance];
    self.distanceLb.adjustsFontSizeToFitWidth = YES;
    //    self.unit.text = response.distanceWithUnit;
//    if (selectIndexPath) {
//        if ([path isEqual:selectIndexPath]) {
//            //YES
//            self.arrowImageView.image = [UIImage imageNamed:@"icon_nav_correct_idle"];
//        }else {
//            //NO
//            self.arrowImageView.image = [UIImage imageNamed:@"icon_nav_correct_unselect"];
//        }
//    }else {
//        self.arrowImageView.image = [UIImage imageNamed:@"icon_arrow_right_passion_blue_idle"];
//    }
    self.arrowImageView.image = [UIImage imageNamed:@"LBS_icon_arrow_right_passion_blue_idle"];
    self.showArrow = YES;
    self.dealers = array;
}

- (void)initCellWithDealer:(NNDealers *)dealer withPath:(NSIndexPath *)path selectIndexPath:(NSIndexPath *)selectIndexPath {
    [self initCellWithDealer:dealer withPath:path selectIndexPath:selectIndexPath highlightString:nil];
}

- (void)initCellWithDealer:(NNDealers *)dealer withPath:(NSIndexPath *)path selectIndexPath:(NSIndexPath *)selectIndexPath highlightString:(NSString *)highlight {
    self.titleLb.text = dealer.dealerName;
    self.detailLb.text = dealer.address;
    NSString * telStr;
    if (dealer.telephone.isNotBlank && dealer.telephone.length > 5) {
        telStr = dealer.telephone;
    }else{
        telStr = @"暂无电话号码";
    }
    [self.phoneNo setTitle:telStr forState:UIControlStateNormal];
    self.distanceLb.text = [NSString stringWithFormat:@"%.1f",dealer.distance];
    self.distanceLb.adjustsFontSizeToFitWidth = YES;
    //    self.unit.text = response.distanceWithUnit;
    if (selectIndexPath) {
        if ([path isEqual:selectIndexPath]) {
            //YES
            self.arrowImageView.image = [UIImage imageNamed:@"icon_nav_correct_idle"];
        }else {
            //NO
            self.arrowImageView.image = [UIImage imageNamed:@"icon_nav_correct_unselect"];
        }
    }else {
        self.arrowImageView.image = [UIImage imageNamed:@"icon_nav_correct_unselect"];
    }
    //    self.dealers = array;
    _unit.hidden = !_shouldShowDistance;
    _distanceLb.hidden = !_shouldShowDistance;
    _locateFailedLabel.hidden = _shouldShowDistance;
    
    if (highlight) {
        NSRange range = [dealer.dealerName rangeOfString:highlight];
        if (range.location != NSNotFound) {
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:dealer.dealerName];
            [attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"107FE0"] range:range];
            _titleLb.attributedText = attr;
        }
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (_showArrow) {
        self.arrowImageView.image = [UIImage imageNamed:@"LBS_icon_arrow_right_passion_blue_idle"];
        [super setSelected:selected animated:animated];
        return;
    }
    if (selected) {
        self.arrowImageView.image = [UIImage imageNamed:@"icon_nav_correct_idle"];
    }   else    {
        self.arrowImageView.image = [UIImage imageNamed:@"icon_nav_correct_unselect"];
    }
    [super setSelected:selected animated:animated];
}


- (IBAction)callDealer:(id)sender {
    if (![_phoneNo.titleLabel.text isValidateTel]) {
        return;
    }
    SOSCustomAlertView *alert = [[SOSCustomAlertView alloc] initWithTitle:[NSString stringWithFormat:@"拨打经销商？\n%@",self.phoneNo.titleLabel.text] detailText:nil cancelButtonTitle:@"拨打" otherButtonTitles:@[@"取消"]];
    alert.pageModel = SOSAlertViewModelCallPhone_Icon;
    alert.backgroundModel = SOSAlertBackGroundModelWhite;
    alert.buttonClickHandle = ^(NSInteger clickIndex) {
        if (clickIndex == 0) {
            if (_isFromPrefer) {
                [SOSDaapManager sendActionInfo:Prfdealer_call];
            }else{
                [SOSDaapManager sendActionInfo:Dealeraptmt_call];

            }
            NSString *string = [NSString stringWithFormat:@"tel:%@", _phoneNo.titleLabel.text];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
        }
    };
    [alert show];
}

- (void)tapPushMapView:(UITapGestureRecognizer *)sender {
    if ([_delegate respondsToSelector:@selector(pushMapVc:)]) {
        [self.delegate pushMapVc:self.dealers[sender.view.tag]];
    }
}

@end
