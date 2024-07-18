//
//  LBSOrderRecordListCell.h
//  LBSTest
//
//  Created by jieke on 2019/6/13.
//  Copyright © 2019 jieke. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LBSOrderRecordListModel;

@interface LBSOrderRecordListCell : UITableViewCell

@property (nonatomic, copy) dispatch_block_t showMoreAction;
@property (nonatomic, strong) LBSOrderRecordListModel *orderRecordListModel;
@end

