//
//  SOSTirpUserLocationView.h
//  Onstar
//
//  Created by Coir on 2018/12/19.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    SOSUserLocationCardStatus_loading = 1,
    SOSUserLocationCardStatus_fail,
    SOSUserLocationCardStatus_success
}	SOSUserLocationCardStatus;

@protocol SOSTirpUserLocationDelegate <NSObject>

@optional
- (void)refreshLocationButtonTapped;

@end

@interface SOSTirpUserLocationView : UIView

@property (nonatomic, weak) id<SOSTirpUserLocationDelegate> delegate;

@property (nonatomic, assign) SOSUserLocationCardStatus cardStatus;

@property (nonatomic, strong) SOSPOI *userLocationPOI;

- (void)refreshTimeLabel;

@end

NS_ASSUME_NONNULL_END
