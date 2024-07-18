//
//  OrderRecordDescriptionForDataCell.h
//  Onstar
//
//  Created by 张万强 on 15/1/15.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderRecordDescriptionForDataCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *vinLabel;
@property (nonatomic, weak) IBOutlet UILabel *indate;
@property (nonatomic, weak) IBOutlet UILabel *originPriceLabel;
@property (nonatomic, weak) IBOutlet UILabel *finalPriceLabel;

@end
