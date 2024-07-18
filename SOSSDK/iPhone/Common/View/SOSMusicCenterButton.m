//
//  SOSMusicCenterButton.m
//  Onstar
//
//  Created by TaoLiang on 2018/3/22.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSMusicCenterButton.h"

@implementation SOSMusicCenterButton

- (void)layoutSubviews {
    [super layoutSubviews];
    // Center image
    CGPoint center = self.imageView.center;
    center.x = self.frame.size.width/2;
    center.y = self.frame.size.height/2 - 10;
    self.imageView.center = center;
    
    //Center text
    CGRect newFrame = [self titleLabel].frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = self.imageView.bottom + 10;
    newFrame.size.width = self.frame.size.width;
    
    self.titleLabel.frame = newFrame;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

@end
