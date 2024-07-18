//
//  SelectPayWaysView.m
//  Onstar
//
//  Created by huyuming on 16/1/22.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SelectPayWaysView.h"

@implementation SelectPayWaysView     {
    

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _channelTable.frame= CGRectMake(_channelTable.frame.origin.x, _channelTable.frame.origin.y, self.frame.size.width-10, self.frame.size.height - 55);
}
- (IBAction)backAct:(id)sender {
    NSLog(@"backAct===");
    if (self.payWaysDelegate && [self.payWaysDelegate respondsToSelector:@selector(backFromSelectPayWays)]) {
        [self.payWaysDelegate backFromSelectPayWays];
    }
}

//- (IBAction)userPayWay:(UIButton *)sender {
//    CGRect ect = self.checkHookIV.frame;
//    ect.origin.y = sender.origin.y;
//    self.checkHookIV.frame = ect;
//    self.checkHookIV.hidden = NO;
//    
//    if (self.payWaysDelegate && [self.payWaysDelegate respondsToSelector:@selector(userPayWay:)]) {
//        [self.payWaysDelegate userPayWay:sender];
//    }
//   
//}



@end
