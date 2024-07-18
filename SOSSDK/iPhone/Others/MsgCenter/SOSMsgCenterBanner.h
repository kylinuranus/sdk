//
//  SOSMsgCenterBanner.h
//  Onstar
//
//  Created by WQ on 2018/5/24.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSMsgCenterBanner : UIView

+ (SOSMsgCenterBanner*)instanceView;
- (void)refreshWithBanners:(NSArray *)banners;

@end
