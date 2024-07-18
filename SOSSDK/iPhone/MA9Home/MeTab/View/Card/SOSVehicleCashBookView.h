//
//  SOSVehicleCashBookView.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/8.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSVehicleCashBookView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *bgView;

- (void)refreshWithResponseData:(NNVehicleCashResp *)responseData status:(RemoteControlStatus)status;


@end
