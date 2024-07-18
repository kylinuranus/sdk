//
//  SOSYearReportView.h
//  Onstar
//
//  Created by WQ on 2019/1/9.
//  Copyright © 2019年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSSimplePopView : UIView

+(SOSSimplePopView*)instanceView;
@property (weak, nonatomic) IBOutlet UIImageView *displayImage;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (copy, nonatomic)  NSString *clickFunctionID;
@property (copy, nonatomic)  NSString *closeFunctionID;

@property (nonatomic, copy) void(^dismissComplete)(void);
-(void)configWithDic:(NSDictionary *)model;
@end

NS_ASSUME_NONNULL_END
