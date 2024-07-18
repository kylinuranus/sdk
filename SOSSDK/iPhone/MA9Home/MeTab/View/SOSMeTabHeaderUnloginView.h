//
//  SOSMeTabHeaderUnloginView.h
//  Onstar
//
//  Created by Onstar on 2019/3/2.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSMeTabHeaderBaseView.h"
NS_ASSUME_NONNULL_BEGIN

@interface SOSMeTabHeaderUnloginView : SOSMeTabHeaderBaseView
@property(nonatomic,strong)UIButton * loginButton;
-(void)unLoginState;
-(void)inLoadingState;
-(void)visitorState;
@end

NS_ASSUME_NONNULL_END
