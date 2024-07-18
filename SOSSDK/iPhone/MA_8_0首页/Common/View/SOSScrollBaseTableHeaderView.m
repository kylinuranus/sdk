//
//  SOSScrollBaseTableHeaderView.m
//  Onstar
//
//  Created by lizhipan on 2017/7/24.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSScrollBaseTableHeaderView.h"
#import "SOSPageScrollMainView.h"
#import "SOSScrollBaseTableViewController.h"
@implementation SOSScrollBaseTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame scrollPara:(SOSPageScrollParaCenter *)para
{
    self = [super initWithFrame:frame];
    if (self) {
        _stickHeaderState = HeaderStateFree;
        _headerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width,para.headerTotalHeight - para.stickHeight)];
        _headerBackgroundView.backgroundColor = [UIColor clearColor];
        [self addSubview:_headerBackgroundView];
                
        self.titleSegment = [[UISegmentedControl alloc]initWithFrame:CGRectMake(0, para.headerTotalHeight - para.stickHeight, frame.size.width,para.stickHeight)];
        self.titleSegment.tintColor = [UIColor clearColor];
        NSDictionary* selectedTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:16.0f],
                                                 NSForegroundColorAttributeName: [UIColor colorWithHexString:@"59708A"]};
        [self.titleSegment setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];
        NSDictionary* unselectedTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:16.0f],
                                                   NSForegroundColorAttributeName: [UIColor colorWithHexString:@"C7CFD8"]};
        [self.titleSegment setTitleTextAttributes:unselectedTextAttributes forState:UIControlStateNormal];
        [self.titleSegment addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.titleSegment];
        
        //底部线
        self.lineView = [[UIView alloc]init];
        self.lineView.backgroundColor = [UIColor colorWithHexString:@"107FE0"];
        [self addSubview:self.lineView];
    }
    [self addShadow];
    return self;
}

- (void)configTitleSegmentWidth:(CGFloat)width titleColor:(UIColor *)titleColor titleHighlightColor:(UIColor *)highlightColor highlightLineColor:(UIColor *)lineColor
{
    [self.titleSegment setFrame:CGRectMake((self.frame.size.width - width)/2, self.titleSegment.frame.origin.y, width, self.titleSegment.height)];
    NSDictionary* selectedTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:16.0f],
                                             NSForegroundColorAttributeName:titleColor};
    [self.titleSegment setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];
    NSDictionary* unselectedTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:16.0f],
                                               NSForegroundColorAttributeName: highlightColor};
    [self.titleSegment setTitleTextAttributes:unselectedTextAttributes forState:UIControlStateNormal];
    
    self.lineView.backgroundColor = lineColor;
    _lineViewWidth = width / self.titleSegment.numberOfSegments;
    self.lineView.frame = CGRectMake(_titleSegment.frame.origin.x, _titleSegment.frame.origin.y+_titleSegment.frame.size.height-2.0f,_lineViewWidth, 2.0f);
}

- (void)addShadow
{
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(5,5);
    self.layer.shadowOpacity = 0.6;
}
- (void)setTitle:(NSArray *)title{
    if (title.count > 0) {
        for (NSInteger i = 0; i < title.count; i ++) {
            [self.titleSegment insertSegmentWithTitle:[title objectAtIndex:i] atIndex:i animated:NO];
        }
    }
    self.titleSegment.selectedSegmentIndex = 0;
    
    _lineViewWidth = self.titleSegment.width / title.count;
    self.lineView.frame = CGRectMake(_titleSegment.frame.origin.x, _titleSegment.frame.origin.y+_titleSegment.frame.size.height-2.0f,_lineViewWidth, 2.0f);
}
- (void)configHeader:(UIView *)headerV
{
    if ([_headerBackgroundView subviews].count >1) {
        [_headerBackgroundView removeAllSubviews];
    }
    headerV.frame = _headerBackgroundView.frame;
    [_headerBackgroundView addSubview:headerV];
}
- (void)configBackground:(UIImage *)backbg
{
    if (backbg) {
        UIImageView * bgv = [[UIImageView alloc] initWithImage:backbg];
        bgv.frame = self.frame;
        [self insertSubview:bgv atIndex:0];
    }
    else
    {
        //默认背景色
        self.backgroundColor = [UIColor whiteColor];//[SOSUtil onstarLightGray];
    }
}
- (void)pageChanged:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentChange:)]) {
        [self.delegate segmentChange:((UISegmentedControl *)sender).selectedSegmentIndex];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    if (self.userInteractionEnabled == NO || self.hidden == YES || self.alpha <= 0.01) return nil;
    
    if ([self pointInside:point withEvent:event] == NO) return nil;
    
    NSInteger count = self.subviews.count;
    for (NSInteger i = count - 1; i >= 0; i--) {
        UIView *childView = self.subviews[i];
        
        CGPoint childViewPoint = [self convertPoint:point toView:childView];
        UIView *responseView = [childView hitTest:childViewPoint withEvent:event];
        if (responseView) {
            
            if ([responseView isKindOfClass:[UIControl class]] ||
                [responseView isKindOfClass:[UIScrollView class]] ||
                [responseView.superview isKindOfClass:[UICollectionViewCell class]] ||
                [responseView.superview isKindOfClass:[UITableViewCell class]]) {

                return responseView;
            }
            
        }
    }
    if ([self.superview isKindOfClass:[SOSPageScrollMainView class]]) {
        SOSPageScrollMainView *parentView = (SOSPageScrollMainView *)self.superview;
        __kindof SOSScrollBaseTableViewController *tableVC = parentView.tableViewControllerArray[parentView.selectTableIndex];
        return tableVC.table;
    }else {
        return self;
    }

    

}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    NSLog(@"hitTesthitTest===");
//    if ([self.titleSegment pointInside:point withEvent:event]) {
//        NSLog(@"titleSegment=pointInside==");
//
//        return [super hitTest:point withEvent:event];
//    } else {
//        if (self.delegate && [self.delegate respondsToSelector:@selector(hitTestReceiver)]) {
//            return (UIView *)[self.delegate hitTestReceiver];
//        }
//        return [super hitTest:point withEvent:event];
        
//    }
//}


@end
