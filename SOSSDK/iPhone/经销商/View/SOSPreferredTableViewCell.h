//
//  SOSPreferredTableViewCell.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/2.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResponseDataObject.h"

@protocol SOSPreferredTableViewCellDelegate <NSObject>

- (void)pushMapVc:(NNDealers *)dealers;

@end


@interface SOSPreferredTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UILabel *detailLb;
@property (weak, nonatomic) IBOutlet UIButton *phoneNo;
@property (weak, nonatomic) IBOutlet UILabel *distanceLb;
@property (weak, nonatomic) IBOutlet UILabel *unit;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@property(nonatomic, assign) id<SOSPreferredTableViewCellDelegate> delegate;

@property(nonatomic, strong) NSArray *dealers;
@property (assign, nonatomic) BOOL showArrow;
///埋点用,判断是附近经销商还是首选经销商
@property (assign, nonatomic) BOOL isFromPrefer;
//是否显示经纬度
@property (assign, nonatomic) BOOL shouldShowDistance;

///改变成搜索经销商中用到的样式
@property (assign, nonatomic) BOOL switchToSearchStyle;


- (void)initCellWithResponse:(NNPreferDealerDataResponse *)response;


/**
selectIndexPath 决定图片是哪种类型(非nil) 选择或者箭头(nil)
 */
- (void)initCellWithDealersResponse:(NSArray *)array
                            withPath:(NSIndexPath *)path
                     selectIndexPath:(NSIndexPath *)selectIndexPath;

- (void)initCellWithDealer:(NNDealers *)dealer
                  withPath:(NSIndexPath *)path
           selectIndexPath:(NSIndexPath *)selectIndexPath;

- (void)initCellWithDealer:(NNDealers *)dealer withPath:(NSIndexPath *)path selectIndexPath:(NSIndexPath *)selectIndexPath highlightString:(NSString *)highlight;

- (void)initCellWithDealersResponse:(NSArray *)array withPath:(NSIndexPath *)path;

@end
