//
//  SOSInfoTableView.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/4.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseXibView.h"
#import "SOSCustomAlertView.h"

typedef NS_ENUM(NSUInteger, ContentType) {
    ContentTypeDefault,
    ContentTypeDealer,
    ContentTypeChargeStation
};

@interface SOSInfoTableView : SOSBaseXibView <SOSAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *table;
@property(nonatomic, strong) NSArray *titleArray;
@property(nonatomic, strong) NSArray *iconArray;
@property(nonatomic, strong) SOSPOI *poi;
@property (assign, nonatomic) ContentType contentType;
@end
