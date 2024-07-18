//
//  testCell.h
//  Onstar
//
//  Created by WQ on 2018/5/23.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CellOnPress)(NSInteger tag);

@interface SOSMsgActivityCell : UICollectionViewCell
@property(nonatomic,strong)UILabel *testLabel;
@property(nonatomic,copy)CellOnPress onPress;

- (void)fillData:(NotifyOrActModel*)m;
@end
