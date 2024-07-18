//
//  SOSInfoFlowTableViewBaseCell.m
//  Onstar
//
//  Created by TaoLiang on 2018/12/12.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSInfoFlowTableViewBaseCell.h"
#import "UIImageView+WebCache.h"

@interface SOSInfoFlowTableViewBaseCell ()


@end

@implementation SOSInfoFlowTableViewBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [SOSUtil onstarLightGray];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.layer.masksToBounds = NO;
        self.contentView.layer.shadowColor = [UIColor colorWithRed:101/255.0 green:112/255.0 blue:181/255.0 alpha:0.2].CGColor;
        self.contentView.layer.shadowOpacity = 1;
        self.contentView.layer.shadowOffset = CGSizeMake(0, 3);
        self.contentView.layer.shadowRadius = 3;
        _containerView = [UIView new];
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.layer.cornerRadius = 4;
        _containerView.layer.masksToBounds = YES;

        [self.contentView addSubview:_containerView];
        [_containerView mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(@10);
            make.left.equalTo(@12);
            make.right.equalTo(@-12);
            make.bottom.equalTo(@-5).priorityHigh();
            //为了侧滑删除时候不会报约束警告
//            make.bottom.equalTo(@0).priorityMedium();
//            make.height.equalTo(@120).priorityLow();
        }];
        
        _leftImageView = [UIImageView new];
        _leftImageView.contentMode = UIViewContentModeScaleAspectFit;
        _leftImageView.backgroundColor = [UIColor whiteColor];
        _leftImageView.clipsToBounds = YES;
        [_containerView addSubview:_leftImageView];
        [_leftImageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerY.equalTo(_containerView);
            make.size.mas_equalTo(CGSizeMake(48, 48));
            make.left.equalTo(@2);
        }];
        
        UIView *line = [UIView new];
        line.backgroundColor = [SOSUtil onstarLightGray];
        [_containerView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(_leftImageView.mas_right).offset(2);
            make.top.bottom.equalTo(_containerView);
            make.width.equalTo(@.5);
        }];
        
        _rightPartView = [UIView new];
        _rightPartView.backgroundColor = [UIColor whiteColor];
        [_containerView addSubview:_rightPartView];
        [_rightPartView mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.top.bottom.equalTo(_containerView);
            make.left.equalTo(line.mas_right);
        }];
        
        _funcBtn = [SOSInfoFlowFuncButton buttonWithType:UIButtonTypeCustom];
        [_funcBtn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_funcBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_funcBtn addTarget:self action:@selector(funcBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_rightPartView addSubview:_funcBtn];
        [_funcBtn mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.bottom.equalTo(@-11);
        }];

        _hrefLabel = [UILabel new];
        _hrefLabel.font = [UIFont systemFontOfSize:13];
        _hrefLabel.textColor = [UIColor colorWithHexString:@"#6896ED"];
        _hrefLabel.userInteractionEnabled = YES;
        [_hrefLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hrefClicked)]];
        [_rightPartView addSubview:_hrefLabel];
        [_hrefLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(@15);
            make.bottom.equalTo(@-21);
            make.right.lessThanOrEqualTo(self.funcBtn.mas_left).offset(-5);
        }];
        
        _label0 = [self fetchLabel];
        [_label0 mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.top.equalTo(@15);
            make.right.equalTo(@-15);
        }];
        
        _label1 = [self fetchLabel];
        _label1.numberOfLines = 1;
        [_label1 mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(@15);
            make.top.equalTo(_label0.mas_bottom).offset(15);
            _label1RightConstraint = make.right.equalTo(self.funcBtn.mas_left).offset(-5);
            make.right.equalTo(@-10).priority(751);
        }];
        
        _label2 = [self fetchLabel];
        _label2.numberOfLines = 1;
        [_label2 mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(@15);
            make.top.equalTo(_label1.mas_bottom).offset(11);
            make.bottom.equalTo(self.hrefLabel.mas_top).offset(-16);
            make.right.equalTo(self.funcBtn.mas_left).offset(-5);
        }];

        
    }
    return self;
}

- (void)fillData:(SOSInfoFlow *)infoFlow atIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
    _infoFlow = infoFlow;
    [_leftImageView sd_setImageWithURL:_infoFlow.header.icon.mj_url placeholderImage:[UIImage imageNamed:@"icon_警示类别"] options:SDWebImageRetryFailed];
    _label0.attributedText = infoFlow.header.infos.firstObject.attrString;
    _label1.attributedText = infoFlow.content.infos.firstObject.attrString;
    _label2.attributedText = infoFlow.content.infos.count >= 2 ? infoFlow.content.infos[1].attrString : nil;

    _label1.lineBreakMode =  NSLineBreakByTruncatingTail;
    _label2.lineBreakMode =  NSLineBreakByTruncatingTail;

    [_label2 mas_updateConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(_label1.mas_bottom).offset(_label2.text.length > 0 ? 11 : 0);
    }];
    
    [self handleFuncBtn];
    [self handleHrefLabel];
//    [self judgeLabel1Trailing];
}


- (void)handleHrefLabel {
    BOOL shouldHideHrefLabel = _infoFlow.action.href.name.length <= 0;
    if (shouldHideHrefLabel) {
        [_label1RightConstraint install];
    }else {
        [_label1RightConstraint uninstall];
    }
    _hrefLabel.text = shouldHideHrefLabel ? nil : _infoFlow.action.href.name;
    [_hrefLabel mas_updateConstraints:^(MASConstraintMaker *make){
        make.bottom.equalTo(shouldHideHrefLabel ? @0 : @-21);
    }];
    
}

- (void)handleFuncBtn {
    BOOL shouldHideFuncBtn = _infoFlow.action.button.name.length <= 0;
    _funcBtn.hidden = shouldHideFuncBtn;
    
    NSString *title = _infoFlow.action.button.name;
    UIColor *color = [UIColor colorWithHexString:_infoFlow.action.button.color];
    [_funcBtn setTitle:title forState:UIControlStateNormal];
    _funcBtn.color = color;
}

- (void)funcBtnClicked:(__kindof UIButton *)button {
    _funcBtnHandler ? _funcBtnHandler(_indexPath) : nil;
}

- (void)hrefClicked {
    _hrefHandler ? _hrefHandler(_indexPath) : nil;
}



- (UILabel *)fetchLabel {
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    [label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [_rightPartView addSubview:label];
    return label;
}

//- (void)judgeLabel1Trailing {
//    [_label1 mas_updateConstraints:^(MASConstraintMaker *make){
//        if (_label2.text.length > 0 || _hrefLabel.text.length > 0) {
//            make.right.equalTo(@-15);
//        }else {
//            make.right.equalTo(self.funcBtn.mas_left).offset(-5).priorityLow();
//        }
//    }];
//}


-(void)layoutSubviews {
    [super layoutSubviews];
    if (@available(iOS 11.0, *)) {
        
    }else {
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
                subview.backgroundColor = [SOSUtil onstarLightGray];
                UIButton *deleteButton = subview.subviews.firstObject;
                deleteButton.backgroundColor = [UIColor clearColor];
                [deleteButton setTitle:nil forState:UIControlStateNormal];
                [deleteButton setImage:[[UIImage imageNamed:@"icon_tile_del_60x60"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
                break;
            }
        }
    }
    
}

@end
