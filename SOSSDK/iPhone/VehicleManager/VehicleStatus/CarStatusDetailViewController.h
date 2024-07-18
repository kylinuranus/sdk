//
//  CarStatusDetailViewController.h
//  Onstar
//
//  Created by Joshua on 14-9-10.
//  Copyright (c) 2014年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarStatusDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>     {
    IBOutlet UITableView *contentTableView;
    IBOutlet UIButton *searchDealerButton;
    IBOutlet UIView *bannerContentView;
    __weak IBOutlet UIView *noMaintenanceSgstView;
}

@property (nonatomic, assign) VehicleStatus gasStatus;
@property (nonatomic, assign) VehicleStatus oilStatus;
@property (nonatomic, assign) VehicleStatus pressureStatus;
@property (nonatomic, assign) VehicleStatus batteryStatus;
@property (nonatomic, assign) CGFloat mileage;
@property (nonatomic, assign) BOOL isFromOwnerLife;//从车主生活点击保养，reportID不一样

@end
