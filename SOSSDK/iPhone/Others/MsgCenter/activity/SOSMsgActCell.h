//
//  SOSMsgActCell.h
//  Onstar
//
//  Created by WQ on 2018/5/31.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^CellOnPressed)(NSString *url,NSString *notifyId);
typedef void (^RefreshBlock)(void);


@interface SOSMsgActCell : UICollectionViewCell

@property(nonatomic,copy)CellOnPressed onPress;
@property(nonatomic,copy)RefreshBlock refreshBlock;

- (void)fillData:(NotifyOrActModel*)m;

@end
