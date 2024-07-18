//
//  ViewCellControllerRecentStatus.m
//  Onstar
//
//  Created by Alfred Jin on 2/8/11.
//  Copyright 2011 plenware. All rights reserved.
//

#import "ViewCellControllerRecentStatus.h"
#import "AppPreferences.h"
#define TABLE_FONT_SIZE		14.0
#define TABLE_FONT_IPAD_SIZE  22.0

@implementation ViewCellControllerRecentStatus
@synthesize labelTime;
@synthesize imgIcon;
@synthesize imgStatus;
@synthesize labelStatus;
@synthesize labelOperationName;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier     {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
//		[self drawCell];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)drawPad     {
    self.backgroundColor = [UIColor clearColor];
    
    imgIcon = [[UIImageView alloc] init];
    imgIcon.frame = CGRectMake(60.0f, 35.0f, 40.0f, 50.0f);
    [self.contentView addSubview:imgIcon];
    
    
    labelOperationName = [[UILabel alloc] init];
    labelOperationName.frame = CGRectMake(140, 15, 300.0f, 30);
    labelOperationName.backgroundColor = [UIColor clearColor];
    [labelOperationName setFont:[UIFont systemFontOfSize:TABLE_FONT_IPAD_SIZE]];
    [labelOperationName setTextAlignment:NSTextAlignmentLeft];
    [labelOperationName setTextColor:[UIColor whiteColor]];
    
    labelTime = [[UILabel alloc] init];
    labelTime.frame = CGRectMake(140.0f, 68.0f, 300.0f, 30.0f);
    labelTime.backgroundColor = [UIColor clearColor];
    [labelTime setFont:[UIFont systemFontOfSize:TABLE_FONT_IPAD_SIZE]];
    [labelTime setTextAlignment:NSTextAlignmentLeft];
    [labelTime setTextColor:[UIColor lightGrayColor]];
    
    imgStatus = [[UIImageView alloc] init];
    imgStatus.frame = CGRectMake(580.0f, 12.0f, 49.0f, 37.0f);
    [self.contentView addSubview:imgStatus];
    
    labelStatus = [[UILabel alloc]init];
    labelStatus.frame = CGRectMake(560, 68, 180, 30);
    labelStatus.backgroundColor = [UIColor clearColor];
    [labelStatus setFont:[UIFont systemFontOfSize:TABLE_FONT_IPAD_SIZE]];
    [labelStatus setTextAlignment:NSTextAlignmentLeft];
    [labelStatus setTextColor:[UIColor lightGrayColor]];
    
    
    UIImageView *bottomLine = [[UIImageView alloc] init];
    bottomLine.frame = CGRectMake(56.0f, 129.0f, 658.0f, 1.0f);
    bottomLine.image = [UIImage imageNamed:@"personinfo_line.png"];
    [self.contentView addSubview:bottomLine];
    
    [self.contentView addSubview:labelTime];
    [self.contentView addSubview:labelOperationName];
    [self.contentView addSubview:labelStatus];

}
- (void)drawCell     {
    if (ISIPAD) {
        [self drawPad];
        return;
    }
    
	self.backgroundColor = [UIColor clearColor];
	
	imgIcon = [[UIImageView alloc] init];
	imgIcon.frame = CGRectMake(15.0f, 22.0f, 27.0f, 25.0f);
	[self.contentView addSubview:imgIcon];
	
	
    
    labelOperationName = [[UILabel alloc]init];
    labelOperationName.frame = CGRectMake(60, 13, 150, 18);
    labelOperationName.backgroundColor = [UIColor clearColor];
    [labelOperationName setFont:[UIFont systemFontOfSize:TABLE_FONT_SIZE]];
	[labelOperationName setTextAlignment:NSTextAlignmentLeft];
	[labelOperationName setTextColor:[UIColor whiteColor]];
	
	labelTime = [[UILabel alloc] init];
	labelTime.frame = CGRectMake(60.0f, 44.0f, 180, 18.0f);
	labelTime.backgroundColor = [UIColor clearColor];
	[labelTime setFont:[UIFont systemFontOfSize:TABLE_FONT_SIZE]];
	[labelTime setTextAlignment:NSTextAlignmentLeft];
	[labelTime setTextColor:[UIColor lightGrayColor]];
    
    imgStatus = [[UIImageView alloc] init];
	imgStatus.frame = CGRectMake(260.0f, 12.0f, 25.0f, 25.0f);
	[self.contentView addSubview:imgStatus];
    
    labelStatus = [[UILabel alloc]init];
    labelStatus.frame = CGRectMake(230, 44, 80, 18);
    labelStatus.backgroundColor = [UIColor clearColor];
    [labelStatus setFont:[UIFont systemFontOfSize:TABLE_FONT_SIZE]];
	[labelStatus setTextAlignment:NSTextAlignmentCenter];
	[labelStatus setTextColor:[UIColor lightGrayColor]];
    
    UIImageView *bottomLine = [[UIImageView alloc] init];
	bottomLine.frame = CGRectMake(15.0f, 69.0f, 290.0f, 1.0f);
	bottomLine.image = [UIImage imageNamed:@"personinfo_line.png"];
	[self.contentView addSubview:bottomLine];
	
	[self.contentView addSubview:labelTime];
    [self.contentView addSubview:labelOperationName];
    [self.contentView addSubview:labelStatus];
}

@end
