//
//  SOSAlertView.h
//  Onstar
//
//  Created by Genie Sun on 16/6/29.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//
//根据需求自定义弹出框

#import <UIKit/UIKit.h>

/// 弹出框的展示内容形式
typedef NS_ENUM(NSUInteger ,AlertPageType){
    SOS_LabelType = 0,
    SOS_WebViewType,
    SOS_TextFieldType,
    SOS_TextViewType,
    SOS_ViewType,
    SOS_ImageViewType
};

@interface SOSAlertView : UIView
@property (assign, nonatomic) BOOL     isTCPSAlert;//是否用于显示tcps新协议
@property (strong, nonatomic) NSString *title; // 标题
@property (strong, nonatomic) NSString *cancelStr; // cancel 按钮
@property (strong, nonatomic) NSString *submitStr; // submit 按钮
@property (strong, nonatomic) UIView *maskView;           //遮罩
@property (strong, nonatomic) UILabel *titleLabel;           //标题LB
@property (strong, nonatomic) UIButton *completeBtn;        // 确定按钮
@property (strong, nonatomic) UIButton *cancelButton; //取消按钮
@property (strong, nonatomic) WKWebView *sosWebView; // 嵌套H5

@property (copy, nonatomic) void (^agreeAction)(BOOL flag); //回调 Block
- (void)loadURL_No_header:(NSString *)strURL;
- (void)showAlertView;  //展示
- (void)dismissAlertView;  //消失

@end
