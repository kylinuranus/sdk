//
//  PPCActivateViewController.m
//  Onstar
//
//  Created by Joshua on 6/10/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import "PPCActivateViewController.h"
#import "PurchaseModel.h"
#import "PurchaseProxy.h"
#import "CustomerInfo.h"
#import "LoadingView.h"
#import "UIImageView+WebCache.h"

@class SOSPrepaidCardVC;
@interface PPCActivateViewController ()

@end

@implementation PPCActivateViewController     {
    __weak IBOutlet UIView *topView;
    __weak IBOutlet UIButton *sureBtn;
    __weak IBOutlet UIImageView *headImageV;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil     {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad     {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = NO;
    self.title = @"预付费卡激活";
    if (self.activeType == ActivatePPCForMyself) {
//        self.backRecordFunctionID = Prepaidcardactive_activecancel;
    }
    else
    {
//        self.backRecordFunctionID = Activeforothers_activecancel;
    }
    
    
    //	吉星管家页_预付费卡激活_立刻激活
    [sureBtn setTitle:NSLocalizedString(@"Confirm", nil) forState:0];  //"" = "确认";
//    titleBGV.backgroundColor = [UIColor colorWithHexString:@"122236"];
    topView.backgroundColor = [UIColor colorWithHexString:@"ffffff"];
    self.activateView.backgroundColor = [UIColor colorWithHexString:@"ffffff"];
    sureBtn.backgroundColor = [UIColor colorWithHexString:@"0e5fce"];
    sureBtn.layer.cornerRadius = 3;
    sureBtn.layer.masksToBounds = YES;
    CGRect ect = sureBtn.frame;
    ect.size.width = SCREEN_WIDTH - 30;
    sureBtn.frame = ect;
    
    if (self.activeType == ActivatePPCForMyself) {
        [headImageV sd_setImageWithURL:[[CustomerInfo sharedInstance].userBasicInfo.preference.avatarUrl makeNSUrlFromString] placeholderImage:[UIImage imageNamed:@"personinfo_avatar.png"]];
       

    }else {
//        NNExtendedSubscriber *response = [[PurchaseModel sharedInstance] getAccountInfoResponse];
//        self.makeModel.text = [NSString stringWithFormat:@"%@%@", response.make, response.model];
    }
    self.makeModel.text = [[[PurchaseModel sharedInstance] ppcVehicle] makeModel];
    headImageV.layer.cornerRadius = 42.0f;
    headImageV.layer.masksToBounds = YES;
    headImageV.contentMode =  UIViewContentModeScaleToFill;
    
    self.vin.text = [[[PurchaseModel sharedInstance] ppcVehicle] vin];
    [self.packageNameLabel adjustsFontSizeToFitWidth];
    
    NNActivatePPCResponse *response = [[PurchaseModel sharedInstance] validateResponse];
    //    Account *account = [response account];
    NSLog(@"\n\n\n   --   %@  --  \n\n\n\n\n\n",response);
    self.name.text = [NSString stringWithFormat:@"%@ 先生/女士", response.accountInfo.lastName];
    NSString *contactMethod = nil;
    if (response.accountInfo.phoneNumber.length > 8) {
        contactMethod = [response.accountInfo.phoneNumber stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }else if (response.accountInfo.email.length > 0){
        contactMethod = [Util maskEmailWithStar:response.accountInfo.email];
    }
    self.contactMethod.text = contactMethod;
    PackageInfos *package = response.packageInfo;
    self.packageNameLabel.text = [package packageName];
    NSString *packageType = response.packageInfo.packageType;
    
    if ([packageType caseInsensitiveCompare:@"data"] == NSOrderedSame) {
        //显示数据包
        [self showDuration:YES];
        self.durationValue.text = [NSString stringWithFormat:@"%@天", package.duration];              //接口没有结束时间
    } else {
        [self showDuration:NO];
        NSRange range = [package.startDate rangeOfString:@" "];
        if (range.length != 0) {
            self.startDateLabel.text = [package.startDate substringToIndex:range.location];
        }
        range = [package.endDate rangeOfString:@" "];
        if (range.length != 0) {
        }
    }
    
    PackageDescription *desc = (PackageDescription *)[[UIViewController alloc] initWithNibName:@"PackageDescription" bundle:nil].view;
    [desc setFrame:CGRectMake(desc.frame.origin.x, desc.frame.origin.y, self.packageDesc.frame.size.width, self.packageDesc.frame.size.height)];
//    [desc setBackgroundColor:[UIColor blueColor]];
    [desc setHeaderX:20.0f contentX:20.0f];
  
    [desc setContent:[package.desc componentsSeparatedByString:@"\n"]];
    CGRect descRect = self.packageDesc.frame;
    descRect.size.height = SCALE_HEIGHT(200);
    self.packageDesc.frame = descRect;
    [desc setHiddenBottomLine];
    [self.packageDesc addSubview:desc];
    
    NSString *startDate = package.startDate;
    NSString *startRange;
    NSString *endRange;
    if(startDate)
    {
        NSRange range = [startDate rangeOfString:@" "];
        if(range.length != 0)
        {
           startRange = [startDate substringToIndex:range.location];
        }
    }
    
    NSString *endDate = package.endDate;
    if(package.endDate)
    {
        NSRange range = [endDate rangeOfString:@" "];
        if(range.length != 0)
        {
            endRange = [endDate substringToIndex:range.location];
        }
    }
    
    //有效期
    self.startDateLabel.text = [NSString stringWithFormat:@"%@ / %@",startRange,endRange];
    if (IS_IPHONE_6) {
        CGRect ectStart = self.startDateLabel.frame;
        ectStart.origin.y = descRect.size.height + 60;
        self.startDateLabel.frame = ectStart;
        
        CGRect ectStartL = self.startLabel.frame;
        ectStartL.origin.y = ectStart.origin.y;
        self.startLabel.frame = ectStartL;
        
    } else if (IS_IPHONE_6P) {
        CGRect ectStart = self.startDateLabel.frame;
        ectStart.origin.y = descRect.size.height + 30;
        self.startDateLabel.frame = ectStart;
        
        CGRect ectStartL = self.startLabel.frame;
        ectStartL.origin.y = ectStart.origin.y;
        self.startLabel.frame = ectStartL;
        
        CGRect pakeEct = self.activateView.frame;
        pakeEct.size.height = pakeEct.size.height + 30;
        self.activateView.frame = pakeEct;
    }
    
    if (SCREEN_HEIGHT < 568) {
        CGRect rect = desc.frame;
        self.packageDesc.frame = CGRectMake(0, 96, 320, 236-88);
        self.packageDesc.contentSize = CGSizeMake(320, rect.size.height);
    }
    else
    {
        CGRect rect = desc.frame;
        self.packageDesc.contentSize = CGSizeMake(320, rect.size.height);
    }
}

- (void)showDuration:(BOOL)shown     {
    self.durationName.hidden = !shown;
    self.durationValue.hidden = !shown;
    self.startLabel.hidden = shown;
    self.startDateLabel.hidden = shown;
    self.endLabel.hidden = shown;
    self.endDateLabel.hidden = shown;
}

- (void)didReceiveMemoryWarning     {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated     {
    [super viewWillDisappear:animated];
    [[PurchaseProxy sharedInstance] removeListener:self];
}

- (IBAction)activateCard     {
    //	吉星管家页_预付费卡激活_立刻激活_确认按钮
    if (self.activeType == ActivatePPCForMyself) {
        [SOSDaapManager sendActionInfo:Prepaidcard_Activpage_confirm];
    }
    [[LoadingView sharedInstance] startIn:self.view];
    [[PurchaseProxy sharedInstance] addListener:self];
    NSString *type = nil;
    if (self.activeType == ActivatePPCForOthers) {
        type = @"Other";
    }
    [[PurchaseProxy sharedInstance] activatePPCById:type];
}

- (void)goToHistory     {
    //	预付费卡激活_历史记录按钮
    ////[[SOSReportService shareInstance] recordActionWithFunctionID:REPORT_PreSaleActivateOrderHistory];
    UIViewController *vc = [[UIStoryboard storyboardWithName:[Util getStoryBoard] bundle:nil]
                            instantiateViewControllerWithIdentifier:@"PPCHistoryViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToSuccessPage     {
    [self.activateView setHidden:YES];
    [self.activateViceView setHidden:YES];
    [self.successView setHidden:NO];
}

- (void)handleAlertInteract {
    if (activateSuccess) {
        if (self.activeType == ActivatePPCForMyself) {
            [self goToHistory];
        }
        else {
            //                [self goToSuccessPage];
            [self backToPreviousView:nil];
        }
    } else {
        [self backToPreviousView:nil];
    }

}

- (void)proxyDidFinishRequest:(BOOL)success withObject:(id)object     {
    [[LoadingView sharedInstance] stop];
    [[PurchaseProxy sharedInstance] removeListener:self];
    
    NNActivatePPCResponse *response = [[PurchaseModel sharedInstance] activatePPCResponse];
    activateSuccess = ([response status] && [[response status] caseInsensitiveCompare:@"Success"] == NSOrderedSame);
    
    if (success && activateSuccess) {
        NSString *msg = nil;
        self.successPackageName.text = response.packageInfo.packageName;
        self.successCardInfo.text = [NSString stringWithFormat:@"卡号：%@", [[PurchaseModel sharedInstance] ppcCardNo]];
        msg = NSLocalizedString(@"SB027_MSG006", nil);
        [Util showAlertWithTitle:nil message:msg completeBlock:^(NSInteger buttonIndex) {
            [self handleAlertInteract];
        }];
    } else {
        [Util showAlertWithTitle:nil message:object completeBlock:^(NSInteger buttonIndex) {
            [self handleAlertInteract];
        }];
        
    }
}
- (IBAction)backToPreviousView:(id)sender     {
    if (activateSuccess) {
//        [self.navigationController popToRootViewControllerAnimated:YES];
            for (id vc in self.navigationController.childViewControllers) {
                if ([vc isKindOfClass:NSClassFromString(@"SOSMeViewController")]) {
                    [self.navigationController popToViewController:vc animated:YES];
                }
        
            }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }

}
@end
