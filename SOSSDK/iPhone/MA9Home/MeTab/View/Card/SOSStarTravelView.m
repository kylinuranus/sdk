//
//  SOSStarTravelView.m
//  Onstar
//
//  Created by lmd on 2017/9/26.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSStarTravelView.h"
#import "SOSCircleProgressView.h"

@interface SOSStarTravelView ()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *bgIcomImageView;

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic)  UILabel *stageFoureLabel;

@property (strong, nonatomic) SOSCircleProgressView * circle ;
@property (weak, nonatomic) IBOutlet UIView *grandView;//有任务的星之旅显示 与下边的不共存

//@property (weak, nonatomic) IBOutlet UIView *onStarView;//on星之旅显示
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgLeftConst;

@end
@implementation SOSStarTravelView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
//    self.typeLabel.textColor = [UIColor colorWithHexString:@"6F717C"];
//    self.bgView.backgroundColor = [UIColor clearColor];
//    self.grandView.backgroundColor = [UIColor clearColor];
    //    self.bgLeftConst.constant = 38 * SCREEN_WIDTH/375;
}

- (SOSCircleProgressView *)circle {
    if (!_circle) {
        _circle = [[SOSCircleProgressView alloc] initWithFrame:self.grandView.bounds];
        [self.grandView addSubview:_circle];
        _circle.trackColor = [UIColor clearColor];
        _circle.progressWidth = 3.0f;
        [_circle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.grandView);
        }];
    }
    return _circle;
}


- (void)refreshWithResponseData:(NNStarTravelResp*)resp status:(RemoteControlStatus)status{
    //    NSMutableAttributedString *attStr;
    if (self.stageFoureLabel){
        [self.stageFoureLabel removeFromSuperview];
    }
    switch (status) {
        case RemoteControlStatus_OperateSuccess:
        {//显示resp
            //            self.typeLabel.text = resp.currentStageInfo.stageName;
            //        NSString *oriStr = [self
            if ([resp isKindOfClass:[NNStarTravelResp class]]) {
                if (!resp.currentStageInfo) {
                    [self getStarTravelFail];
                }else{
                    if (resp.serviceDays) {
                        self.infoLabel.text = [NSString stringWithFormat:@"第%@天 · %@ ",resp.serviceDays,resp.currentStageInfo.stageName];
                    }
                    self.typeLabel.text = resp.currentStageInfo.formatComments;
                    if (resp.currentStageInfo.stageId) {
                        UIImage * stgImage = [UIImage imageNamed:[NSString stringWithFormat:@"starbg_%@",resp.currentStageInfo.stageId]];
                        if (stgImage) {
                            self.bgImageView.image = stgImage;
                        }else{
                            self.bgImageView.image = [UIImage imageNamed:@"starbg_5"];
                        }
                    }
                    //判断是哪个旅程显示隐藏view //TODO
                    if (([resp.currentStageInfo.stageId isEqualToString:@"1"] ||
                         [resp.currentStageInfo.stageId isEqualToString:@"2"] ||
                         [resp.currentStageInfo.stageId isEqualToString:@"3"])) {
                        //安星 智星 随性
                        //            _onStarView.hidden = YES;
                        self.bgView.hidden = NO;
                        self.progressLabel.text = resp.currentStageInfo.progress;
                        self.circle.progress = resp.currentStageInfo.progress.floatValue/100;
                        self.circle.progressColor = [self getStageColor:resp.currentStageInfo.stageId.integerValue];
                        
                    }else {// on star jixing
                        //            self.onStarView.hidden = NO;
                        if ([resp.currentStageInfo.stageId isEqualToString:@"5"]){
                            if (!self.stageFoureLabel) {
                                UILabel * stg = [[UILabel alloc] init];
                                NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"体验更多服务 \n获得达人徽章"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size: 10],NSForegroundColorAttributeName: [UIColor colorWithRed:130/255.0 green:131/255.0 blue:137/255.0 alpha:1.0]}];
                                stg.attributedText = string;
                                stg.textAlignment = NSTextAlignmentCenter;
                                stg.numberOfLines = 0;
                                [self addSubview:stg];
                                [stg mas_makeConstraints:^(MASConstraintMaker *make) {
                                    make.edges.mas_equalTo(self.bgView);
                                }];
                                self.stageFoureLabel = stg;
                            }
                        }
                        _bgView.hidden = YES;
                        
                    }
                }
            }
            
        }
            break;
        case RemoteControlStatus_InitSuccess:
        {
            self.bgImageView.image = [UIImage imageNamed:@"starbg_loading"];
            self.infoLabel.text = @"数据飞快加载中..";
            self.typeLabel.text = @"星享之旅正在开启";
            self.bgView.hidden = YES;
        }
            break;
        case RemoteControlStatus_OperateFail:
        {
            [self getStarTravelFail];
        }
            break;
        case RemoteControlStatus_Void:
        {
            self.bgImageView.image = [UIImage imageNamed:@"starbg_1"];
            self.infoLabel.text = @"";
            self.typeLabel.text = @"";
            self.bgView.hidden = YES;
        }
            break;
        default:
            break;
    }
    
}
-(void)getStarTravelFail{
    self.bgImageView.image = [UIImage imageNamed:@"starbg_loading"];
    self.infoLabel.text = @"未获取到数据";
    self.typeLabel.text = @"下拉刷新一下吧〜";
    self.bgView.hidden = YES;
}
-(UIColor *)getStageColor:(NSInteger)stage{
    switch (stage) {
        case 1:
            return [UIColor colorWithHexString:@"#6896ED"];
            break;
        case 2:
            return [UIColor colorWithHexString:@"#84B85E"];
            break;
        case 3:
            return [UIColor colorWithHexString:@"#F18F19"];
            break;
        default:
            return [UIColor colorWithHexString:@"#6896ED"];
            break;
    }
}
- (NSString *)stringWithCSS:(NSString *)oriString {
    
    return [NSString stringWithFormat:@"<body><style>h1,h2,h3,h4{color: white;margin: 0;text-align: center;font-size: 15px;}</style><div style='font-size: 12px;color: white;text-align: center;'>%@</div></body>", oriString];
    
}

@end
