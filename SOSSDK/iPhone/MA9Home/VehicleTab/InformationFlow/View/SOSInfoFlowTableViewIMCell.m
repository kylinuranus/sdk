//
//  SOSInfoFlowTableViewIMCell.m
//  Onstar
//
//  Created by TaoLiang on 2018/12/20.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSInfoFlowTableViewIMCell.h"
#ifndef SOSSDK_SDK
#import "NIMBadgeView.h"
#import "SOSIMNotificationCenter.h"
#endif
@interface SOSInfoFlowTableViewIMCell ()
#ifndef SOSSDK_SDK
<SOSIMNotificationCenterDelegate>
@property (strong, nonatomic) NIMBadgeView *badgeView;
#endif
@end

@implementation SOSInfoFlowTableViewIMCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
#ifndef SOSSDK_SDK
        _badgeView = [NIMBadgeView viewWithBadgeTip:@"0"];
        [self.rightPartView addSubview:_badgeView];
        [_badgeView mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.bottom.equalTo(@-15);
        }];
        [[SOSIMNotificationCenter sharedCenter] addDelegate:self];
#endif
    }
    return self;
}

- (void)fillData:(SOSInfoFlow *)infoFlow atIndexPath:(NSIndexPath *)indexPath {
    [super fillData:infoFlow atIndexPath:indexPath];
    self.funcBtn.hidden = YES;
#ifndef SOSSDK_SDK
    [self setUnreadNum:[SOSIMNotificationCenter sharedCenter].unreadCount];
#endif
}

- (void)setUnreadNum:(NSUInteger)unreadNum {
#ifndef SOSSDK_SDK
    _unreadNum = unreadNum;
    _badgeView.badgeValue = unreadNum > 0 ? [NSString stringWithFormat:@"%@", @(unreadNum)] : @"";
    _badgeView.hidden = unreadNum <= 0;
    [_badgeView layoutIfNeeded];
#endif
}

- (void)didMessageUnreadNumChanged:(NSUInteger)unreadNum {
#ifndef SOSSDK_SDK
    [self setUnreadNum:[SOSIMNotificationCenter sharedCenter].unreadCount];
#endif
}

- (void)dealloc {
#ifndef SOSSDK_SDK
    [[SOSIMNotificationCenter sharedCenter] removeDelegate:self];
#endif
}

@end
