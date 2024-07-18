//
//  ViewController.h
//  ISVINReaderPreViewSDKDemo
//
//  Created by Simon Liu on 2017/8/3.
//  Copyright © 2017年 xzliu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSRegisterInformation.h"

@interface SOSVinViewController : UIViewController


@property(nonatomic,copy)scanFinishBlock scanVinBlock;

- (instancetype)initWithAuthorizationCode:(NSString *)authorizationCode;

@end

