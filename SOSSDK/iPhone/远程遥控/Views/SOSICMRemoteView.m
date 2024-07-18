//
//  SOSICMRemoteView.m
//  Onstar
//
//  Created by Coir on 2018/4/27.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSICMRemoteView.h"

@interface SOSICMRemoteView ()

@property (weak, nonatomic) IBOutlet UILabel *authorizedDetailLabel;
@property (weak, nonatomic) IBOutlet UIView *roofWindowBGView;
@property (weak, nonatomic) IBOutlet UIImageView *sunroofIconImgView;
@property (weak, nonatomic) IBOutlet UIView *sideWindowBGView;
@property (weak, nonatomic) IBOutlet UIImageView *sideWindowIconImgView;
@property (weak, nonatomic) IBOutlet UIView *trunkBGView;
@property (weak, nonatomic) IBOutlet UIImageView *trunkIconImgView;

@property (weak, nonatomic) IBOutlet UIButton *openRoofWindowButton;
@property (weak, nonatomic) IBOutlet UIButton *closeRoofWindowButton;
@property (weak, nonatomic) IBOutlet UIButton *openWindowButton;
@property (weak, nonatomic) IBOutlet UIButton *closeWindowButton;
@property (weak, nonatomic) IBOutlet UIButton *openTrunkButton;

@property (weak, nonatomic) IBOutlet UIButton *instructionButton;

@property (nonatomic, assign) float topValue;

@end

@implementation SOSICMRemoteView

- (void)awakeFromNib	{
    [super awakeFromNib];
    NSArray *buttonArray = @[_openRoofWindowButton, _closeRoofWindowButton, _openWindowButton, _closeWindowButton, _openTrunkButton];
    SOSRemoteOperationType beginType = SOSRemoteOperationType_OpenRoofWindow;
    for (int i = 0; i < buttonArray.count; i++) {
        UIButton *button = buttonArray[i];
        button.tag = i + beginType + 1000;
    }
}

- (void)resetFrame	{
    [self resetFrameWithTopValue:0];
}

/// 隐藏置顶位置的按钮 (0 -2 分别对应 天窗, 车窗, 后备箱)
- (void)resetFrameWithTopValue:(float)topValue	{
    _topValue = topValue;
    SOSVehicle *vehicle = [CustomerInfo sharedInstance].currentVehicle;
    float gapValue = (IS_IPHONE && SCREEN_MAX_LENGTH <= 568.0) ? 0.f : 30.f;
    if (vehicle.openSunroofSupported == NO) {
        self.roofWindowBGView.hidden = YES;
    }    else    {
        self.roofWindowBGView.top = _topValue;
        _topValue = self.sunroofIconImgView.bottom + gapValue;
        self.openRoofWindowButton.height = self.openRoofWindowButton.width / 116.f * 50.f;
        self.closeRoofWindowButton.height = self.closeRoofWindowButton.width / 116.f * 50.f;
        self.openRoofWindowButton.centerY = self.roofWindowBGView.height / 2;
        self.closeRoofWindowButton.centerY = self.roofWindowBGView.height / 2;
    }
    if (vehicle.openWindowSupported == NO) {
        self.sideWindowBGView.hidden = YES;
    }    else    {
        self.sideWindowBGView.top = _topValue;
        _topValue = self.sideWindowBGView.bottom + gapValue;
        self.openWindowButton.height = self.openWindowButton.width / 116.f * 50.f;
        self.closeWindowButton.height = self.closeWindowButton.width / 116.f * 50.f;
        self.openWindowButton.centerY = self.sideWindowBGView.height / 2;
        self.closeWindowButton.centerY = self.sideWindowBGView.height / 2;
    }
    if (vehicle.openTrunkSupported == NO) {
        self.trunkBGView.hidden = YES;
    }    else    {
        self.trunkBGView.top = _topValue;
        self.trunkIconImgView.width = MIN(self.sunroofIconImgView.width, self.sideWindowIconImgView.width);
        self.trunkIconImgView.height = self.trunkIconImgView.width;
        self.trunkIconImgView.centerX = self.trunkBGView.width / 2;
        self.openTrunkButton.width = MIN(self.openRoofWindowButton.width, self.openWindowButton.width);
        self.openTrunkButton.height = self.openTrunkButton.width / 116.f * 50.f;
        self.openTrunkButton.centerX = self.trunkBGView.width / 2;
        self.openTrunkButton.top = self.trunkIconImgView.bottom + 15;
        self.trunkBGView.height = self.trunkIconImgView.height + self.openTrunkButton.height + 35;
        _topValue = self.trunkBGView.bottom + gapValue;
    }
    
    [self.instructionButton addUnderlineTitle];
    [self resetBottomItemPosition];
}

- (void)showAuthorizedDetailLabel:(BOOL)show	{
    self.authorizedDetailLabel.hidden = !show;
    if (show) {
        [self resetFrameWithTopValue:50.f];
        if ([CustomerInfo sharedInstance].carSharingFlag)	{
            [self.authorizedDetailLabel setText:NSLocalizedString(@"carSharingAuthorizedDetail", nil)];
        }	else	{
            [self.authorizedDetailLabel setText:NSLocalizedString(@"carSharingUnAuthorizedDetail", nil)];
        }
    }	else	[self resetFrameWithTopValue:0.f];
}

- (void)resetBottomItemPosition		{
    // 适配 4s
    if (!IS_IPHONE_4_OR_LESS) {
        self.instructionButton.bottom = self.viewController.view.height - 10 - 47;
        self.lastOperationLabel.bottom = self.instructionButton.top - 20;
    }
}

- (IBAction)operationButtonTapped:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:
       	@selector(operationButtonTapped:)]) {
        [self.delegate operationButtonTapped:sender];
    }
}

- (IBAction)instructionButtonTapped:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:
    	@selector(operationButtonTapped:)]) {
        [self.delegate operationButtonTapped:sender];
    }
}

@end
