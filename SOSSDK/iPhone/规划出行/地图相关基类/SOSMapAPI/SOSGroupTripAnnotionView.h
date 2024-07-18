//
//  SOSGroupTripAnnotionView.h
//  Onstar
//
//  Created by Coir on 2019/11/2.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSMapHeader.h"
#import "SOSGroupTripCalloutView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOSGroupTripAnnotionView : MAAnnotationView

@property (nonatomic, assign) SOSGroupTripTeamMemberStatus memberStatus;
@property (nonatomic, copy) NSString *memberID;

@property (nonatomic, strong) SOSGroupTripCalloutView *calloutView;

@end

NS_ASSUME_NONNULL_END
