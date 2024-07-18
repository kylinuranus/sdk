//
//  PackageHeader.h
//  Onstar
//
//  Created by Joshua on 5/28/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "PackageInfo.h"
#import "ResponseDataObject.h"

typedef void (^CallBackBlock)(PackageInfos *index);

@interface PackageHeader : UITableViewCell     {
    CallBackBlock selectedBlock;
}

@property (nonatomic, strong) NSString *packageId;
@property (nonatomic, weak) IBOutlet UIButton *radioButton;
@property (nonatomic, weak) IBOutlet UIButton *expandIndicator;
@property (nonatomic, weak) IBOutlet UILabel  *packageName;
@property (nonatomic, weak) IBOutlet UILabel  *packageOriginPrice;
@property (nonatomic, weak) IBOutlet UILabel  *packageCouponDescription;
@property (nonatomic, weak) PackageInfos *currentPackage;
@property (nonatomic, strong) NSIndexPath *currentIndex;

- (void)setPackage:(PackageInfos *)package withBlock:(CallBackBlock)block;
- (void)checkRadio:(BOOL)radioflag;
- (void)updateIndicator:(BOOL)indicatorFlag;
@end
