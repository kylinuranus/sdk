//
//  SOSBannerTableViewCell.h
//  Onstar
//
//  Created by Genie Sun on 2017/9/6.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSBannerTableViewCell : UITableViewCell

@property (nonatomic, copy) void(^imageEndLoadBlock)(NSError * _Nullable error);

- (void)refreshWithBanners:(NSArray *)banners;


@end
