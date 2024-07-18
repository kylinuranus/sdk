//
//  vKeys.h
//  BlueTools
//
//  Created by onstar on 2018/6/13.
//  Copyright © 2018年 onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSVkeyContent : NSObject

@property (nonatomic,copy) NSString *csk2;
@property (nonatomic,copy) NSString *sha256;
@property (nonatomic,copy) NSString *secretContent;

@end

@interface SOSVKeys : NSObject

@property (nonatomic, copy) NSString *vkeyId;
@property (nonatomic,copy) NSString *vkeyStatus;
@property (nonatomic,copy) NSString *vkeyCreateTime;
@property (nonatomic,copy) NSString *vkeyModifyTime;
@property (nonatomic,strong) SOSVkeyContent *vkeyContent;

@end
