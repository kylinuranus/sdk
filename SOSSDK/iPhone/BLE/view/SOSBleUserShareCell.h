//
//  SOSBleUserShareCell.h
//  Onstar
//
//  Created by onstar on 2018/7/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSAuthorInfo.h"

@interface SOSBleUserShareCell : UICollectionViewCell

@property (nonatomic, strong) SOSAuthorDetail *authorEntity;

@property (nonatomic, copy) void (^operationButtonTapBlock)(void);

@end
