//
//  SOS4GPackageChildVC.m
//  Onstar
//
//  Created by Coir on 11/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOS4GPackageChildVC.h"
#import "SOSDataPackageCell.h"
#import "SOSPackageHeader.h"

@interface SOS4GPackageChildVC () <UIGestureRecognizerDelegate>  {
    
    __weak IBOutlet UIScrollView *bgScrollView;
    __weak IBOutlet UIView *current4GPackageBGView;
    
    SOSDataPackageCell *current4GView;
    
}

@end

@implementation SOS4GPackageChildVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSelf];
}

- (void)configSelf  {
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 40 - 50);
    [self.view layoutIfNeeded];
    current4GView = [[NSBundle SOSBundle] loadNibNamed:@"SOSDataPackageCell" owner:self options:nil][0];
//    [SOSDaapManager sendActionInfo:Datapackage_currentpackageTab];
    current4GView.frame = current4GPackageBGView.bounds;
    [current4GPackageBGView addSubview:current4GView];
    self.contentWebView.forceRegisterJSCore = YES;
    [self.contentView addSubview:self.contentWebView];
    @weakify(self)
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        make.edges.mas_equalTo(self.contentView);
    }];
    
    
    
    [_contentWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:KPackageUsageURL]]];
    
    [SOSUtilConfig setView:current4GPackageBGView RoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight withRadius:CGSizeMake(6, 6)];
    [SOSUtilConfig setView:_contentWebView RoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight withRadius:CGSizeMake(6, 6)];
}

- (void)setPackageInfoArray:(NSArray *)packageInfoArray     {
    _packageInfoArray = packageInfoArray;
    if (!packageInfoArray.count)    return;
    current4GView.package = packageInfoArray[0];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (SOSWebView *)contentWebView {
    if (!_contentWebView) {
        _contentWebView = [[SOSWebView alloc] initWithFrame:self.contentView.bounds];
    }
    return _contentWebView;
}

@end
