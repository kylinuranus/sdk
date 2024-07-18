//
//  NavigateSearchHistoryCell.m
//  Onstar
//
//  Created by Coir on 16/1/25.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "NavigateSearchHistoryCell.h"
#import "SOSSearchResult.h"
#import "SOSTripRouteVC.h"
 

@interface NavigateSearchHistoryCell () 

@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *centerLabel;
@property (weak, nonatomic) IBOutlet UIButton *collectionnButton;


@end

@implementation NavigateSearchHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)configSelf  {
    self.titleLabel.hidden = NO;
    self.detailLabel.hidden = NO;
    self.centerLabel.hidden = YES;
    self.iconImgView.hidden = NO;
    self.sendToCarButton.hidden = NO;
    self.collectionnButton.hidden = YES;
    switch (self.searchType) {
        case SearchTypeCollection:
            self.sendToCarButton.hidden = YES;
            self.collectionnButton.hidden = NO;
            self.contentView.backgroundColor = [UIColor whiteColor];
            self.titleLabel.text = NONil(self.poi.name);
            self.detailLabel.text = NONil(self.poi.address);
            self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
            break;
        case SearchTypeSearchResult:
            self.contentView.backgroundColor = [UIColor whiteColor];
            self.titleLabel.text = NONil(self.poi.name);
            self.detailLabel.text = NONil(self.poi.address);
            self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
            break;
        case SearchTypeSearchHistory:
            self.contentView.backgroundColor = [UIColor whiteColor];
            self.iconImgView.image = [UIImage imageNamed:@"Search_Associate_Icon"];
            self.titleLabel.text = NONil(self.poi.name);
            self.detailLabel.text = NONil(self.poi.address);
            self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
            break;
        case SearchTypeNoMoreSearchHistory:
            self.centerLabel.hidden = NO;
            self.titleLabel.hidden = YES;
            self.detailLabel.hidden = YES;
            self.iconImgView.hidden = YES;
            self.sendToCarButton.hidden = YES;
            self.contentView.backgroundColor = [UIColor clearColor];
            self.centerLabel.text = @"暂无相关历史记录";
            self.separatorInset = UIEdgeInsetsMake(0, 0, 0, SCREEN_WIDTH);
            break;
        case SearchTypeCleanHistory:
            self.titleLabel.hidden = YES;
            self.detailLabel.hidden = YES;
            self.iconImgView.hidden = YES;
            self.centerLabel.hidden = NO;
            self.sendToCarButton.hidden = YES;
            self.contentView.backgroundColor = [UIColor clearColor];
            self.backgroundColor = [UIColor clearColor];
            self.centerLabel.text = @"清空历史记录";
            self.centerLabel.textColor = [UIColor colorWithHexString:@"828389"];
            self.separatorInset = UIEdgeInsetsMake(0, 0, 0, SCREEN_WIDTH);
            break;
        case SearchTypeCleanCollection:
            self.titleLabel.hidden = YES;
            self.detailLabel.hidden = YES;
            self.iconImgView.hidden = YES;
            self.centerLabel.hidden = NO;
            self.sendToCarButton.hidden = YES;
            self.contentView.backgroundColor = [UIColor clearColor];
            self.backgroundColor = [UIColor clearColor];
            self.centerLabel.text = @"清空收藏夹";
            self.centerLabel.textColor = [UIColor colorWithHexString:@"828389"];
            self.separatorInset = UIEdgeInsetsMake(0, 0, 0, SCREEN_WIDTH);
            break;
        default:
            break;
    }
    [self layoutIfNeeded];
}

- (void)setOperationType:(SelectPointOperation)operationType	{
    _operationType = operationType;
    dispatch_async_on_main_queue(^{
        if (operationType != OperationType_Void) {
            self.sendToCarButton.hidden = YES;
            self.collectionnButton.hidden = YES;
        }
    });
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)routeButtonTapped {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_HistoryTab_GoHere];
    [[SOSPoiHistoryDataBase sharedInstance] insert:self.poi];
    SOSTripRouteVC *vc = [[SOSTripRouteVC alloc] initWithRouteBeginPOI:[CustomerInfo sharedInstance].currentPositionPoi AndEndPOI:self.poi];
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

- (IBAction)collectionButtonTapped:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteButtonTappedWithCell:)]) {
        __weak __typeof(self) weakSelf = self;
        [self.delegate deleteButtonTappedWithCell:weakSelf];
    }
}

@end
