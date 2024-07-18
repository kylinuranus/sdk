//
//  CarStatusCell.m
//  Onstar
//
//  Created by Joshua on 14-9-11.
//  Copyright (c) 2014年 Shanghai Onstar. All rights reserved.
//

#import "CarStatusCell.h"
#import "Util.h"


@implementation CarStatusCell

- (id)init     {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)fillContent:(NSArray *)array withMultiLabel:(BOOL)multiLabel     {
    self.contentView.backgroundColor = UIColor.whiteColor;
    CGFloat currentX = 22.0f;
    CGFloat currentY = 10.0f;

    if (multiLabel) {
        currentX = 40;
        currentY = 20.0f;
    }
    CGFloat width = SCREEN_WIDTH - currentX * 2;
    CGFloat gap = 5.0f;
   
    if ([array count] > 1) {
        title = [[UILabel alloc] initWithFrame:CGRectMake(currentX, currentY, width, 30)];
        
        [title setBackgroundColor:[UIColor clearColor]];
        title.font = [UIFont boldSystemFontOfSize:15];
        title.text = NSLocalizedString([array objectAtIndex:0], nil);
        title.textColor = [array objectAtIndex:1];
        if (multiLabel) {
            title.textAlignment = NSTextAlignmentCenter;
            currentY += 35;
        }else {
            currentY += 30;
            title.textAlignment = NSTextAlignmentLeft;
        }
        [self.contentView addSubview:title];
    }
    
    if ([array count] > 2) {
        NSString *hintStr = NSLocalizedString([array objectAtIndex:2], nil);
//        CGSize size = [hintStr sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0f] constrainedToSize:CGSizeMake(width, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        CGSize size = [hintStr boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:14.0f]} context:nil].size;
        hint = [[UILabel alloc] initWithFrame:CGRectMake(currentX, currentY, width, size.height)];
        [hint setBackgroundColor:[UIColor clearColor]];
        hint.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
        hint.text = hintStr;
        hint.numberOfLines = 0;
        hint.lineBreakMode = NSLineBreakByWordWrapping;
        hint.textColor = UIColorHex(#828389);
        currentY += (size.height + gap);
        [self.contentView addSubview:hint];
    }
    
    if (multiLabel) {
        CGFloat eachLabelHeight = 16.0f;
        for (int i = 3; i < [array count] - 1; i++) {
            CGFloat x = ((i + 1) % 2) * 160 + currentX;
            CGFloat y = currentY + (i - 3)/2 * eachLabelHeight;
            UILabel *maintanceItem = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 130, eachLabelHeight)];
            maintanceItem.text = NSLocalizedString([array objectAtIndex:i], nil);
            [maintanceItem setBackgroundColor:[UIColor clearColor]];
            maintanceItem.font = [UIFont boldSystemFontOfSize:12];
            
            maintanceItem.textColor = UIColorHex(#828389);
            [self.contentView addSubview:maintanceItem];
        }
        currentY += (([array count] - 3) / 2 * eachLabelHeight + gap);
    }
    
    if ([array count] > 3) {
        NSString *warningStr = NSLocalizedString([array lastObject], nil);
//        CGSize size = [warningStr sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0f] constrainedToSize:CGSizeMake(width, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        CGSize size = [warningStr boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:11.0f]} context:nil].size;
        warning = [[UILabel alloc] initWithFrame:CGRectMake(currentX, currentY, width, size.height)];
        warning.font = [UIFont fontWithName:@"Helvetica" size:11.0f];
        warning.text = warningStr;
        warning.numberOfLines = 0;
        warning.lineBreakMode = NSLineBreakByWordWrapping;
        warning.textColor = UIColorHex(#A4A4A4);
        currentY += (size.height + gap);
        [self.contentView addSubview:warning];
    }
//    UIImageView *seperateLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"carStatusDetail_line.png"]];
//    seperateLine.frame = CGRectMake(10, currentY, SCREEN_WIDTH-20, 1);
//    [self.contentView addSubview:seperateLine];
    currentY += 10;
    
    
    CGRect frame = self.frame;
    frame.size.height = currentY ;
    if (multiLabel) {
        self.contentView.backgroundColor = UIColorHex(#F3F5FE);
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(20, 10, SCREEN_WIDTH - 20*2,  frame.size.height - 10)];
        backView.backgroundColor = [UIColor whiteColor];
        backView.layer.cornerRadius = 5;
        backView.tag = 11;
        [self.contentView addSubview:backView];
        [self.contentView sendSubviewToBack:backView];
    }else {
        UIView *backView = [self.contentView viewWithTag:11];
        if (backView) {
            [backView removeFromSuperview];
        }
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0, currentY, SCREEN_WIDTH, 1)];
        line.backgroundColor = UIColorHex(#F3F3F4);
        [self.contentView addSubview:line];
    }
    self.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated     {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
