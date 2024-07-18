//
//  SOSMeCustomerServiceCell.m
//  Onstar
//
//  Created by Onstar on 2018/12/21.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSMeCustomerServiceCell.h"
#import "SOSHorizontalMenuView.h"
#import "SOSMeTabCellMenuItem.h"
#import "SOSCardUtil.h"
@interface SOSMeCustomerServiceCell()<FMHorizontalMenuViewDelegate,FMHorizontalMenuViewDataSource>
@property (nonatomic,strong) SOSHorizontalMenuView *functionView;
@property (nonatomic,copy) NSMutableArray<SOSMeTabCellMenuItem *>*packageMenuArray;
@property (nonatomic,copy) NSMutableArray<SOSMeTabCellMenuItem *>*customerServiceMenuArray;

@end

@implementation SOSMeCustomerServiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setUpView {
    [self.functionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
}
- (SOSHorizontalMenuView *)functionView {
    if (!_functionView) {
        _functionView = [[SOSHorizontalMenuView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 140)];
        _functionView.delegate = self;
        _functionView.dataSource = self;
        _functionView.hidesForSinglePage = YES;
        [self.containerView addSubview:_functionView];
        [self initDataSource];
    }
    return _functionView;
}
-(void)initDataSource{
        NSString *path = [[NSBundle SOSBundle] pathForResource:@"meTabCellMenu" ofType:@"json"];
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        _packageMenuArray = @[].mutableCopy;
        _customerServiceMenuArray = @[].mutableCopy;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSArray * packageArray = [dic valueForKey:@"packageCell"];
        [packageArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SOSMeTabCellMenuItem *menuItem = [SOSMeTabCellMenuItem mj_objectWithKeyValues:obj];
            if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
                if ([Util vehicleIsG9] && [menuItem.actionName isEqualToString:@"routerTo4GPackage"]) {
                    return ;
                }
            }
#ifndef SOSSDK_SDK
            BOOL shouldHideSC = [[LoginManage sharedInstance] isLoadingUserBasicInfoReady] && [CustomerInfo.sharedInstance.userBasicInfo.idpUserId.uppercaseString isEqualToString:[Util decodeBase64:SP_ID].uppercaseString];
            if ([menuItem.actionName isEqualToString:@"routerToPrepaymentCard"] && shouldHideSC) {
                return ;
            }
#endif
            [_packageMenuArray addObject:menuItem];
        }];
        NSArray * serviceArray = [dic valueForKey:@"customerServiceCell"];
        [serviceArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SOSMeTabCellMenuItem *menuItem = [SOSMeTabCellMenuItem mj_objectWithKeyValues:obj];
            [_customerServiceMenuArray addObject:menuItem];
        }];
}
-(void)sos_setIsCustomerService:(BOOL)isCustomerService{
    _isCustomerService = isCustomerService;
    if (!isCustomerService) {
        _packageMenuArray = nil;
        [self initDataSource];
    }
    [_functionView reloadData];
}
#pragma mark === FMHorizontalMenuViewDataSource

- (NSInteger)numberOfItemsInHorizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView section:(NSInteger)section;{
    if (_isCustomerService) {
        return _customerServiceMenuArray.count;
    }else{
         return _packageMenuArray.count;
    }
    
}
#pragma mark === FMHorizontalMenuViewDelegate


- (NSInteger)numberOfSectionsInHorizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView{
    
    return 1;
}
-(NSInteger)numOfRowsPerPageInHorizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView{
    return 1 + _isCustomerService;
}

-(NSInteger)numOfColumnsPerPageInHorizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView{
    if (_isCustomerService) {
         return 4;
    }else{
         return _packageMenuArray.count;
    }
}

- (void)horizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView didSelectItemAtIndex:(NSIndexPath *)index{
    NSString * actionName;
    NSString * daapFunctionID;

    if (_isCustomerService) {
        actionName = [_customerServiceMenuArray objectAtIndex:index.row].actionName;
        [SOSCardUtil performSelector:NSSelectorFromString(actionName)];
        
        daapFunctionID = [_customerServiceMenuArray objectAtIndex:index.row].daapID;
        
        if (daapFunctionID) {
            [SOSDaapManager sendActionInfo:daapFunctionID];
        }

        
    }else{
        actionName = [_packageMenuArray objectAtIndex:index.row].actionName;
        [SOSCardUtil performSelector:NSSelectorFromString(actionName)];
        
        daapFunctionID = [_packageMenuArray objectAtIndex:index.row].daapID;
        if (daapFunctionID) {
            [SOSDaapManager sendActionInfo:daapFunctionID];
        }
    }
}

- (NSString *)horizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView titleForItemAtIndex:(NSIndexPath *)index{
    if (_isCustomerService) {
        return [_customerServiceMenuArray objectAtIndex:index.row].title;
    }else{
        return [_packageMenuArray objectAtIndex:index.row].title;
    }
}

- (NSString *)horizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView localIconStringForItemAtIndex:(NSIndexPath *)index{
       
        if (_isCustomerService) {
            if (SOS_CD_PRODUCT) {
              return [[_customerServiceMenuArray objectAtIndex:index.row].iconName stringByAppendingString:@"_sdkcd"];
            }
            if (SOS_BUICK_PRODUCT) {
                return [[_customerServiceMenuArray objectAtIndex:index.row].iconName stringByAppendingString:@"_sdkbuick"];
            }
            return [_customerServiceMenuArray objectAtIndex:index.row].iconName;
        }else{
            if (SOS_CD_PRODUCT) {
                         return [[_packageMenuArray objectAtIndex:index.row].iconName stringByAppendingString:@"_sdkcd"];
                       }
                       if (SOS_BUICK_PRODUCT) {
                           return [[_packageMenuArray objectAtIndex:index.row].iconName stringByAppendingString:@"_sdkbuick"];
                       }
            return [_packageMenuArray objectAtIndex:index.row].iconName;
        }
}
- (CGSize)iconSizeForHorizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView  index:(NSIndexPath *)index{
    return CGSizeMake(60, 60);
}

///////////////////

- (UIFont *)textFontForHorizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView{
    return [UIFont systemFontOfSize:12.0f];
}

@end
