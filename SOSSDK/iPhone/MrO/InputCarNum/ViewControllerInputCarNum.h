//
//  ViewControllerInputCarNum
//  Onstar
//
//  Created by Vicky on 15/5/26.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>




//请求违章信息
@protocol ToRequestViolationListDelegate <NSObject>

- (void)toRequestViolationList_carNum:(NSString *)carNum engineNum:(NSString *)engineNum;

@end


@interface ViewControllerInputCarNum : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSString *carNumString;
@property (strong, nonatomic) IBOutlet UITextField *textCarNum;
@property (strong, nonatomic) IBOutlet UITextField *textEngine;
@property (strong, nonatomic) IBOutlet UILabel *labelTipCarNum;
@property (strong, nonatomic) IBOutlet UILabel *labelTipEngine;
@property (strong, nonatomic) IBOutlet UIImageView *carNumImageV;
@property (strong, nonatomic) IBOutlet UIImageView *engineImageV;
@property (strong, nonatomic) IBOutlet UIView *bgView;
//@property (strong, nonatomic) IBOutlet UIButton *commitBtn;
//@property (strong, nonatomic) IBOutlet UIImageView *btnImageV;
//@property (strong, nonatomic) IBOutlet UITextField *btnField;

@property (nonatomic, weak) id<ToRequestViolationListDelegate> reqViolationDelegate;

@end
