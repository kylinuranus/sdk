//
//  SOSOilGunSelectCell.m
//  Onstar
//
//  Created by Coir on 2019/9/1.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSOilGunSelectCell.h"

@interface SOSOilGunSelectCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation SOSOilGunSelectCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setTitle:(NSString *)title	{
    _title = title;
    self.titleLabel.text = [NSString stringWithFormat:@"%@号枪", title];
}

- (void)setSelectState:(BOOL)selectState	{
    _selectState = selectState;
    if (selectState) {
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = [UIColor colorWithHexString:@"6896ED"];
        self.titleLabel.layer.borderWidth = 0;
    }	else	{
        self.titleLabel.textColor = [UIColor colorWithHexString:@"828389"];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.layer.borderWidth = .8;
    }
}

@end
