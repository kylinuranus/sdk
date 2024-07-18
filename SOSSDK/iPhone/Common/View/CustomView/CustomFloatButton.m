//
//  CustomFloatButton.m
//  Onstar
//
//  Created by Genie Sun on 16/3/8.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//  自定义按钮

#import "CustomFloatButton.h"
#import "CustomerInfo.h"

#define PADDING     5

@implementation CustomFloatButton

CGPoint beginPoint;
ButtonPosition positionStr;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event     {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    beginPoint = [touch locationInView:self];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event     {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint nowPoint = [touch locationInView:self];
    
    float offsetX = nowPoint.x - beginPoint.x;
    float offsetY = nowPoint.y - beginPoint.y;
 
    if (offsetY == 0 && offsetX == 0) {
        return;
    }
    positionStr = PositionCenter;
    [[NSNotificationCenter defaultCenter] postNotificationName:SOS_SMALL_O_LEFT_OR_RIGHT object:[NSString stringWithFormat:@"%ld",(long)positionStr]];

    self.center = CGPointMake(self.center.x + offsetX, self.center.y + offsetY);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event     {
    [super touchesEnded:touches withEvent:event];
 
    float marginLeft = self.frame.origin.x;
    float marginRight = SCREEN_WIDTH - self.frame.origin.x - self.frame.size.width;
    
    if (positionStr != PositionCenter) {
        if ([_target respondsToSelector:_action])
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_target performSelector:_action withObject:self];
#pragma clang diagnostic pop;
        }
    }
    //左
    else if (marginLeft < marginRight) {
        positionStr = PositionMoveLeft;
    }else if (marginLeft > marginRight){
        positionStr = PositionMoveRight;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SOS_SMALL_O_LEFT_OR_RIGHT object:[NSString stringWithFormat:@"%ld",(long)positionStr]];

  
    
    [UIView animateWithDuration:0.125 animations:^(void){
        self.frame = CGRectMake(marginLeft < marginRight? 0 : SCREEN_WIDTH - self.frame.size.width,
                                self.frame.origin.y,
                                self.frame.size.width,
                                self.frame.size.height);
        if (self.frame.origin.y < 0) {
            CGRect selfRect = self.frame;
            selfRect.origin.y -= self.frame.origin.y;
            self.frame = selfRect;
        }
        else if (self.frame.origin.y > SCREEN_HEIGHT - 100){
            CGRect selfRect = self.frame;
            selfRect.origin.y = SCREEN_HEIGHT - 200;
            self.frame = selfRect;
        }
    }];
}


- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents     {
    if (UIControlEventTouchUpInside & controlEvents)
    {
        _target = target;
        _action = action;
    }
}

@end
