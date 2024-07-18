//
//  SOSSocialGPSEndView.h
//  Onstar
//
//  Created by onstar on 2019/4/25.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSSocialGPSEndView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *lengthUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeUnitLabel;
@property (nonatomic, copy) void(^finishTapBlock)(void);
@end

NS_ASSUME_NONNULL_END
