//
//  SOSQSModelProtol.h
//  Onstar
//
//  Created by Onstar on 2019/1/11.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppPreferences.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SOSQSModelProtol <NSObject>
@required
-(NSString*)modelTitle;
-(NSString*)modelImage;
-(BOOL)modelNeedLogin;
@optional
-(NSString*)modelID;
-(NSString*)modelAction;
- (void)setModelTitle:(NSString *)modelTitle;

- (SOSRemoteOperationType)remoteOpeType;
@end

NS_ASSUME_NONNULL_END
