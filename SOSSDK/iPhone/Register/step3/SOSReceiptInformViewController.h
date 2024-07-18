//
//  SOSReceiptInformViewController.h
//  Onstar
//
//  Created by Onstar on 2017/10/12.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
//图片上传告之界面

typedef void(^continueBlock)(void);

@interface SOSReceiptInformViewController : SOSBaseViewController
@property(nonatomic,copy)continueBlock continueCompleteCallBack;
@end
