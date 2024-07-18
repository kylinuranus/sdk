//
//  OrderRecordDescripton.h
//  Onstar
//
//  Created by Joshua on 6/9/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderRecordDescription : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *vinLabel;
@property (nonatomic, weak) IBOutlet UILabel *startDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *endDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *originPriceLabel;
@property (nonatomic, weak) IBOutlet UILabel *offerLabel;
@property (nonatomic, weak) IBOutlet UILabel *finalPriceLabel;

@end
