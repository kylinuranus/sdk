//
//  ChangePasswordViewController.h
//  Onstar
//
//  Created by Vicky on 14-1-15.
//  Copyright (c) 2014年 Shanghai Onstar. All rights reserved.
//

enum pageAction {
    CheckOldPassword = 0,
    ChangePassword =1 
    };
#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface ChangePasswordViewController : UIViewController<UITextFieldDelegate>     {
    IBOutlet UIImageView *backImage;
    IBOutlet TPKeyboardAvoidingScrollView *scrollView;
    IBOutlet UILabel *labelOld;
    IBOutlet UILabel *labelNew;
    IBOutlet UILabel *labelAgain;
    IBOutlet UITextField *fieldOld;
    IBOutlet UITextField *fieldNew;
    IBOutlet UITextField *fieldAgain;
    IBOutlet UILabel *labelTipOld;
    IBOutlet UILabel *labelTipNew;
    IBOutlet UILabel *labelTipAgain;
    IBOutlet UIButton *buttonOK;
    IBOutlet UIButton *buttonCancel;
    IBOutlet UILabel *labelOK;
    IBOutlet UILabel *labelCancel;
    enum pageAction action;
}
- (IBAction)buttonOKTapped:(id)sender;

@end
