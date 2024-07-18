//
//  SOSmailTableViewCell.m
//  Onstar
//
//  Created by Genie Sun on 2017/3/23.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSmailTableViewCell.h"

@implementation SOSmailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 25)];
    customView.backgroundColor = [UIColor clearColor];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(customView.frame.size.width-35, -4, 35, 29)];
    [btn setImage:[UIImage imageNamed:@"down_normal.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"down_highlight.png"] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:@"down_highlight.png"] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(cancelBackKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:btn];
    self.codeTf.inputAccessoryView = customView;
}

- (void)cancelBackKeyboard:(id)sender     {
    [self.codeTf resignFirstResponder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)send:(id)sender {
    if (self.sendBtn) {
        self.sendBtn(sender);
    }
}

- (void)sendCodeBtn:(SendCodeBtn)sendbtn
{
    if (sendbtn) {
        self.sendBtn = sendbtn;
    }
}

@end
