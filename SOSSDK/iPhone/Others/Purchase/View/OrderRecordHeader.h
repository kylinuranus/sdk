//
//  OrderRecordHeader.h
//  Onstar
//
//  Created by Joshua on 6/9/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderRecordHeader : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *expandIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *seperatorLine;

@property (nonatomic, weak) IBOutlet UILabel *packageNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *orderStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *purchaseDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *orderIdLabel;
@property (nonatomic, weak) IBOutlet UILabel *finalPriceLabel;

@property (nonatomic, weak) IBOutlet UILabel *vinLabel;
@property (nonatomic, weak) IBOutlet UILabel *startDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *endDateLabel;


- (void)updateIndicator:(BOOL)indicatorFlag;
@end
