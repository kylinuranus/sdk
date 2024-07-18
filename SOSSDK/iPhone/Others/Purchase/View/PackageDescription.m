//
//  PackageDescription.m
//  Onstar
//
//  Created by Joshua on 5/28/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//介绍VC

#import "PackageDescription.h"
#import "AppPreferences.h"
//#define ContentX    132.0f            // 介绍X
#define ContentX    20.0f
@implementation PackageDescription

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier     {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        contentX = ContentX;
    }
    return self;
}

- (void)awakeFromNib     {
    // Initialization code
    [super awakeFromNib];
    contentX = ContentX;
}

- (void)setHeaderX:(CGFloat)x1 contentX:(CGFloat)x2     {
    CGRect rect = header.frame;
    rect.origin.x = x1;
    header.frame = rect;
    contentX = x2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated     {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
//介绍VC  set
- (void)setContent:(NSArray *)descriptionList     {
    float height = 0.0f;
    for (int i = 0; i < [descriptionList count]; i++) {
        CGRect frame = CGRectMake(contentX, 50 + i * 20, SCREEN_WIDTH-contentX*2, 20);
        UILabel *descLabel = [[UILabel alloc] initWithFrame:frame];
        descLabel.textColor = [UIColor darkGrayColor];
        descLabel.font = [UIFont systemFontOfSize:13.0f];
        descLabel.text = [[descriptionList objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        NSLog(@"\n\n\n\n介绍  %@ \n\n\n",descriptionList[i]);
        [self.contentView addSubview:descLabel];
        height = 50 + (i+1) * 20 + 5;
    }
    CGRect selFrame = self.frame;
    selFrame.size.height = height;
    self.frame = selFrame;
}
- (void)setContentPad:(NSArray *)descriptionList andIsFromPPC:(BOOL) isFromPPC     {
    for (int i = 0; i < [descriptionList count]; i++) {
        CGRect frame = CGRectMake(382, 20 + i * 30, 380, 30);
        UILabel *descLabel = [[UILabel alloc] initWithFrame:frame];
        descLabel.backgroundColor = [UIColor clearColor];
        if(isFromPPC){
            descLabel.textColor =[UIColor darkGrayColor];
        }else{
            descLabel.textColor = [UIColor darkGrayColor];
        }
        descLabel.font = [UIFont systemFontOfSize:22.0f];
        
        descLabel.text = [descriptionList objectAtIndex:i];
        [self.contentView addSubview:descLabel];
    }
}
- (void)setHiddenBottomLine     {
    [bottomLine setHidden:YES];
}


@end
