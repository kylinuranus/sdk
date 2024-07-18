//
//  SOSGroupTripAnnotionView.m
//  Onstar
//
//  Created by Coir on 2019/11/2.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSGroupTripAnnotionView.h"

const  NSNotificationName KNotiNameGroupTripSelectMember = @"KNotiNameGroupTripSelectMember";
const  NSNotificationName KNotiNameGroupTripPreventDeSelectMember = @"KNotiNameGroupTripPreventDeSelectMember";

@interface SOSGroupTripAnnotionView ()

@property (nonatomic, assign) BOOL shouldPreventDeSelectNoti;

@end

@implementation SOSGroupTripAnnotionView

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier	{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addObserver];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated  {
    if (self.selected == selected || self.memberStatus == SOSGroupTripTeamMemberStatus_Normal)      return;
    if (selected)   {
        if (self.calloutView == nil) {
            self.calloutView = [SOSGroupTripCalloutView viewFromXib];
            self.calloutView.frame = CGRectMake(0, 0, 122, 53);
            self.calloutView.center = CGPointMake(61, 33.5);
        }
        [self.calloutView configSelfWithStatus:self.memberStatus];
        [self insertSubview:self.calloutView belowSubview:self.imageView];
    }   else    {
        [self.calloutView removeFromSuperview];
    }
    if (self.shouldPreventDeSelectNoti == NO) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotiNameGroupTripSelectMember object:@[self.memberID, @(selected)]];
    }
    [super setSelected:selected animated:animated];
}

- (void)addObserver 	{
    __weak __typeof(self) weakSelf = self;
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotiNameGroupTripPreventDeSelectMember object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSNumber *shouldDeselect = x.object;    // ex: @[self.memberID, @(selected)]
        if (shouldDeselect && [shouldDeselect isKindOfClass:[NSNumber class]]) {
            weakSelf.shouldPreventDeSelectNoti = shouldDeselect.boolValue;
        }
    }];
}

- (NSString *)memberID	{
    return _memberID.length ? _memberID : @"";
}

@end
