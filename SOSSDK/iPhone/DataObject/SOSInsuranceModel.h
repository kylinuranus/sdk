//
//  SOSInsuranceModel.h
//  Onstar
//
//  Created by onstar on 2018/1/30.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSInsuranceModel : NSObject<YYModel>

@property (nonatomic, copy) NSString *isPrompt;//是否浮窗：Y是，N否
@property (nonatomic, copy) NSString *refLinkUrl; //点击链接地址
@property (nonatomic, copy) NSString *promptImageUrl; //浮窗图片地址
@property (nonatomic, copy) NSString *promptType;  //浮窗原因：1.固定节假日 2.超速130km

@end
