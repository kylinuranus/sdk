//
//  SOSOilOrderCell.m
//  Onstar
//
//  Created by Coir on 2019/8/19.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSOilOrderCell.h"
#import "SOSDateFormatter.h"

@interface SOSOilOrderCell ()

@property (weak, nonatomic) IBOutlet UILabel *oliTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *orderPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *originPriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *stationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderPhoneNumLabel;

@property (weak, nonatomic) IBOutlet UIImageView *orderStatusImgView;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;

@end

@implementation SOSOilOrderCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setOrder:(SOSOilOrder *)order	{
    _order = [order copy];
    dispatch_async_on_main_queue(^{
        self.oliTypeLabel.text = [NSString stringWithFormat:@"%@汽油", order.oilNo];
        if (order.orderTime.length) {
            NSDate *date = [[SOSDateFormatter sharedInstance] style4_dateFromString:order.orderTime];
            self.orderTimeLabel.text = [[SOSDateFormatter sharedInstance] dateStrWithDateFormat:@"yyyy.MM.dd HH:mm" Date:date timeZone:nil];
        }	else	{
            self.orderTimeLabel.text = @"--";
        }
        self.orderPriceLabel.text = order.amountPay;
        self.originPriceLabel.text = order.amountGun;
        [self configOriginPriceLabel];
        self.stationNameLabel.text = order.gasName;
        self.orderNumLabel.text = [NSString stringWithFormat:@"订单号:%@", order.orderId];
        self.orderPhoneNumLabel.text = [NSString stringWithFormat:@"订单手机号:%@", order.phone];
        self.orderStatusLabel.text = order.orderStatusName;
        // 订单状态    (1, "已支付"， 4, "退款申请中"， 5, "已退款"， 6, "退款失败")
        [self setOrderState:order.orderStatusName];
    });
}

/// 订单状态    (1, "已支付"， 4, "退款申请中"， 5, "已退款"， 6, "退款失败")
- (void)setOrderState:(NSString *)orderState	{
    NSString *imgName = @"";
    if ([orderState isEqualToString:@"已支付"]) {
        imgName = @"Trip_OilStation_order_Paid";
    }    else if ([orderState isEqualToString:@"退款申请中"])    {
        imgName = @"Trip_OilStation_order_Refunding";
    }    else if ([orderState isEqualToString:@"已退款"])    {
        imgName = @"Trip_OilStation_order_Refund_successfully";
    }    else if ([orderState isEqualToString:@"退款失败"])    {
        imgName = @"Trip_OilStation_order_Refund_failed";
    }
/*
    switch (orderState) {
        case 1:
            imgName = @"Trip_OilStation_order_Paid";
            break;
        case 4:
            imgName = @"Trip_OilStation_order_Refunding";
            break;
        case 5:
            imgName = @"Trip_OilStation_order_Refund_successfully";
            break;
        case 6:
            imgName = @"Trip_OilStation_order_Refund_failed";
            break;
        default:
            break;
    }
*/
    self.orderStatusImgView.image = [UIImage imageNamed:imgName];
}

- (void)configOriginPriceLabel	{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.originPriceLabel.text];
    [attrStr addAttributes:@{NSFontAttributeName:self.originPriceLabel.font,
                             NSStrikethroughStyleAttributeName:@(NSUnderlineStyleThick|NSUnderlinePatternSolid),
                             NSStrikethroughColorAttributeName:[UIColor colorWithHexString:@"828389"]}
                     range:NSMakeRange(0, attrStr.length)];
    self.originPriceLabel.attributedText = attrStr;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
