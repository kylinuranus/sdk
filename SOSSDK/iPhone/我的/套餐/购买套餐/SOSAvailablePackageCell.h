//
//  SOSAvailablePackageCell.h
//  Onstar
//
//  Created by Coir on 8/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSAvailablePackageCell : UITableViewCell

@property (nonatomic, assign) BOOL selectFlag;
@property (nonatomic, copy) PackageInfos *package;

- (void)setCornerRidusWithIndexPath:(NSIndexPath *)indexPath AndPackageCount:(NSInteger)packageCount;

@end
