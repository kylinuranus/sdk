//
//  ChargeModeViewController.h
//  Onstar
//
//  Created by Vicky on 15/12/1.
//  Copyright © 2015年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChargeModeDelegate <NSObject>

- (void)getCurrentSchedule;

@end

@interface ChargeModeViewController : SOSBaseViewController {
    
//    __weak IBOutlet UILabel *labelTitle;
//    __weak IBOutlet UILabel *labelChargeNowTitle;
//    __weak IBOutlet UILabel *labelChargeNowDesc;
//    __weak IBOutlet UILabel *labelChargeDelayTitle;
//    __weak IBOutlet UILabel *labelChargeDelayDesc;
//    __weak IBOutlet UILabel *labelChargeSmartTitle;
//    __weak IBOutlet UILabel *labelChargeSmartDesc;
//    __weak IBOutlet UILabel *labelDepatureTimeTitle;
//    __weak IBOutlet UIButton *buttonChargeNow;
//    __weak IBOutlet UIButton *buttonChargeDelay;
//    __weak IBOutlet UIButton *buttonChargeSmart;
//    __weak IBOutlet UIButton *buttonDepatureTime;
//    __weak IBOutlet UILabel *labelSave;
//    IBOutlet UIButton *buttonSave;
    
//    IBOutlet UIButton *buttonAlert;
//    IBOutlet UILabel *labelAlert;
    
}
@property (nonatomic, assign) BOOL flag;
//- (IBAction)buttonSaveTapped:(id)sender;
//- (void)getChargeMode;
@end
