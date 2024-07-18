//
//  SOSMeTabHeaderBaseView.h
//  Onstar
//
//  Created by Onstar on 2019/3/5.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SOSMeFunctionType) {
    SOSMeFunctionLogin,  //0
    SOSMeFunctionUpgradeOwner, //
    SOSMeFunctionByOnstarPackage,   //
    SOSMeFunctionByDataPackage
};
@protocol SOSMeTableHeaderViewProtol <NSObject>

@optional
-(void)loginViewPackageExpiredState;
-(void)functionButtonWithType:(NSNumber *)buttonType;

@end
@interface SOSMeTabHeaderBaseView : UIView
@property(nonatomic,weak)id<SOSMeTableHeaderViewProtol>delegate;
@property(nonatomic,assign) SOSMeFunctionType functionType;
@end

NS_ASSUME_NONNULL_END
