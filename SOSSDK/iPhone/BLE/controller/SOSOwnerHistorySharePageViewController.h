//
//  SOSOwnerHistorySharePageViewController.h
//  Onstar
//
//  Created by onstar on 2018/7/24.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseSegmentViewController.h"

@interface SOSOwnerHistorySharePageViewController : SOSBaseSegmentViewController

@property (nonatomic, strong) NSArray *sourceTempData;
@property (nonatomic, strong) NSArray *sourcePermData;
@property (nonatomic, assign) BOOL fromOwnerShare;
@end
