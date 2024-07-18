//
//  SOSInfoFlowTableViewStyleACell.m
//  Onstar
//
//  Created by TaoLiang on 2018/12/12.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSInfoFlowTableViewTailCell.h"
#import "UILabel+HTML.h"


@interface SOSInfoFlowTailLabel : UILabel

@end

@implementation SOSInfoFlowTailLabel

-(void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(8,0,8,0))];

}

- (CGSize)intrinsicContentSize {
    CGSize intrinsicSuperViewContentSize = [super intrinsicContentSize] ;
    if (intrinsicSuperViewContentSize.height <= 0) {
        return intrinsicSuperViewContentSize;
    }
    intrinsicSuperViewContentSize.height += 16;
    return intrinsicSuperViewContentSize ;
}


@end

@interface SOSInfoFlowTailView : UIView
@property (strong, nonatomic) NSArray<SOSIFTextInfo *> *tailInfos;
@property (strong, nonatomic) NSMutableArray<UILabel *> *labels;
@property (strong, nonatomic) NSMutableArray<UIImageView *> *icons;

@end

@implementation SOSInfoFlowTailView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _labels = @[].mutableCopy;
        _icons = @[].mutableCopy;
        UILabel *lastLabel;
        for (int i=0; i<5; i++) {
            SOSInfoFlowTailLabel *label = [SOSInfoFlowTailLabel new];
            label.numberOfLines = 0;
            [label setContentCompressionResistancePriority:751 forAxis:UILayoutConstraintAxisVertical];
            [self addSubview:label];
            [_labels addObject:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make){
                make.left.equalTo(@45);
                make.right.equalTo(@-15);
                if (lastLabel) {
                    make.top.equalTo(lastLabel.mas_bottom);
                }else {
                    make.top.equalTo(@0);
                }
                if (i==4) {
                    make.bottom.equalTo(self);
                }
            }];
            lastLabel = label;

        }
        
        [_labels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIImageView *icon = [UIImageView new];
            icon.hidden = YES;
            icon.image = [UIImage imageNamed:@"icon_report-care_22x22"];
            [self addSubview:icon];
            [icon mas_makeConstraints:^(MASConstraintMaker *make){
                make.left.equalTo(@15);
                make.centerY.equalTo(obj);
            }];
            [_icons addObject:icon];
            
        }];
    }
    return self;
}

- (void)setTailInfos:(NSArray<SOSIFTextInfo *> *)tailInfos {
    _tailInfos = tailInfos;
    [_labels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.attributedText = nil;
    }];
    [_icons enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden =YES;
    }];
    [_tailInfos enumerateObjectsUsingBlock:^(SOSIFTextInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        _labels[idx].attributedText = obj.attrString;
        _icons[idx].hidden = NO;
    }];
}

@end

@interface SOSInfoFlowTableViewTailCell ()

@property (strong, nonatomic) SOSInfoFlowTailView *tailView;
@property (strong, nonatomic) CAShapeLayer *containerMaskLayer;
@property (strong, nonatomic) CAShapeLayer *tailMaskLayer;
@property (strong, nonatomic) NSString *arrowBase64;


@end

@implementation SOSInfoFlowTableViewTailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        if (@available(iOS 10.0, *)) {
            self.contentView.bounds = CGRectMake(0, 0, NSIntegerMax, NSIntegerMax);
        } else {
            // Fallback on earlier versions
            self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        }
        self.containerView.layer.cornerRadius = 0;
        [self.containerView removeFromSuperview];
        [self.contentView addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(@10);
            make.left.equalTo(@12);
            make.right.equalTo(@-12);
            make.height.equalTo(@120).priorityLow();
        }];
        
        _tailView = [SOSInfoFlowTailView new];
        _tailView.backgroundColor = [UIColor colorWithHexString:@"#F9F9FC"];
        [self.contentView addSubview:_tailView];
        [_tailView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.right.equalTo(self.containerView);
            make.bottom.equalTo(self.contentView).offset(-5);
            make.top.equalTo(self.containerView.mas_bottom);
        }];
                
        [self.label2 mas_updateConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.label1.mas_bottom).offset(20);
        }];
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
    return self;
}

- (void)fillData:(SOSInfoFlow *)infoFlow atIndexPath:(NSIndexPath *)indexPath {
    
    [super fillData:infoFlow atIndexPath:indexPath];
    NSArray<SOSIFTextInfo *> *tailInfos = infoFlow.tail.infos;
    _tailView.tailInfos = tailInfos;
    if (infoFlow.content.infos.count > 1) {
        self.label1RightConstraint = nil;
        [self.label1 mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(@15);
            make.top.equalTo(self.label0.mas_bottom).offset(15);
            make.right.equalTo(@-5);
        }];
    }
}


- (void)layoutSubviews {
    UIRectCorner containerCorner = UIRectCornerTopLeft | UIRectCornerTopRight;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.containerView.bounds byRoundingCorners:containerCorner cornerRadii:CGSizeMake(4, 4)];
    self.containerMaskLayer.frame = self.containerView.bounds;
    self.containerMaskLayer.path = bezierPath.CGPath;
    self.containerView.layer.mask = _containerMaskLayer;

    UIRectCorner tailCorner = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    UIBezierPath *bezierPathTail = [UIBezierPath bezierPathWithRoundedRect:self.tailView.bounds byRoundingCorners:tailCorner cornerRadii:CGSizeMake(4, 4)];
    self.tailMaskLayer.frame = self.tailView.bounds;
    self.tailMaskLayer.path = bezierPathTail.CGPath;
    self.tailView.layer.mask = _tailMaskLayer;

}

- (CALayer *)containerMaskLayer {
    if (!_containerMaskLayer) {
        _containerMaskLayer = [CAShapeLayer new];
    }
    return _containerMaskLayer;
}

- (CALayer *)tailMaskLayer {
    if (!_tailMaskLayer) {
        _tailMaskLayer = [CAShapeLayer new];
    }
    return _tailMaskLayer;
}

@end
