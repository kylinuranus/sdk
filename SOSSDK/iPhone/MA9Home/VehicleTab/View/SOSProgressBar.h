//
//  SOSProgressBar.h
//  Onstar
//
//  Created by Onstar on 2019/1/21.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSProgressBar : UIView
@property (nonatomic) float progress;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *backgroundColor;

@end

NS_ASSUME_NONNULL_END
