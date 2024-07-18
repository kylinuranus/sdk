//
//  InputGovidViewController.h
//  Onstar
//
//  Created by lizhipan on 2017/9/1.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSRegisterInformation.h"
typedef void(^govidFillBlock)(NSString *govid,SOSEnrollGaaInformation * subscriberInfo,NSString *error);

@interface verifyGovidViewController : SOSBaseViewController
@property(nonatomic,copy)govidFillBlock fillBlock;
@property(nonatomic,copy)NSString * changeGovid;
@end
