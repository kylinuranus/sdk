//
//  SOSTripRouteNavBarView.m
//  Onstar
//
//  Created by Coir on 2019/4/15.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripRouteNavBarView.h"
#import "NavigateSearchVC.h"

@interface SOSTripRouteNavBarView ()

@property (nonatomic, assign) BOOL isReverse;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet SOSCustomBtn *beginPointButton;
@property (weak, nonatomic) IBOutlet SOSCustomBtn *endPointButton;
@property (weak, nonatomic) IBOutlet UIView *beginFlagView;
@property (weak, nonatomic) IBOutlet UIView *endFlagView;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *beginButtonTopGuide;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endButtonTopGuide;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeightGuide;
//@property (strong, nonatomic) IBOutlet UIView *dashLine;

@property (strong, nonatomic) UIView *dashLine;



@end

@implementation SOSTripRouteNavBarView

- (void)awakeFromNib	{
    [super awakeFromNib];
    float statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.navBarHeightGuide.constant = statusBarHeight;
    _dashLine = [UIView new];
    [self addSubview:_dashLine];
    [_dashLine mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(_beginFlagView);
        make.top.equalTo(_beginFlagView.mas_bottom);
        make.bottom.equalTo(_endFlagView.mas_top);
        make.width.equalTo(@1);
    }];
    [self drawDashLine];
}

- (void)setBeginPOI:(SOSPOI *)beginPOI    {
    _beginPOI = [beginPOI copy];
    NSString *name = beginPOI.name;
    if ([beginPOI.nickName isEqualToString:@"我的位置"]) {
        name = @"我的位置";
    }
    dispatch_async_on_main_queue(^{
        if (self.isReverse)        [self.endPointButton setTitleForNormalState:name];
        else                     [self.beginPointButton setTitleForNormalState:name];
    });
}

- (void)setEndPOI:(SOSPOI *)endPOI    {
    _endPOI = [endPOI copy];
    NSString *name = endPOI.name;
    if ([endPOI.nickName isEqualToString:@"我的位置"]) {
        name = @"我的位置";
    }
    dispatch_async_on_main_queue(^{
        if (self.isReverse)        [self.beginPointButton setTitleForNormalState:name];
        else                    [self.endPointButton setTitleForNormalState:name];
    });
}


- (void)setIsFindCarMode:(BOOL)isFindCarMode	{
    _isFindCarMode = isFindCarMode;
    dispatch_async_on_main_queue(^{
        self.switchButton.hidden = isFindCarMode;
        self.beginPointButton.userInteractionEnabled = !isFindCarMode;
        self.endPointButton.userInteractionEnabled = !isFindCarMode;
    });
}

- (IBAction)routeBeginButtonTapped {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_POIdetail_GoHere_StartPosition];
    NavigateSearchVC *vc = [NavigateSearchVC new];
    SelectPointOperation type = self.isReverse ? OperationType_set_Route_Destination_POI : OperationType_set_Route_Begin_POI;
    vc.operationType = type;
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.vc presentViewController:navVC animated:YES completion:nil];
}

- (IBAction)routeEndButtonTapped {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_POIdetail_GoHere_EndPosition];
    NavigateSearchVC *vc = [NavigateSearchVC new];
    SelectPointOperation type = self.isReverse ? OperationType_set_Route_Begin_POI : OperationType_set_Route_Destination_POI;
    vc.operationType = type;
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.vc presentViewController:navVC animated:YES completion:nil];
}

- (IBAction)backButtonTapped {
    if (self.isFindCarMode) {
        [SOSDaapManager sendActionInfo:Trip_VehicleLocation_FindMyCar_POIdetail_Back];
    }	else	{
        [SOSDaapManager sendActionInfo:Trip_GoWhere_POIdetail_GoHere_Back];
    }
    [self.viewController.navigationController popViewControllerAnimated:YES];
}

- (IBAction)switchButtonTapped {
    [SOSDaapManager sendActionInfo:Trip_GoWhere_POIdetail_GoHere_Interchange];
    [_dashLine removeFromSuperview];
    [self layoutIfNeeded];
    if (self.isReverse) {
    // 反向状态,恢复初始状态
        self.beginButtonTopGuide.constant = 5.f;
        self.endButtonTopGuide.constant = 44.f;
    }	else	{
        self.beginButtonTopGuide.constant = 44.f;
        self.endButtonTopGuide.constant = 5.f;
    }
    [UIView animateWithDuration:.3 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        
        SOSPOI *tempPOI = [self.beginPOI copy];
        _beginPOI = self.endPOI;
        _endPOI = tempPOI;
        if (self.isReverse) {
            self.beginFlagView.backgroundColor = [UIColor colorWithHexString:@"6896ED"];
            self.endFlagView.backgroundColor = [UIColor colorWithHexString:@"EE8249"];
        }	else	{
            self.beginFlagView.backgroundColor = [UIColor colorWithHexString:@"EE8249"];
            self.endFlagView.backgroundColor = [UIColor colorWithHexString:@"6896ED"];
        }
        self.isReverse = !self.isReverse;
        [self addSubview:_dashLine];
        [_dashLine mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerX.equalTo(_beginFlagView);
            make.top.equalTo(self.isReverse ? _endFlagView.mas_bottom : _beginFlagView.mas_bottom);
            make.bottom.equalTo(self.isReverse ? _beginFlagView.mas_top : _endFlagView.mas_top).priorityLow();
            make.width.equalTo(@1);
        }];
        [self drawDashLine];

        if (self.delegate && [self.delegate respondsToSelector:@selector(routePOIChangedWithBeginPOI:AndEndPOI:)]) {
            [self.delegate routePOIChangedWithBeginPOI:_beginPOI AndEndPOI:_endPOI];
        }
    }];
}

- (void)drawDashLine {
    [self layoutIfNeeded];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.bounds = _dashLine.bounds;
    shapeLayer.position = CGPointMake(_dashLine.width, _dashLine.height / 2);
    shapeLayer.fillColor = UIColor.clearColor.CGColor;
    shapeLayer.strokeColor = [UIColor colorWithHexString:@"CFCFCF"].CGColor;
    shapeLayer.lineWidth = 1;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineDashPattern = @[@1, @1.5];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, 0, _dashLine.height);
    
    shapeLayer.path = path;
    CGPathRelease(path);
    [_dashLine.layer addSublayer:shapeLayer];
}

@end
