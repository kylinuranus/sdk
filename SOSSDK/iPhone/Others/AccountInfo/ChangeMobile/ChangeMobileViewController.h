//
//  ChangeMobileViewController.h
//  Onstar
//
//  Created by Vicky on 14-1-16.
//  Copyright (c) 2014年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppPreferences.h"
#import "TPKeyboardAvoidingScrollView.h"
@interface ChangeMobileViewController : UIViewController<UITextFieldDelegate>     {
    
    IBOutlet UIImageView *backImage;
    IBOutlet UILabel *labelTitle;
    
    IBOutlet UILabel *labelOldMobile;
    IBOutlet TPKeyboardAvoidingScrollView *scroll;
    IBOutlet UILabel *labelOld;
    IBOutlet UITextField *fieldOld;
   

    IBOutlet UILabel *labelMsg;
  
    UserRegisterAction action;
    BOOL timeStart;
    
    IBOutlet UILabel *labelNew;
    IBOutlet UITextField *fieldNew;
    IBOutlet UIButton *buttonSendCheck;
    IBOutlet UILabel *labelSendCheck;
    
    IBOutlet UITextField *fieldCheckCode;
    IBOutlet UIButton *buttonOK;
    
    IBOutlet UILabel *labelOk;
    
    IBOutlet UILabel *labelTipNew;
    IBOutlet UILabel *labelTipCode;
    
    IBOutlet UIImageView *imgInput2;
    IBOutlet UIImageView *imgInput1;
    
}
@property (weak, nonatomic) IBOutlet UIView *upToView;

@property (weak, nonatomic) IBOutlet UIView *hideNoPhone;
@property (weak, nonatomic) IBOutlet UILabel *tipLb;
@property(nonatomic ,strong)NSString *oldMobile;

- (IBAction)backButtonTapped:(id)sender;
- (IBAction)buttonSendCheckTapped:(id)sender;
- (IBAction)buttonOKTapped:(id)sender;

@end
