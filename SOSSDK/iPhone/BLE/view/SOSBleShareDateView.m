//
//  SOSBleShareDateView.m
//  Onstar
//
//  Created by onstar on 2018/7/24.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleShareDateView.h"
#import "DateTools.h"

@interface SOSBleShareDateView ()

@property (weak, nonatomic) IBOutlet UIButton *startYmdButton;
@property (weak, nonatomic) IBOutlet UIButton *endYmdButton;
@property (weak, nonatomic) IBOutlet UIButton *startHmButton;
@property (weak, nonatomic) IBOutlet UIButton *endHmButton;

@end

@implementation SOSBleShareDateView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.startYmdButton setTitle:[[NSDate date] stringWithFormat:@"yyyy/MM/dd"] forState:UIControlStateNormal];
    [self.startHmButton setTitle:[[NSDate date] stringWithFormat:@"HH:mm"] forState:UIControlStateNormal];
    NSDate *tomorrow = [[NSDate date] dateByAddingDays:1];
    [self.endYmdButton setTitle:[tomorrow stringWithFormat:@"yyyy/MM/dd"] forState:UIControlStateNormal];
    [self.endHmButton setTitle:@"00:00" forState:UIControlStateNormal];
}

- (IBAction)dateButtonTap:(UIButton *)sender {
    !self.dateButtonTapBlock?:self.dateButtonTapBlock(self,sender);
}

- (IBAction)shareToWechat:(id)sender {
    !self.shareButtonTapBlock?:self.shareButtonTapBlock(self);
}

- (IBAction)bgTap:(id)sender {
    self.layer.opacity = 1.0f;
//    CATransform3D currentTransform = self.layer.transform;
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
//                         self.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         self.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
                     }
     ];
}

- (void)dismiss {
    [self bgTap:nil];
}

- (NSDate *)startTime {
    NSString *dateString = [NSString stringWithFormat:@"%@ %@",self.startYmdButton.titleLabel.text,self.startHmButton.titleLabel.text];
    return [NSDate dateWithString:dateString format:@"yyyy/MM/dd HH:mm"];
}

- (NSDate *)endTime {
    NSString *dateString = [NSString stringWithFormat:@"%@ %@",self.endYmdButton.titleLabel.text,self.endHmButton.titleLabel.text];
    return [NSDate dateWithString:dateString format:@"yyyy/MM/dd HH:mm"];
}

- (void)equalStartTime {
    if ([self.startTime isLaterThan:self.endTime]) {
        
        NSDate *tomorrow = [self.startTime dateByAddingDays:1];
        [self.endYmdButton setTitle:[tomorrow stringWithFormat:@"yyyy/MM/dd"] forState:UIControlStateNormal];
        [self.endHmButton setTitle:@"00:00" forState:UIControlStateNormal];
    }
}

@end
