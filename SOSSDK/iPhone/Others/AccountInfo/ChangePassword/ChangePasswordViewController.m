//
//  ChangePasswordViewController.m
//  Onstar
//
//  Created by Vicky on 14-1-15.
//  Copyright (c) 2014年 Shanghai Onstar. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "Util.h"
#import "CustomerInfo.h"
 
#import "LoadingView.h"
#import "DataObject.h"
#import "AccountInfoUtil.h"
#import "SOSKeyChainManager.h"

@interface ChangePasswordViewController ()
@end

@implementation ChangePasswordViewController

- (void)initForiPhone{
    buttonOK.layer.masksToBounds = YES;
    buttonOK.layer.cornerRadius = 3;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (IS_IPHONE_5 | IS_IPHONE_4_OR_LESS) {
        scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 440);
    }

    scrollView.type = TPKeyboardAvoidingScrollViewTypeAdjust;
    scrollView.scrollEnabled = YES;
    

    self.title = NSLocalizedString(@"Change_Password", nil);
    labelOld.text =NSLocalizedString(@"PasswordOld", nil);
    labelNew.text = NSLocalizedString(@"PasswordNew", nil);
    labelAgain.text = NSLocalizedString(@"PasswordAgain", nil);
    labelOK.text = NSLocalizedString(@"pwdSubmit", nil);
    labelCancel.text = NSLocalizedString(@"Cancel", nil);
    labelOld.adjustsFontSizeToFitWidth = YES;
    labelNew.adjustsFontSizeToFitWidth = YES;
    labelAgain.adjustsFontSizeToFitWidth = YES;
    
    labelTipNew.adjustsFontSizeToFitWidth = YES;
    labelTipOld.adjustsFontSizeToFitWidth = YES;
    labelTipAgain.adjustsFontSizeToFitWidth = YES;
    [self text:NSLocalizedString(@"6to20", @"") Label:labelTipOld forError:NO];
    [self text:NSLocalizedString(@"6to20", @"") Label:labelTipNew forError:NO];
    
    fieldOld.returnKeyType = UIReturnKeyNext;
    fieldNew.returnKeyType = UIReturnKeyDone;
    fieldOld.clearButtonMode =UITextFieldViewModeWhileEditing;
    fieldNew.clearButtonMode =UITextFieldViewModeWhileEditing;
    fieldAgain.clearButtonMode =UITextFieldViewModeWhileEditing;
    fieldOld.placeholder = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"PleaseInput", nil),NSLocalizedString(@"PasswordOld", nil)];
    fieldNew.placeholder = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"PleaseInput", nil),NSLocalizedString(@"PasswordNew", nil)];
    fieldAgain.placeholder = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"PleaseInput", nil),NSLocalizedString(@"PasswordAgain", nil)];
    // 自定义的view
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 25)];
    customView.backgroundColor = [UIColor clearColor];
    fieldOld.inputAccessoryView = customView;
    fieldNew.inputAccessoryView = customView;
    fieldAgain.inputAccessoryView = customView;
    // 往自定义view中添加各种UI控件(以UIButton为例)
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(customView.frame.size.width-35, -4, 35, 29)];
    [btn setImage:[UIImage imageNamed:@"down_normal.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"down_highlight.png"] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:@"down_highlight.png"] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(CancelBackKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:btn];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initForiPhone];
}

- (IBAction)switch1Changed:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    [fieldOld resignFirstResponder];
    if(!sender.selected)
    {
        fieldOld.secureTextEntry = YES;
        NSString* text = fieldOld.text;
        fieldOld.text = @" ";
        fieldOld.text = text;
    }else
    {
        fieldOld.secureTextEntry = NO;
        NSString* text = fieldOld.text;
        fieldOld.text = @" ";
        fieldOld.text = text;
    }
}

- (IBAction)switchChanged:(UIButton *)sender {
    sender.selected = !sender.selected;

    [fieldNew resignFirstResponder];
    if(!sender.selected)
    {
        fieldNew.secureTextEntry = YES;
        NSString* text = fieldNew.text;
        fieldNew.text = @" ";
        fieldNew.text = text;
    }else
    {
        fieldNew.secureTextEntry = NO;
        NSString* text = fieldNew.text;
        fieldNew.text = @" ";
        fieldNew.text = text;
    }
}

- (void)CancelBackKeyboard:(id)sender     {
    [fieldOld resignFirstResponder];
    [fieldNew resignFirstResponder];
    [fieldAgain resignFirstResponder];
}

- (void)text:(NSString *)text Label:(UILabel *)label forError:(BOOL)error     {
    if (error) {
        label.textColor = [UIColor redColor];
    } else {
        label.textColor = [UIColor grayColor];
    }
    label.text = text;
}

