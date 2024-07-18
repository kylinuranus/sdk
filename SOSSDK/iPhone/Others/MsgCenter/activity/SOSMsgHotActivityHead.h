//
//  SOSMsgHotActivityHead.h
//  Onstar
//
//  Created by WQ on 2018/5/23.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSMsgHotActivityHead : UICollectionReusableView
@property(nonatomic,retain)UILabel *lb_date;
- (void)becomeFirstHead;
- (void)reset;

@end
