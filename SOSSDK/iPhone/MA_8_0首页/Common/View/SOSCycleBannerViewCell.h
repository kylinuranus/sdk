//
//  SOSCycleBannerViewCell.h
//  Onstar
//
//  Created by Onstar on 2018/10/16.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN NSString *const SOSBannerReuseIdentifier;
@interface SOSCycleBannerViewCell : UICollectionViewCell
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *indexLabel;
@end

NS_ASSUME_NONNULL_END
