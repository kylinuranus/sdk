//
//  SOSUserSettings.h
//  Onstar
//
//  Created by 梁元 on 2023/9/22.
//  Copyright © 2023 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSUserSettings : NSObject

@property(nonatomic,assign)  BOOL is2G3GUser;
@property(nonatomic,assign)  BOOL  showDataCard;
@end

NS_ASSUME_NONNULL_END
