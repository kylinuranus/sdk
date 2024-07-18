//
//  PPCActivateViewController.h
//  Onstar
//
//  Created by Joshua on 6/10/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PurchaseCommonDefination.h"
#import "PurchaseProxy.h"
#import "PackageDescription.h"

@interface PPCActivateViewController : UIViewController <ProxyListener>     {
    BOOL activateSuccess;
}
@property (nonatomic, weak) IBOutlet UILabel *packageNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *startLabel;
@property (nonatomic, weak) IBOutlet UILabel *endLabel;
@property (nonatomic, weak) IBOutlet UILabel *startDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *endDateLabel;

@property (nonatomic, weak) IBOutlet UILabel *durationName;
@property (nonatomic, weak) IBOutlet UILabel *durationValue;

@property (nonatomic, weak) IBOutlet UILabel *makeModel;
@property (nonatomic, weak) IBOutlet UILabel *vin;
@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet UILabel *contactMethod;
@property (nonatomic, weak) IBOutlet UIScrollView *packageDesc;

@property (nonatomic, weak) IBOutlet UIView *activateView;
@property (nonatomic, weak) IBOutlet UIView *activateViceView;
@property (nonatomic, weak) IBOutlet UIView *successView;

@property (nonatomic, weak) IBOutlet UILabel *successPackageName;
@property (nonatomic, weak) IBOutlet UILabel *successCardInfo;

@property (nonatomic, assign) PPCActivateType activeType;

@property (nonatomic, retain) NSString *headImageStr;


@end
