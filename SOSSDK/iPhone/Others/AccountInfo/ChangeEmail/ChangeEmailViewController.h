//
//  ChangeEmailViewController.h
//  Onstar
//
//  Created by Vicky on 14-2-24.
//  Copyright (c) 2014年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppPreferences.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface ChangeEmailViewController : UIViewController<UITextFieldDelegate>{
    IBOutlet UILabel *labelTitle;
    IBOutlet UIImageView *backImage;
    
    IBOutlet TPKeyboardAvoidingScrollView *scroll;
    IBOutlet UILabel *labelOld;
    IBOutlet UITextField *fieldOld;
    IBOutlet UILabel *labelOldEmail;
    
    IBOutlet UILabel *labelNew;
    IBOutlet UITextField *fieldNew;
    IBOutlet UIButton *buttonSendCheck;
    IBOutlet UILabel *labelSendCheck;
    
    IBOutlet UITextField *fieldCheckCode;
    
    IBOutlet UILabel *labelMsg;
    IBOutlet UIButton *buttonOK;
    
    IBOutlet UILabel *labelOk;
    IBOutlet UIImageView *imgInput1;
    
    IBOutlet UIImageView *imginput2;
    IBOutlet UILabel *labelTipNew;
    IBOutlet UILabel *labelTipCode;
    UserRegisterAction action;
    BOOL timeStart;
}
@property (weak, nonatomic) IBOutlet UIView *upToView;
@property (weak, nonatomic) IBOutlet UIView *hidenoemail;
@property(nonatomic ,strong)NSString *oldEmail;
@property (weak, nonatomic) IBOutlet UILabel *tipLb;

- (IBAction)backButtonTapped:(id)sender;
- (IBAction)buttonSendCheckTapped:(id)sender;
- (IBAction)buttonOKTapped:(id)sender;
@end
