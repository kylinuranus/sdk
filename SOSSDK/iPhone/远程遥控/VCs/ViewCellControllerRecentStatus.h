//
//  ViewCellControllerRecentStatus.h
//  Onstar
//
//  Created by Alfred Jin on 2/8/11.
//  Copyright 2011 plenware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewCellControllerRecentStatus : UITableViewCell  {
	
	IBOutlet UILabel * labelTime;
	
    IBOutlet UILabel *labelStatus;
    IBOutlet UILabel *labelOperationName;
	IBOutlet UIImageView *imgIcon;
	IBOutlet UIImageView *imgStatus;
	
}

@property (strong, nonatomic) UILabel * labelTime;
@property (strong, nonatomic) UIImageView *imgIcon;
@property (strong, nonatomic) UIImageView *imgStatus;
@property (strong, nonatomic) UILabel * labelOperationName;
@property (strong, nonatomic) UILabel *labelStatus;
- (void)drawCell;

@end
