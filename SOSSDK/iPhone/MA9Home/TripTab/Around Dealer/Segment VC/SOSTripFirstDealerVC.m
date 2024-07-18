//
//  SOSTripFirstDealerVC.m
//  Onstar
//
//  Created by Coir on 2019/5/5.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripFirstDealerVC.h"
#import "SOSTripDealerCell.h"
#import "SOSSelectDealerVC.h"
#import "SOSDealerTool.h"

@interface SOSTripFirstDealerVC ()

@property (weak, nonatomic) IBOutlet UIView *successBGView;
@property (weak, nonatomic) IBOutlet UIView *unNormalBGView;
@property (weak, nonatomic) IBOutlet UIView *noDealerBGView;
@property (weak, nonatomic) IBOutlet UIButton *changeFirstDealerButton;

@property (weak, nonatomic) IBOutlet UIView *loadingBGView;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (weak, nonatomic) IBOutlet UIImageView *statusImgView;
@property (weak, nonatomic) IBOutlet UILabel *detailTextLabel;

@property (weak, nonatomic) SOSTripDealerCell *detailView;

@end

@implementation SOSTripFirstDealerVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated	{
    [super viewWillAppear:animated];
    [self reloadButtonTapped];
}

- (void)setFullScreenMode:(BOOL)fullScreenMode	{
    _fullScreenMode = fullScreenMode;
    dispatch_async_on_main_queue(^{
        self.changeFirstDealerButton.hidden = !fullScreenMode;
    });
}

- (IBAction)setDealerButtonTapped 	{
    __weak __typeof(self) weakSelf = self;
    [SOSDaapManager sendActionInfo:Trip_GoWhere_AroundDealer_POIdetail_SeeMore_PreferDealerTab_Set];
    SOSSelectDealerVC *dealerVC = [SOSSelectDealerVC new];
    dealerVC.backRecordFunctionID = PrfdealerChange_back;
    dealerVC.choosePreferDealer = ^(id dealerModel) {
        weakSelf.status = SOSTripFirstDealerStatus_Success;
        weakSelf.dealer = dealerModel;
    };
    
    [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:dealerVC animated:YES];
}

- (void)setStatus:(SOSTripFirstDealerStatus)status	{
    _status = status;
    dispatch_async_on_main_queue(^{
        switch (status) {
            case SOSTripFirstDealerStatus_Loading:
                [self.statusImgView setImage:[UIImage imageNamed:@"Trip_LBS_List_Loading"]];
                self.noDealerBGView.hidden = YES;
                self.loadingBGView.hidden = NO;
                break;
            case SOSTripFirstDealerStatus_Success:
                
                break;
            case SOSTripFirstDealerStatus_Fail:
                [self.statusImgView setImage:[UIImage imageNamed:@"Trip_LBS_List_Reload"]];
                self.noDealerBGView.hidden = YES;
                self.loadingBGView.hidden = NO;
                break;
            case SOSTripFirstDealerStatus_Empty:
                self.noDealerBGView.hidden = NO;
                self.loadingBGView.hidden = YES;
                break;
        }
        if (status == SOSTripFirstDealerStatus_Success) {
            self.successBGView.hidden = NO;
            self.unNormalBGView.hidden = YES;
            if (self.detailView == nil) {
                self.detailView = [SOSTripDealerCell viewFromXib];
                self.detailView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 152);
                __weak __typeof(self) weakSelf = self;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:KFirstDealerViewTappedNotify object:[weakSelf.dealer mj_keyValues]];
                }];
                self.detailView.cellType = SOSTripCellType_Dealer;
                [self.detailView addGestureRecognizer:tap];
                [self.successBGView addSubview:self.detailView];
            }
        }	else	{
            self.successBGView.hidden = YES;
            self.unNormalBGView.hidden = NO;
        }
        self.reloadButton.userInteractionEnabled = (status == SOSTripFirstDealerStatus_Fail);
        (status == SOSTripFirstDealerStatus_Loading) ? [self.statusImgView startRotating] : [self.statusImgView endRotating];
    });
}

- (void)setDealer:(NNDealers *)dealer	{
    _dealer = [dealer copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.detailView.dealer = dealer;
    });
}

- (IBAction)reloadButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(firstDealerReloadButtonTapped)]) {
        [self.delegate firstDealerReloadButtonTapped];
    }
}

@end
