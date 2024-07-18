//
//  NavigateSearchHistoryCell.h
//  Onstar
//
//  Created by Coir on 16/1/25.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PoiHistory.h"

typedef NS_ENUM(NSUInteger, CellType) {
    ///搜索历史
    SearchTypeSearchHistory,
    ///收藏夹
    SearchTypeCollection,
    ///搜索结果
    SearchTypeSearchResult,
    ///清空搜索历史
    SearchTypeCleanHistory,
    ///清空收藏夹
    SearchTypeCleanCollection,
    ///geo历史记录
    SearchTypeGeoHistory,
    ///geo收藏夹
    SearchTypeGeoCollection,
    ///暂无更多搜索历史
    SearchTypeNoMoreSearchHistory,
};

@class NavigateSearchHistoryCell;
@protocol SOSCollectionCellDelegate <NSObject>

@required
/// 取消收藏Button 点击
- (void)deleteButtonTappedWithCell:(NavigateSearchHistoryCell *)cell;

@end

@interface NavigateSearchHistoryCell : UITableViewCell

@property (nonatomic, strong) SOSPOI *poi;
@property (nonatomic, assign) CellType searchType;
@property (weak, nonatomic) IBOutlet UIButton *sendToCarButton;
@property (nonatomic, assign) SelectPointOperation operationType;
@property (nonatomic, weak) id <SOSCollectionCellDelegate> delegate;

- (void)configSelf;

@end