#pragma mark - textfield
- (void)textFieldDidBeginEditing:(UITextField *)textField     {
    [scrollView adjustOffsetToIdealIfNeeded];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.tag == 0 )
    {
        [fieldNew becomeFirstResponder];
    }
    if(textField.tag == 1 )
    {
        [self buttonOKTapped:nil];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField     {
    if (textField == fieldOld) {
        if ([[Util trim:fieldOld]length] < 1) {
            [self text:NSLocalizedString(@"NullField", @"") Label:labelTipOld forError:YES];
//            buttonOK.enabled = NO;
            return;
        }
        else{
            bool showAlert =[Util isValidatePassword:[Util trim:fieldOld]];
            if(!showAlert){
                [self text:NSLocalizedString(@"passwordFormat", @"") Label:labelTipOld forError:YES];
//                buttonOK.enabled = NO;
                return;
            }
        }
        labelTipOld.text = @"";
        [self text:NSLocalizedString(@"6to20", @"") Label:labelTipOld forError:NO];
//        buttonOK.enabled = NO;
    }
    else if(textField == fieldNew)
    {
        if ([[Util trim:fieldNew]length] < 1) {
            [self text:NSLocalizedString(@"NullField", @"") Label:labelTipNew forError:YES];
//            buttonOK.enabled = NO;
            return;
        }
        else{
            bool showAlert =[Util isValidatePassword:[Util trim:fieldNew]];
            if(!showAlert){
                [self text:NSLocalizedString(@"passwordFormat", @"") Label:labelTipNew forError:YES];
                return;
            }
            if([[Util trim:fieldNew] isEqualToString:[Util trim:fieldOld]])
            {
                [self text:NSLocalizedString(@"SB022_MSG014", @"") Label:labelTipNew forError:YES];
//                buttonOK.enabled = NO;
                return;
            }
        }
        [self text:NSLocalizedString(@"6to20", @"") Label:labelTipNew forError:NO];
//        buttonOK.enabled = YES;
    }
    else if(textField == fieldAgain)
    {
        if ([[Util trim:fieldAgain]length] < 1) {
            labelTipAgain.text =NSLocalizedString(@"NullField", @"");
            return;
        }
        else{
            bool showAlert =[Util isValidatePassword:[Util trim:fieldAgain]];
            if(!showAlert){
                labelTipAgain.text = NSLocalizedString(@"passwordFormat", nil);
                return;
            }
            //密码不一致
            if(![[Util trim:fieldAgain] isEqualToString:[Util trim:fieldNew]])
            {
                labelTipAgain.text = NSLocalizedString(@"SB022_MSG005", nil);
                return;
            }
        }
        labelTipAgain.text = @"";
    }
}

- (void)sendToBackground    {
    [SOSDaapManager sendActionInfo:Password_confirm];
    @weakify(self);
    [AccountInfoUtil updatePassword:[Util trim:fieldNew] OldPassword:[Util trim:fieldOld] Success:^(NSString *response){
        self->buttonCancel.enabled = YES;
        [Util showAlertWithTitle:nil message:response completeBlock:^(NSInteger buttonIndex) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            [[LoginManage sharedInstance] doLogout];
        }];
        [SOSKeyChainManager clearLoginuserNameAndPassword];
        [SOSDaapManager sendActionInfo:Password_changesucce];

    } Failed:^(NSString *failResponse){
        [Util showAlertWithTitle:nil message:failResponse completeBlock:nil];
    }];
}

#pragma mark - user action
- (IBAction)buttonOKTapped:(id)sender {
    [self.view endEditing:YES];
    if ([[Util trim:fieldOld]length] < 1) {
        [self text:NSLocalizedString(@"NullField", @"不能为空") Label:labelTipOld forError:YES];
        return;
    }
    else{
        bool showAlert =[Util isValidatePassword:[Util trim:fieldOld]];
        if(!showAlert){
            [self text:NSLocalizedString(@"passwordFormat", @"") Label:labelTipOld forError:YES];
            return;
        }
    }
    [self text:NSLocalizedString(@"6to20", @"") Label:labelTipOld forError:NO];
    
    if ([[Util trim:fieldNew]length] < 1) {
        [self text:NSLocalizedString(@"NullField", @"") Label:labelTipNew forError:YES];
        return;
    }
    else{
        bool showAlert =[Util isValidatePassword:[Util trim:fieldNew]];
        if(!showAlert){
            [self text:NSLocalizedString(@"passwordFormat", @"") Label:labelTipNew forError:YES];
            return;
        }
        if([[Util trim:fieldNew] isEqualToString:[Util trim:fieldOld]])
        {
            [self text:NSLocalizedString(@"SB022_MSG014", @"") Label:labelTipNew forError:YES];
            return;
        }
    }
    [self text:NSLocalizedString(@"6to20", @"") Label:labelTipNew forError:NO];

    buttonCancel.enabled = YES;
    action = ChangePassword;
    [self sendToBackground];
}

- (void)dealloc{
    [SOSDaapManager sendActionInfo:Password_back];

}

@end
