//
//  SOSCarSecretarySectionHeaderView.h
//  Onstar
//
//  Created by TaoLiang on 2018/1/29.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SaveBtnAction)(void);

@interface SOSCarSecretarySectionHeaderView : UIView
@property (copy, nonatomic) NSString *title;
//- (void)showSaveBtn:(SaveBtnAction)action;
@end
