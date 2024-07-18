//
//  SOSNStytleEditInfoViewController.h
//  Onstar
//
//  Created by Onstar on 2020/2/11.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
//我:比如这个修改邮箱  李苏楠:这里暂不做修改 我:那就是只有修改pin码页面是那个样式? 李苏楠:对的
@interface SOSNStytleEditInfoViewController : SOSBaseViewController
@property (nonatomic, assign) SOSEditUserInfoType editType;
@property (nonatomic, copy)   NSString *govid;//身份证
@property (nonatomic, copy)   NSString *originLabelString;
@property (nonatomic, copy)   void((^fixOkBlock)(NSString *text));

@end

NS_ASSUME_NONNULL_END
