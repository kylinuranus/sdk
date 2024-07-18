//
//  SOSMeTabMenuItem.h
//  Onstar
//
//  Created by Onstar on 2018/12/24.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSMeTabCellMenuItem : NSObject
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *iconName;
@property (nonatomic,copy) NSString *actionName;
@property (nonatomic,copy) NSString *daapID;
@end

NS_ASSUME_NONNULL_END
