//
//  SOSOnRemoteCell.m
//  Onstar
//
//  Created by onstar on 2018/12/21.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSOnRemoteCell.h"
#import "SOSHorizontalMenuView.h"
#import "SOSOnRemoteCollectionLayout.h"
#import "SOSRemoteTool.h"
#import "SOSOnUtils.h"
#import "UIImage+SOSSkin.h"
@interface SOSOnRemoteCell ()<FMHorizontalMenuViewDelegate,FMHorizontalMenuViewDataSource>
@property (weak, nonatomic) IBOutlet SOSHorizontalMenuView *menuView;
@property (nonatomic, strong) NSArray *firstPageRemoteArray;
@property (nonatomic, strong) NSArray *secondPageRemoteArray;

@property (nonatomic, assign) SOSRemoteOperationType operationingType;

@property (nonatomic, assign) RemoteControlStatus RemoteControlStatus;

@end

@implementation SOSOnRemoteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.menuView.delegate = self;
    self.menuView.dataSource = self;
    
    if (SOS_CD_PRODUCT) {
        self.menuView.currentPageDotColor = [UIColor cadiStytle];
           self.menuView.pageDotColor = [UIColor colorWithHexString:@"#C8C8C8"];
    }
    if (SOS_BUICK_PRODUCT) {
        self.menuView.currentPageDotColor = [UIColor colorWithHexString:@"#004E90"];
    }

    [self addObserver];
    
    /*作用：当本页面还未初始化，在其他页面下发车辆操作后，进入本页面时下述两个值未能获取到实时操作下发状态。
    所以在本页面初始化时，同步下操作状态*/
    _operationingType = SOSRemoteTool.sharedInstance.lastOperationType;
    _RemoteControlStatus = SOSRemoteTool.sharedInstance.operationStastus;
}


- (void)addObserver        {
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_VEHICLE_OPERATE_NOTIFICATION object:nil] subscribeNext:^(NSNotification *noti) {
        //        @{@"state":@(RemoteControlStatus_OperateFail), @"OperationType" : @(type)}
        NSDictionary *notiDic = noti.userInfo;
        RemoteControlStatus resultState = [notiDic[@"state"] intValue];
        SOSRemoteOperationType operationType = [notiDic[@"OperationType"] intValue];
        BOOL havc = [notiDic[@"HVAC"] boolValue];
        if (notiDic[@"OperationType"]) {
            if (operationType == SOSRemoteOperationType_RemoteStart && havc) {
                self.operationingType = SOSRemoteOperationType_OpenHVAC;
            }else if(operationType == SOSRemoteOperationType_CloseHVAC) {
                self.operationingType = SOSRemoteOperationType_OpenHVAC;
            }else if (operationType == SOSRemoteOperationType_Light || operationType == SOSRemoteOperationType_Horn) {
                self.operationingType = SOSRemoteOperationType_LightAndHorn;
            }else {
                self.operationingType = operationType;
            }
            self.RemoteControlStatus = resultState;
            [self.menuView reloadDataSingle];
        }
    }];
    
}





- (void)reload {
    if ([SOSCheckRoleUtil isOwner] || [SOSCheckRoleUtil isDriverOrProxy]) {
        self.firstPageRemoteArray = [SOSOnUtils supportNormalRemoteItems];
        self.secondPageRemoteArray = [SOSOnUtils supportIcmRemoteItems];
    }else {
        self.firstPageRemoteArray = [SOSOnUtils defaultRemoteItems];
        self.secondPageRemoteArray = @[];
    }
    
    [self.menuView reloadData];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark === FMHorizontalMenuViewDataSource

//-(UINib *)customCollectionViewCellNibForHorizontalMenuView:(FMHorizontalMenuView *)view{
//    return [UINib nibWithNibName:@"FMCollectionViewCell" bundle:nil];
//}
//-(void)setupCustomCell:(UICollectionViewCell *)cell forIndex:(NSInteger)index horizontalMenuView:(FMHorizontalMenuView *)view{
//    //    FMCollectionViewCell *myCell = (FMCollectionViewCell*)cell;
//    //    myCell.kindLabel.text = @"测试";
//}

-(NSInteger)numberOfItemsInHorizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView section:(NSInteger)section {
    if (section == 0) {
         return self.firstPageRemoteArray.count;
    }else {
        return self.secondPageRemoteArray.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInHorizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView {
    return 2;
}

#pragma mark === FMHorizontalMenuViewDelegate

- (SOSHorizontalMenuCollectionLayout *)layoutInHorizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView {
    return [SOSOnRemoteCollectionLayout new];
}

-(void)horizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView didSelectItemAtIndex:(NSIndexPath *)index {
    NSInteger operationType ;
    if (index.section == 0) {
        operationType = [[self.firstPageRemoteArray[index.row] objectForKey:@"operationType"] integerValue];
    }else {
        operationType = [[self.secondPageRemoteArray[index.row] objectForKey:@"operationType"] integerValue];
    }
    
    if (operationType == SOSRemoteOperationType_OpenHVAC) {
        //空调alert
        !self.tapHVACABlock?:self.tapHVACABlock(operationType);
    }else {
        //远程操作
        !self.tapRemoteBlock?:self.tapRemoteBlock(operationType);
    }
    
}


- (void)horizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView congfigItem:(SOSHorizontalMenuViewCell *)cell atIndex:(NSIndexPath *)index {
    cell.line.hidden = NO;
    cell.highlightIcon.hidden = NO;
    SOSRemoteOperationType type;
    NSString *imageKey = @"defaultImg";
    if ([SOSCheckRoleUtil isOwner]) {
        
        if (![CustomerInfo sharedInstance].isExpired) {
            imageKey = @"img";
        }
    }else if ([SOSCheckRoleUtil isDriverOrProxy]) {
//        imageKey = [CustomerInfo sharedInstance].carSharingFlag?@"img":@"defaultImg";
        if (![CustomerInfo sharedInstance].isExpired && [CustomerInfo sharedInstance].carSharingFlag) {
            imageKey = @"img";
        }
    }
    
    
    if (index.section == 0) {
        cell.menuTile.text =  [self.firstPageRemoteArray[index.row] objectForKey:@"title"];
        if ([imageKey isEqualToString:@"defaultImg"]) {
          cell.menuIcon.image = [UIImage imageNamed:[self.firstPageRemoteArray[index.row] objectForKey:imageKey]];
        }else{
            cell.menuIcon.image = [UIImage sosSDK_imageNamed:[self.firstPageRemoteArray[index.row] objectForKey:imageKey]];
        }
        
        type = [[self.firstPageRemoteArray[index.row] objectForKey:@"operationType"] integerValue];
    }else {
        cell.menuTile.text = [self.secondPageRemoteArray[index.row] objectForKey:@"title"];
        if ([imageKey isEqualToString:@"defaultImg"]) {
                 cell.menuIcon.image = [UIImage imageNamed:[self.secondPageRemoteArray[index.row] objectForKey:imageKey]];
               }else{
                   cell.menuIcon.image = [UIImage sosSDK_imageNamed:[self.secondPageRemoteArray[index.row] objectForKey:imageKey]];
               }
        type = [[self.secondPageRemoteArray[index.row] objectForKey:@"operationType"] integerValue];
    }
    if (type == self.operationingType && self.RemoteControlStatus == RemoteControlStatus_InitSuccess) {
        //refreshing
        [cell shouldLoading:YES];
    }else {
        //normal
        [cell shouldLoading:NO];
    }
    
    
}


-(CGSize)iconSizeForHorizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView {
  
    return CGSizeMake(60, 60);
}

@end
