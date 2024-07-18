//
//  InvoiceViewController.m
//  Onstar
//
//  Created by Joshua on 5/29/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import "InvoiceViewController.h"
#import "PurchaseModel.h"
#import "LoadingView.h"

@implementation InvoiceTypeDescription

- (IBAction)backToPreviousView:(id)sender     {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

@interface InvoiceViewController ()     {
    BOOL saveSuccess;
}
@end

@implementation InvoiceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil     {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad     {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PurchaseModel *model = [PurchaseModel sharedInstance];
    _invoiceTitle.text = model.invoiceTitle;
    _invoiceReceiver.text = model.invoiceReceipt;
    _invoiceAddress.text = model.invoiceAddress;
    _invoiceZipCode.text = model.zipCode;
    _invoiceMobile.text = model.invoiceMobile;
    
    _invoiceTitle.delegate = self;
    _invoiceReceiver.delegate = self;
    _invoiceAddress.delegate = self;
    _invoiceZipCode.delegate = self;
    _invoiceMobile.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated     {
    [super viewWillAppear:animated];
    [_invoiceTitle setSuppressibleKeyboard];
    [_invoiceReceiver setSuppressibleKeyboard];
    [_invoiceAddress setSuppressibleKeyboard];
    [_invoiceZipCode setSuppressibleKeyboard];
    [_invoiceMobile setSuppressibleKeyboard];
    

    
    // set the save button position
    CGRect scrollFrame = self.scrollView.frame;
    CGFloat centerY = (scrollFrame.origin.y + scrollFrame.size.height + self.view.frame.size.height) / 2;
    CGFloat centerX = self.view.frame.size.width / 2;
    self.saveButton.center = CGPointMake(centerX, centerY);
}

- (void)didReceiveMemoryWarning     {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated     {
    [super viewWillDisappear:animated];
    [[PurchaseProxy sharedInstance] removeListener:self];
}

- (void)keyboardShown:(NSNotification *)notify     {
    UITextField *textField = nil;
    if (_invoiceAddress.isFirstResponder) {
        textField = _invoiceAddress;
    } else if (_invoiceZipCode.isFirstResponder) {
        textField = _invoiceZipCode;
    } else if (_invoiceReceiver.isFirstResponder) {
        textField = _invoiceReceiver;
    } else if (_invoiceMobile.isFirstResponder) {
        textField = _invoiceMobile;
    }
    
    if (textField) {
        
        NSDictionary *userInfo = [notify userInfo];
        CGFloat keyboardHeight = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        
        CGFloat textFieldBottomY = self.scrollView.frame.origin.y + textField.frame.origin.y + textField.frame.size.height;
        CGFloat keyboardTopY = self.view.frame.size.height - keyboardHeight;
        if (textFieldBottomY > keyboardTopY) {
            [self.scrollView setContentOffset:CGPointMake(0, textFieldBottomY - keyboardTopY) animated:YES];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField     {
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    NSString *error = nil;
    NSString *content = textField.text;
    if (textField == _invoiceZipCode) {
        error = [self validateZipCode:content];
        _zipCodeError.text = error;
    } else if (textField == _invoiceMobile) {
        error = [self validatePhoneNumber:content];
        _mobileError.text = error;
    } else {
        error = [self validateNonAllNum:content];
        if (textField == _invoiceTitle) {
            _titleError.text = error;
        } else if (textField == _invoiceReceiver) {
            _receiverError.text = error;
        } else if (textField == _invoiceAddress) {
            _addressError.text = error;
        }
    }
}

- (NSString *)validateZipCode:(NSString *)content     {
    NSString *retStr = nil;
    if ([content length] == 0) {
        retStr = NSLocalizedString(@"SB027_MSG004", nil);
    } else {
        NSString *regex = @"^\\d{6}$";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if (![predicate evaluateWithObject:content]) {
            retStr = NSLocalizedString(@"SB027_MSG012", nil);
        }
    }
    return retStr;
}

- (NSString *)validateNonAllNum:(NSString *)content     {
    NSString *retStr = nil;
    if ([content length] == 0) {
        retStr = NSLocalizedString(@"SB027_MSG004", nil);
    } else {
        NSString *regex = @"^\\d*$";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if ([predicate evaluateWithObject:content]) {
            retStr = NSLocalizedString(@"SB027_MSG012", nil);
        }
    }
    return retStr;
}

- (NSString *)validatePhoneNumber:(NSString *)content     {
    NSString *retStr = nil;
    if ([content length] == 0) {
        retStr = NSLocalizedString(@"SB027_MSG004", nil);
    } else {
        if (![Util isValidatePhone:content]) {
            retStr = NSLocalizedString(@"SB027_MSG012", nil);
        }
    }
    return retStr;
}

- (IBAction)backToPreviousView:(id)sender     {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showInvoiceTypeDescription:(id)sender     {
    InvoiceTypeDescription *descVC = [[UIStoryboard storyboardWithName:[Util getStoryBoard] bundle:nil]
                                        instantiateViewControllerWithIdentifier:@"InvoiceTypeDescription"];
    [self.navigationController pushViewController:descVC animated:YES];
}

- (IBAction)saveInvoiceInfo     {
    
    // Handle the empty input case
    [self.view endEditing:YES];
    
    if ([_titleError.text length] > 0 ||
        [_receiverError.text length] > 0 ||
        [_addressError.text length] > 0 ||
        [_zipCodeError.text length] > 0 ||
        [_mobileError.text length] > 0) {
        return;
    } else {
        for (UITextField *textField in @[_invoiceTitle, _invoiceReceiver, _invoiceMobile, _invoiceAddress, _invoiceZipCode]) {
            if ([[textField text] length] == 0) {
                [self textFieldDidEndEditing:textField];
                return;
            }
        }
    }
    
    // Save the invoice information
    PurchaseModel *model = [PurchaseModel sharedInstance];
    model.invoiceTitle = _invoiceTitle.text;
    model.invoiceReceipt = _invoiceReceiver.text;
    model.invoiceAddress = _invoiceAddress.text;
    model.zipCode = _invoiceZipCode.text;
    model.invoiceMobile = _invoiceMobile.text;
    
    [[LoadingView sharedInstance] startIn:self.view];
    [[PurchaseProxy sharedInstance] addListener:self];
    [[PurchaseProxy sharedInstance] saveInvoice];
}

- (void)proxyDidFinishRequest:(BOOL)success withObject:(id)object     {
    [[LoadingView sharedInstance] stop];
    [[PurchaseProxy sharedInstance] removeListener:self];
    [Util showAlertWithTitle:nil message:object completeBlock:^(NSInteger buttonIndex) {
        if (saveSuccess ) {
            [self backToPreviousView:nil];
        }

    }];

}


- (void)dealloc     {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

@end
