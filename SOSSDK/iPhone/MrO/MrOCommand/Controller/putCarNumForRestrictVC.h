//
//  putCarNumForRestrictVC.h
//  Onstar
//
//  Created by huyuming on 15/10/27.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>



//请求违章信息
@protocol ToReqRestrictDelegate <NSObject>

//- (void)toReqRestrict_carNum:(NSString *)carNum;

@end


@interface putCarNumForRestrictVC : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *textCarNum;
//@property (retain, nonatomic) IBOutlet UITextField *textEngine;
@property (strong, nonatomic) IBOutlet UILabel *labelTipCarNum;
//@property (retain, nonatomic) IBOutlet UILabel *labelTipEngine;
@property (strong, nonatomic) IBOutlet UIImageView *carNumImageV;
//@property (retain, nonatomic) IBOutlet UIImageView *engineImageV;
@property (strong, nonatomic) IBOutlet UIView *bgView;
@property (strong, nonatomic) IBOutlet UIButton *commitBtn;


- (IBAction)sureAct:(UIButton *)sender;

@property (nonatomic, weak) id<ToReqRestrictDelegate> reqRestrictDelegate;

@end
