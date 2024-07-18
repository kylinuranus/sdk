//
//  PPCVinConfirmViewController.h
//  Onstar
//
//  Created by Joshua on 6/10/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextField+Keyboard.h"
#import "PurchaseProxy.h"

@interface PPCVinConfirmViewController : UIViewController <ProxyListener, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *vinNumber;
@property (nonatomic, weak) IBOutlet UITextField *phoneNumber;
@property (nonatomic, weak) IBOutlet UIView *phoneView;

@property (nonatomic, weak) IBOutlet UILabel *vinEmptyLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneEmptyLabel;
@end
