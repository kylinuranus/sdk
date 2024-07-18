//
//  ViewControllerFingerprintpw.h
//  Onstar
//
//  Created by Genie Sun on 16/1/21.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewControllerFingerprintpw : UIViewController
@property (strong, nonatomic) IBOutlet UISwitch *fingerSwitch;
@property (weak, nonatomic) IBOutlet UILabel *onstarLb;
@property (weak, nonatomic) IBOutlet UILabel *openFingerLb;
//@property (weak, nonatomic) IBOutlet UILabel *fingerUnlock;
@property (weak, nonatomic) IBOutlet UIImageView *fingerprintIcon;

//@property (weak, nonatomic) IBOutlet UIImageView *cellIcon;
@property (weak, nonatomic) IBOutlet UILabel *agreementLabel;

@end
