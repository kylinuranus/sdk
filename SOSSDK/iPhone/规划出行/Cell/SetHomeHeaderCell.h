//
//  SetHomeHeaderCell.h
//  Onstar
//
//  Created by Coir on 16/2/17.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetHomeHeaderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *myPositionButton;
@property (strong, nonatomic) IBOutlet UIButton *buttonCenter;
@property (strong, nonatomic) IBOutlet UIButton *buttonFavorite;

@property (nonatomic, weak) UINavigationController *nav;

@end
