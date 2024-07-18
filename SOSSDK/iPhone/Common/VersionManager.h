//
//  VersionManager.h
//  Onstar
//
//  Created by Apple on 16/12/13.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VersionManager : NSObject

@property (nonatomic, strong) NSString *latestVersion;
@property (nonatomic, strong) NSString *trackViewUrl;
@property (nonatomic, strong)SOSCheckAppVersionResponse *checkVersionResp;
+ (VersionManager *)sharedInstance;

- (void)checkNewVersion;

- (void)manageVersion;

@end
@interface SOSUpgradeDetailView : UIView <UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)NSArray * tipsArray;
-(void)addDetailTips:(NSArray *)tips leftOffset:(CGFloat)loff;
@end
