//
//  SOSStarTravelView.h
//  Onstar
//
//  Created by lmd on 2017/9/26.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSStarTravelView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

- (void)refreshWithResponseData:(NNStarTravelResp*)resp status:(RemoteControlStatus)status;

@end
