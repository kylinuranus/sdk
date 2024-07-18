//
//  SOSPrepaidCardVC.h
//  Onstar
//
//  Created by Coir on 28/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSPrepaidCardVC : UIViewController 

@property (nonatomic, weak) IBOutlet UITextField *cardNumber;
@property (nonatomic, weak) IBOutlet UITextField *cardPassword;

@property (nonatomic, weak) IBOutlet UIView *constantView;
@property (nonatomic, weak) IBOutlet UIView *clickableView;

@property (nonatomic, weak) IBOutlet UILabel *makeModel;
@property (nonatomic, weak) IBOutlet UILabel *vin;
@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet UILabel *contactMethod;

@property (nonatomic, weak) IBOutlet UILabel *myMakeModel;
@property (nonatomic, weak) IBOutlet UILabel *myVin;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) BOOL isFromVinConfirmation;

@property (nonatomic, weak) IBOutlet UILabel *cardEmptyLabel;
@property (nonatomic, weak) IBOutlet UILabel *passEmptyLabel;

@end
