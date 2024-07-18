//
//  AuthorInfo.m
//  BlueTools
//
//  Created by onstar on 2018/6/20.
//  Copyright © 2018年 onstar. All rights reserved.
//

#import "SOSAuthorInfo.h"

@implementation SOSAuthorInfo

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"resultData":@"SOSAuthorDetail"};
}

@end



@implementation SOSAuthorDetail

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"vkeys":@"SOSVKeys"};
}

@end
