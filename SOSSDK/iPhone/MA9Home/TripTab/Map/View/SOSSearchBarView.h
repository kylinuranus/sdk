//
//  SOSSearchBarView.h
//  Onstar
//
//  Created by Coir on 2019/4/8.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// SearchBarView Mode
typedef enum {
    /// 列表模式,显示返回 Button 以及中心 Title
    SOSSearchBarViewMode_List = 1,
    /// 详情模式,显示输入框以及清除 Button
    SOSSearchBarViewMode_Detail
} SOSSearchBarViewMode;

@interface SOSSearchBarView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) SOSSearchBarViewMode viewMode;
@property (weak, nonatomic) IBOutlet UIButton *listModeRightButton;

- (void)lockStateChange:(BOOL)lock;

@end

NS_ASSUME_NONNULL_END
