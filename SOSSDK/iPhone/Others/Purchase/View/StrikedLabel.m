//
//  StrikedLabel.m
//  Onstar
//
//  Created by Joshua on 6/12/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import "StrikedLabel.h"

@implementation StrikedLabel

- (id)initWithFrame:(CGRect)frame     {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect     {
    [super drawRect:rect];
    
    // Get the text rect
    CGSize textRect = [self.text sizeWithAttributes:@{NSFontAttributeName: self.font}];
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 148.0f/255.0f, 150.0f/255.0f, 154.0f/255.0f, 1.0f);
    
    CGContextSetLineWidth(context, 1.0f);
    CGContextMoveToPoint(context, 0, CGRectGetMidY(self.bounds)); // cannot use self.frame
    CGContextAddLineToPoint(context, textRect.width, CGRectGetMidY(self.bounds)); // just stroke the text
    CGContextStrokePath(context);
}

@end
