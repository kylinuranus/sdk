//
//  SOSTripGeoInfoView.h
//  Onstar
//
//  Created by Coir on 2019/6/12.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SOSGeoInfoViewDelegate <NSObject>

- (void)geoRadiusButtonTapped;

@end

@interface SOSTripGeoInfoView : UIView

@property (nonatomic, copy) NNGeoFence *geofence;

@property (nonatomic, weak) id<SOSGeoInfoViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
