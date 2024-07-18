//
//  ViewControllerLogin.h
//  Onstar
//
//  Created by Alfred Jin on 1/10/11.
//  Copyright 2011 plenware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface ViewControllerLogin : UIViewController <UITextFieldDelegate>{
	
    __weak IBOutlet UIButton *fingerBtn;
	BOOL forceUpgrade;
	
	NSString *appURLInAPPStore;
        
    UIButton *exitButton;
    
    __weak IBOutlet UIButton *buttonForget;
    __weak IBOutlet UIButton *buttonLogin;
    __weak IBOutlet UIButton *buttonRegister;
    __weak IBOutlet UIView *adjustScroll;
}
@property (weak, nonatomic) IBOutlet UIView *loginField;
- (void)backToPreview;
- (IBAction)buttonLoginClicked:(id)sender;
- (IBAction)buttonRegisterClicked:(id)sender;

- (void)fillCellphoneNumber:(NSString *)cellphoneNumber;

@end
