//
//  InvoiceViewController.h
//  Onstar
//
//  Created by Joshua on 5/29/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextField+Keyboard.h"
#import "PurchaseProxy.h"

@interface InvoiceTypeDescription : UIViewController

@end

@interface InvoiceViewController : UIViewController <ProxyListener, UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UITextField  *invoiceTitle;
@property (nonatomic, weak) IBOutlet UITextField  *invoiceReceiver;
@property (nonatomic, weak) IBOutlet UITextField  *invoiceAddress;
@property (nonatomic, weak) IBOutlet UITextField  *invoiceZipCode;
@property (nonatomic, weak) IBOutlet UITextField  *invoiceMobile;

@property (nonatomic, weak) IBOutlet UILabel *titleError;
@property (nonatomic, weak) IBOutlet UILabel *receiverError;
@property (nonatomic, weak) IBOutlet UILabel *addressError;
@property (nonatomic, weak) IBOutlet UILabel *zipCodeError;
@property (nonatomic, weak) IBOutlet UILabel *mobileError;

@property (nonatomic, weak) IBOutlet UIButton *saveButton;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@end
