//
//  BaseSearchTableVC.h
//  Onstar
//
//  Created by Coir on 16/2/17.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "PoiHistory.h"
#import <UIKit/UIKit.h>
#import "CustomerInfo.h"
#import "AssociateCell.h"
#import "AssociateTips.h"
#import "BaseSearchOBJ.h"
#import "SOSShortCutView.h"
#import "SOSNavigateHeader.h"
#import "NavigateSearchHistoryCell.h"

@interface BaseSearchTableVC : UIViewController  <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, AssociateTipsDelegate>  {
    
    
    
    BaseSearchOBJ *baseSearchOBJ;
    
    ///tableView类型
    TableDataType tableType;
    ///上一条数据
    int TableDataTypeBeforeChange;
    
    ///当前页码
    int currentPage;
    ///是否需要显示更多
    BOOL needShowMore;
    
    ///搜索历史数组,存放 SOSPOI 对象
    NSMutableArray *historyArray;
    
    
    ///当前搜索结果页码
    int searchRsultPage;
    
    ///搜索结果类数组,存放SOSPoi对象
    NSMutableArray *searchResultArray;
    
    ///收藏夹数据类数组，存放SOSPoi对象
    NSMutableArray *collectionArray;
    
    ///搜索关键字联想类数组,存放AMapTip对象
    NSMutableArray *associateDataArray;
    
}

@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet SOSShortCutView *shortCutView;
@property (weak, nonatomic) IBOutlet UIView *segmentVc;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shortCutHeight;

///搜索关键字联想类对象
@property (nonatomic, strong) AssociateTips *associateSearchOBJ;
@property (weak, nonatomic) IBOutlet UITextField *fieldSearch;
@property (weak, nonatomic) IBOutlet UITableView *searchListTableView;

@property (nonatomic, strong) NNGeoFence *geoFence;
/// 从电子围栏加载
@property(nonatomic, assign) BOOL fromGeoFecing;
/// 设置搜索页面为选点模式,设置选点操作类型    (若不需要,传0或不设置)
@property (nonatomic, assign) SelectPointOperation operationType;

@property (nonatomic,strong)CLLocation * currentLocation;
@property(nonatomic,strong)CLLocation * currentVehicleLocation;


- (IBAction)back:(UIButton *)sender;

///重置TableView状态
- (void)resetTableView;

///获取搜索联想提示Cell
- (UITableViewCell *)getAssociateCellInTableView:(UITableView *)tableview ByIndexPath:(NSIndexPath *)indexPath;

///获取搜索结果Cell
- (UITableViewCell *)getSearchResultCellInTableView:(UITableView *)tableview ByIndexPath:(NSIndexPath *)indexPath;

///处理搜索联想Cell点击事件
- (void)handleAssociateCellSelect:(AssociateCell *)cell AtIndexPath:(NSIndexPath *)indexPath;

///搜索结果Cell点击处理
- (void)handleSearchResultCellSelect:(UITableView *)tableView  AtIndexPath:(NSIndexPath *)indexPath;

/// 处理搜索结果跳转(电子围栏,设置住家/公司地址,正常POI搜索等)
+ (void)handleSearchResultJumpWithResultPOI:(SOSPOI *)resultPOI FromVC:(UIViewController *)fromVC;

@end
