//
//  SOSServicePwd.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/28.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSServicePwd.h"

@implementation SOSServicePwd

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *newValue = [self.tf.text mutableCopy];
    [newValue replaceCharactersInRange:range withString:string];
    if ([newValue length]< 6) {
        _buttonOK.enabled = NO;
    }
    else {
        _buttonOK.enabled = YES;
        if ([newValue length]> 6) {
            return NO;
        }
    }
    return YES;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [SOSUtilConfig setCancelBackKeyBoardWithTextField:self.tf target:self];
    self.isFlashSelected = YES;
    self.isHornSelected = YES;
    self.tf.delegate = self;
    self.tf.rightViewMode = UITextFieldViewModeAlways;
    self.tf.rightView = self.eyeBtn;

}

//- (IBAction)makeCall:(UIButton *)sender {
//    if (self.functionID) {
//        [SOSDaapManager sendActionInfo:self.functionID];
//    }
//    [SOSUtil callPhoneNumber:@"4008201188"];
//
//}

- (IBAction)onlineFeedback:(id)sender {
    if (_feedback) {
        _feedback();
    }
}

- (UIButton *)eyeBtn {
    if (!_eyeBtn)
    {
        UIImage *image = [UIImage imageNamed:@"eye"];
        UIImage *imageSel = [UIImage imageNamed:@"eye_click"];

        _eyeBtn = [UIButton buttonWithType:0];
        _eyeBtn.frame = CGRectMake(0, 0, image.size.width + 10, image.size.height);
        [_eyeBtn setImage:image forState:0];
        [_eyeBtn setImage:imageSel forState:UIControlStateSelected];
        [_eyeBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _eyeBtn;
}

- (void)CancelBackKeyboard:(id)sender {
    [self.tf resignFirstResponder];
}

- (void)click:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.tf.secureTextEntry = !sender.selected;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (void)setIsHornFlash:(BOOL)hornFlash {
    if (_isHornFlash != hornFlash) {
        _isHornFlash = hornFlash;
    }
    if (_isHornFlash) {
        self.viewHorn.hidden = NO;
        self.viewFlash.hidden = NO;
    }
}

- (IBAction)HornSelected:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (!sender.selected) {
        if(!_buttonFlash.selected){
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"hornOrLightMustChooseOne", @"") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ac0 = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"") style:UIAlertActionStyleCancel handler:nil];
            [ac addAction:ac0];
            [ac show];
            sender.selected = !sender.selected;
            return ;
        }
        _isHornSelected = NO;
        
    }else{
        _isHornSelected = YES;
    }
}

- (IBAction)FlashSelected:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (!sender.selected) {
        if(!_buttonHorn.selected){
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"hornOrLightMustChooseOne", @"") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ac0 = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"") style:UIAlertActionStyleCancel handler:nil];
            [ac addAction:ac0];
            [ac show];
            sender.selected = !sender.selected;
            return ;
        }
        _isFlashSelected = NO;
    }else{
        _isFlashSelected = YES;
    }
}


@end
