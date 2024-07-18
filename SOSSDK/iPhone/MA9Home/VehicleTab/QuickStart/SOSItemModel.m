//
//  SOSItemModel.m
//  Onstar
//
//  Created by Genie Sun on 2017/5/18.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSItemModel.h"

@implementation SOSItemModel

- (instancetype)init {
    if (self = [super init]) {
        _opeType = NSIntegerMax;
    }
    return self;
}

-(NSString*)modelID{
    return self.ID;
}
-(NSString*)modelTitle{
    return self.title;
}
-(NSString*)modelImage{
    if (SOS_CD_PRODUCT) {
        return [self.image stringByAppendingString:@"_sdkcd"];
    }
    if (SOS_BUICK_PRODUCT) {
           return [self.image stringByAppendingString:@"_sdkbuick"];
       }
    return self.image;
}
-(NSString*)modelAction{
    return self.action;
}
-(BOOL)modelNeedLogin {
    return self.needLogin;
}


- (SOSRemoteOperationType)remoteOpeType {
    return (SOSRemoteOperationType)self.opeType;
}
@end
