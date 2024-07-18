//
//  TLMroRestrictionContentContainerView.m
//  Onstar
//
//  Created by TaoLiang on 2017/11/23.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "TLMroRestrictionContentContainerView.h"
#import "TLMroRestrictionContentView.h"

@interface TLMroRestrictionContentContainerView ()
@property (strong, nonatomic) NSMutableArray <TLMroRestrictionContentView *> *views;

@end

@implementation TLMroRestrictionContentContainerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configure];

    }
    return self;
}

- (void)setData:(TLMroRestrictionData *)data {
    _data = data;
    [_views enumerateObjectsUsingBlock:^(TLMroRestrictionContentView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (idx) {
            case 0:
                obj.content = data.region;
                break;
            case 1:
                obj.content = data.time;
                break;
            case 2:
                obj.content = data.num;
                break;
            case 3:
                obj.content = data.remarks;
                break;
            default:
                break;
        }
    }];
}

- (void)configure {
    self.backgroundColor = [UIColor whiteColor];
    _views = @[].mutableCopy;
    NSArray *titles = @[@"限行区域", @"限行时段", @"限行尾号", @"特别提示"];
    for (int i=0; i<4; i++) {
        TLMroRestrictionContentView *view = [TLMroRestrictionContentView new];
        [_views addObject:view];
        view.title = titles[i];
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.right.equalTo(self);
            if (i == 0) {
                make.top.equalTo(self);
            }else if (i == 1 || i == 2) {
                make.top.equalTo(_views[i-1].mas_bottom);
            }else if (i == 3) {
                make.top.equalTo(_views[i-1].mas_bottom);
                make.bottom.equalTo(self);
            }
        }];
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //画虚线
    CGFloat padding = 15.f;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetGrayStrokeColor(context, 0.6, 1.f);
    
    CGFloat lengths[] = {2, 2};
    CGContextSetLineDash(context, 5.0f, lengths, sizeof(lengths)/sizeof(lengths[0]));
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, padding, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width - padding, rect.size.height);
    CGContextStrokePath(context);
}


@end
