//
//  TLMroRestrictionResultCell.m
//  Onstar
//
//  Created by TaoLiang on 2017/11/21.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "TLMroRestrictionResultCell.h"
#import "TLMroRestrictionDateView.h"
#import "TLMroRestrictionContentContainerView.h"
#import "TLMroRestrictionContentView.h"
#import "SOSDateFormatter.h"
#import "TLMroRestrictionErrorView.h"

@interface TLMroRestrictionResultCell ()
@property (weak, nonatomic) IBOutlet UIView *rootContainerView;
@property (weak, nonatomic) IBOutlet TLMroRestrictionDateView *dateView;
@property (strong, nonatomic) NSMutableArray <__kindof UIView*>*contentContainerViews;
@property (weak, nonatomic) IBOutlet UIView *containerView;
//@property (assign, nonatomic) NSUInteger selectIndex;
@property (strong, nonatomic) NSArray <NSDate *>*showDateArray;
@property (strong, nonatomic) TLMroRestrictionErrorView *errorView;

@end

@implementation TLMroRestrictionResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    _contentContainerViews = @[].mutableCopy;
    _rootContainerView.layer.cornerRadius = 5;
    _rootContainerView.layer.masksToBounds = YES;
}

- (TLMroRestrictionErrorView *)errorView {
    if (!_errorView) {
        _errorView = [TLMroRestrictionErrorView new];
    }
    return _errorView;
}

- (void)setRestrictions:(TLMroRestrictions *)restrictions {
    _restrictions = restrictions;
    [self cookData];
    
    //防止后台数据出错,未匹配到选中日期,导致数组越界crash
    if (_restrictions.selectIndex == NSUIntegerMax) {
        _restrictions.selectIndex = 0;
    }

    [self loadDetailData];
    _dateView.showDateArray = _showDateArray;
    _dateView.selectIndex = restrictions.selectIndex;
    @weakify(self);
    _dateView.selectedBlock = ^(NSUInteger selectIndex, NSDate *date) {
        @strongify(self);
        self.restrictions.selectIndex = selectIndex;
        if (self.shouldReload) 	self.shouldReload(self.indexPath);
        
        NSArray <NSString *> *funIds = @[MrO_TrafficRestrictions_Result_ClickL1, MrO_TrafficRestrictions_Result_ClickL2, MrO_TrafficRestrictions_Result_ClickL3, MrO_TrafficRestrictions_Result_ClickL4, MrO_TrafficRestrictions_Result_ClickL5, MrO_TrafficRestrictions_Result_ClickL6, MrO_TrafficRestrictions_Result_ClickL7];
        [SOSDaapManager sendActionInfo:funIds[selectIndex]];


    };

}


- (void)loadDetailData {
    TLMroRestriction *restriction = _restrictions.sevenDayDatas[_restrictions.selectIndex];
    
    [_contentContainerViews enumerateObjectsUsingBlock:^(TLMroRestrictionContentContainerView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [_contentContainerViews removeAllObjects];
    [_errorView removeFromSuperview];
    if (![restriction.code isEqualToString:@"0000"] || restriction.content.data.count <= 0) {
        [_containerView addSubview:self.errorView];
        _errorView.errorMsg = restriction.message;
        if ([restriction.code isEqualToString:@"0000"] && restriction.content.data.count <=0) {
            _errorView.errorMsg = @"当日不限行";
        }
        [_errorView mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(_containerView);
            make.height.mas_equalTo(200);
        }];
        return;
    }
    [restriction.content.data enumerateObjectsUsingBlock:^(TLMroRestrictionData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TLMroRestrictionContentContainerView *contentCotainerView = [TLMroRestrictionContentContainerView new];
        contentCotainerView.data = obj;
        [_containerView addSubview:contentCotainerView];
        [_contentContainerViews addObject:contentCotainerView];
        [contentCotainerView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.right.equalTo(_containerView);
            if (idx == 0) {
                make.top.equalTo(_containerView);
            }else {
                make.top.equalTo(_contentContainerViews[idx-1].mas_bottom);
            }
        }];
    }];
    
    TLMroRestrictionContentView *penaltyView = [TLMroRestrictionContentView new];
    penaltyView.title = @"违规处罚";
    penaltyView.content = restriction.content.penalty;

    [_containerView addSubview:penaltyView];
    [penaltyView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.right.bottom.equalTo(_containerView);
        make.top.equalTo(_contentContainerViews.lastObject.mas_bottom);
//        make.edges.equalTo(_containerView);
    }];
    [_contentContainerViews addObject:penaltyView];

}

- (void)cookData {
    NSDate *selectDay = [[SOSDateFormatter sharedInstance] dateFromString:_restrictions.searchDate];
    NSMutableArray *resultArray = @[].mutableCopy;
    [_restrictions.sevenDayDatas enumerateObjectsUsingBlock:^(TLMroRestriction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDate *date = [[SOSDateFormatter sharedInstance] style1_dateFromString:obj.date];
        if ([SOSDateFormatter isSameDay:date date2:selectDay]) {
            if (_restrictions.selectIndex == NSUIntegerMax) {
                _restrictions.selectIndex = idx;
            }
        }
        [resultArray addObject:date];
    }];
    _showDateArray = resultArray;
}

@end
