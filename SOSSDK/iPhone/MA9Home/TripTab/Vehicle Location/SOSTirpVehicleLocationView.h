//
//  SOSTirpVehicleLocationView.h
//  Onstar
//
//  Created by Coir on 2018/12/19.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    SOSVehicleLocationCardStatus_loading = 1,
    SOSVehicleLocationCardStatus_fail,
    SOSVehicleLocationCardStatus_success
}	SOSVehicleLocationCardStatus;

@protocol SOSTirpVehicleLocationDelegate <NSObject>

@optional
- (void)refreshVehicleLocationButtonTapped;
- (void)vehicleSwitchCarButtonTapped;

@end

@interface SOSTirpVehicleLocationView : UIView

@property (nonatomic, weak) id<SOSTirpVehicleLocationDelegate> delegate;

@property (nonatomic, assign) SOSVehicleLocationCardStatus cardStatus;

@property (nonatomic, strong) SOSPOI *vehicleLocationPOI;

- (void)refreshTimeLabel;

@end

NS_ASSUME_NONNULL_END
