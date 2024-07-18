//
//  SOSLBSListCardView.m
//  Onstar
//
//  Created by Coir on 2018/12/20.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSLBSListCardView.h"
#import "SOSDateFormatter.h"

@interface SOSLBSListCardView ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *funcButton;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *getLocationButton;

@end

@implementation SOSLBSListCardView

+ (instancetype)newCard		{
    SOSLBSListCardView *cardView = [[NSBundle SOSBundle] loadNibNamed:@"SOSLBSListCardView" owner:nil options:nil][0];
    return cardView;
}

- (void)setCardStatus:(SOSLBSListCardStatus)cardStatus	{
    if (_cardStatus == cardStatus)		return;
    _cardStatus = cardStatus;
    [self configSelfWithCardStatus];
}

- (void)setLbsInfo:(NNLBSDadaInfo *)lbsInfo	{
    if (_lbsInfo == lbsInfo)			return;
    _lbsInfo = lbsInfo;
    if (self.cardStatus == SOSLBSListCardStatus_Success) {
        dispatch_async_on_main_queue(^{
            SOSDateFormatter *formatter = [SOSDateFormatter sharedInstance];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *updateDate = [formatter dateFromString:lbsInfo.createts];
            NSString * resultDateString = [formatter dateStrWithDateFormat:@"yyyy年M月d日创建" Date:updateDate timeZone:nil];
            self.timeLabel.text = resultDateString;
            self.titleLabel.text = lbsInfo.devicename;
        });
    }
}

- (void)configSelfWithCardStatus	{
    BOOL isSuccess = NO;
    NSString *imgName = nil;
    NSString *detailTitle = nil;
    switch (self.cardStatus) {
        case SOSLBSListCardStatus_Loading:
            imgName = @"Trip_LBS_List_Loading";
            detailTitle = @"加载中..";
            break;
        case SOSLBSListCardStatus_Error:
            imgName = @"Trip_LBS_List_Reload";
            detailTitle = @"点击重新加载";
            
            break;
        case SOSLBSListCardStatus_Blank:
            imgName = @"Trip_LBS_List_Add_Device";
            detailTitle = @"添加新设备";
            
            break;
        case SOSLBSListCardStatus_Success:
            isSuccess = YES;
            break;
            
        default:
            break;
    }
    dispatch_async_on_main_queue(^{
        self.iconImgView.hidden = isSuccess;
        self.detailLabel.hidden = isSuccess;
        self.funcButton.hidden = isSuccess;
        if (imgName)		self.iconImgView.image = [UIImage imageNamed:imgName];
        if (detailTitle)	self.detailLabel.text = detailTitle;
        if (self.cardStatus == SOSLBSListCardStatus_Loading)	[self.iconImgView startRotating];
        else                                                 	[self.iconImgView endRotating];
        
        self.titleLabel.hidden = !isSuccess;
        self.timeLabel.hidden = !isSuccess;
        self.getLocationButton.hidden = !isSuccess;
    });
}

- (IBAction)getLocationnButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(getLBSLocationButtonTappedWithView:)]) {
        [self.delegate getLBSLocationButtonTappedWithView:self];
    }
}

- (IBAction)functionButtonTapped {
    switch (self.cardStatus) {
        // 添加新设备
        case SOSLBSListCardStatus_Blank:
            [SOSDaapManager sendActionInfo:TRIP_LBS_ADD];
            if (self.delegate && [self.delegate respondsToSelector:@selector(addLBSDeviceButtonTapped)]) {
                [self.delegate addLBSDeviceButtonTapped];
            }
            break;
        // 重新加载
        case SOSLBSListCardStatus_Error:
            if (self.delegate && [self.delegate respondsToSelector:@selector(refreshLBSListButtonTapped)]) {
                [self.delegate refreshLBSListButtonTapped];
            }
            break;
        default:
            return;
    }
}

@end
