//
//  SOSRemoteView.m
//  Onstar
//
//  Created by Coir on 2018/6/20.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSRemoteView.h"

@interface SOSRemoteView ()
@property (weak, nonatomic) IBOutlet UIView *remoteStartBGView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteStartBGViewHeightGuide;
@property (weak, nonatomic) IBOutlet UIButton *unlockButton;
@property (weak, nonatomic) IBOutlet UIButton *lockButton;
@property (weak, nonatomic) IBOutlet UIButton *remoteStartButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelRemoteStartButton;
@property (weak, nonatomic) IBOutlet UIButton *alertButton;
@property (weak, nonatomic) IBOutlet UIButton *instructionButton;

@end

@implementation SOSRemoteView

- (void)awakeFromNib	{
    [super awakeFromNib];
    NSArray *buttonArray = @[_lockButton, _unlockButton, _remoteStartButton, _cancelRemoteStartButton];
    SOSRemoteOperationType beginType = SOSRemoteOperationType_LockCar;
    for (int i = 0; i < buttonArray.count; i++) {
        UIButton *button = buttonArray[i];
        button.tag = i + beginType + 1000;
    }
    _alertButton.tag = 1000 + SOSRemoteOperationType_LightAndHorn;
    //不支持远程启动，去除
    if(![CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.remoteStartSupported){
        self.remoteStartBGView.hidden = YES;
        self.remoteStartBGViewHeightGuide.constant = 0;
    }    else    {
        self.remoteStartBGView.hidden = NO;
        self.remoteStartBGViewHeightGuide.constant = 125;
    }
    [self.instructionButton addUnderlineTitle];
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
