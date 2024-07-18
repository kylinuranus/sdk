//
//  SubmitPersonalInfoViewController.h
//  Onstar
//
//  Created by lizhipan on 2017/8/21.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSPersonInfoItem.h"
#import "SOSPersonalInformationTableViewCell.h"
#import "NSString+JWT.h"
#import "SOSRegisterInformation.h"



@interface SubmitPersonalInfoViewController : SOSBaseViewController
@property(nonatomic,strong)SOSEnrollGaaInformation *checkedUserInfo;
@property(nonatomic,strong)SOSRegisterCheckRequestWrapper *queryUserInfoPara; //提交草稿&查询govid gaa信息
@property(nonatomic,strong)SOSRegisterCheckRequestWrapper *submitUserDraftPara;//提交草稿
@property(nonatomic,strong)SOSRegisterScanIDCardInfoWrapper *scanInfo;         //身份证照片扫码出的信息

- (IBAction)submitInfo:(id)sender;
@end
