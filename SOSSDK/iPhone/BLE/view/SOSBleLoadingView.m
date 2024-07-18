//
//  SOSBleLoadingView.m
//  Onstar
//
//  Created by onstar on 2018/8/6.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleLoadingView.h"

@interface SOSBleLoadingView ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@end

@implementation SOSBleLoadingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib {
    [super awakeFromNib];
    [self.activityView startAnimating];
}


@end
