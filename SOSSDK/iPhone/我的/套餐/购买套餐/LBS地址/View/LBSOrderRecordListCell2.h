//
//  LBSOrderRecordListCell2.h
//  ListTest
//
//  Created by jieke on 2019/6/19.
//  Copyright © 2019 jieke. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LBSOrderRecordListModel;

@interface LBSOrderRecordListCell2 : UITableViewCell

@property (nonatomic, copy) dispatch_block_t showMoreAction;

@property (nonatomic, strong) LBSOrderRecordListModel *orderRecordListModel;
@end
