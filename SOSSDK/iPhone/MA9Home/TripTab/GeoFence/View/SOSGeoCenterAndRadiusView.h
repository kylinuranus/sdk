//
//  SOSGeoCenterAndRadiusView.h
//  Onstar
//
//  Created by Coir on 2019/6/17.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SOSGeoCenterAndRadiusDelegate <NSObject>

@optional
- (void)geoRadiusChangedWithGeofence:(NNGeoFence *)geofence;

- (void)geoCenterAndRadiusViewBackButtonTapped;

- (void)geoCenterAndRadiusViewSaveButtonTapped;

@end

@interface SOSGeoCenterAndRadiusView : UIView

// 首次和非首次呈现时,返回和保存的事件不同
@property (nonatomic, assign) BOOL isFirstCard;
@property (nonatomic, copy) NNGeoFence *geofence;
@property (weak, nonatomic) IBOutlet UISlider *geoRadiusSlider;

@property (weak, nonatomic) UIViewController *vc;

@property (nonatomic, weak) id<SOSGeoCenterAndRadiusDelegate> delegate;

- (void)saveButtonTapped;

@end

NS_ASSUME_NONNULL_END
