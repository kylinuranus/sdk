//
//  SOSNotifyCell.h
//  Onstar
//
//  Created by WQ on 2018/5/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CellOnPress)(NSString* url,NSString*notifyId);

@interface SOSNotifyCell : UITableViewCell

@property(nonatomic,copy)CellOnPress onPress;
- (void)fillData:(NotifyOrActModel*)m;

@end
