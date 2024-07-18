//
//  SOSTopPromptView.h
//  Onstar
//
//  Created by TaoLiang on 2018/12/28.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SOSTopPromptStyle) {
    SOSTopPromptStyleUndefine,
    SOSTopPromptStyleLogining,
    SOSTopPromptStyleRefreshing,
    SOSTopPromptStyleRefreshFailed,
    SOSTopPromptStyleNetworkError
};
#define KTOPTAG 9924
@interface SOSTopPromptView : UIView

@property (assign, nonatomic) SOSTopPromptStyle style;

@property(copy, nonatomic) void (^refreshHandler)(void);

@property (assign, nonatomic) BOOL showing;


//- (void)show;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
