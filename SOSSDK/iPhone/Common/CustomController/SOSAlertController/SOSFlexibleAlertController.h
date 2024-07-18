//
//  SOSFlexibleAlerController.h
//  Onstar
//
//  Created by TaoLiang on 2018/12/24.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SOSAlertActionStyle) {
    //UI上AlertView的默认按钮颜色是蓝色，该枚举代表蓝色
    SOSAlertActionStyleDefault = 0,
    SOSAlertActionStyleCancel,
    SOSAlertActionStyleDestructive,
    SOSAlertActionStyleGray,
    //UI上ActionSheet的默认按钮颜色是黑色，该枚举代表黑色
    SOSAlertActionStyleActionSheetDefault
};

typedef NS_ENUM(NSInteger, SOSAlertControllerStyle) {
    SOSAlertControllerStyleActionSheet = 0,
    SOSAlertControllerStyleAlert
};


@interface SOSAlertAction : NSObject

@property (copy, nonatomic, readonly) NSString *title;
@property (assign, nonatomic, readonly) SOSAlertActionStyle style;
@property (strong, nonatomic) UIColor *titleColor;
@property (strong, nonatomic) UIFont *font;

+ (instancetype)actionWithTitleOnStarStyle:(NSString *)title style:(SOSAlertActionStyle)style handler:(void (^)(SOSAlertAction * _Nonnull))handler;
+ (instancetype)actionWithTitle:(NSString *)title style:(SOSAlertActionStyle)style handler:(nullable void (^)(SOSAlertAction *action))handler;
@end

@interface SOSFlexibleAlertController : UIViewController
@property (copy, nonatomic, readonly) NSArray <SOSAlertAction *>*actions;
@property (strong, nonatomic, readonly) UIImage *titleImage;
@property (copy, nonatomic, readonly) NSString *alertTitle;
@property (copy, nonatomic, readonly) NSString *message;
@property (strong, nonatomic, readonly) __kindof UIView *customView;
@property (assign, nonatomic, readonly) SOSAlertControllerStyle preferredStyle;
@property (strong, nonatomic, readonly) UIView *alertContainerView;
@property(copy,nonatomic) UIButton *(^rightButtonBlock)(void);
//可变值
//@property (assign, nonatomic) BOOL enabledBlurEffect;
@property (strong, nonatomic) UIColor *titleColor;
@property (strong, nonatomic) UIFont *titleFont;
@property (strong, nonatomic) UIColor *separatorColor;
@property (strong, nonatomic) UIImageView *titleImageView;

@property (nonatomic) float margins; //设置弹框-2边距


/**
 返回一个AlertController实例
 
 @param image 图片
 @param title 标题
 @param message 内容
 @param customView 自定义View
 @param preferredStyle style
 @return 实例
 */
+ (instancetype)alertControllerWithImage:(nullable UIImage *)image
                                   title:(nullable NSString *)title
                                 message:(nullable NSString *)message
                              customView:(nullable __kindof UIView *)customView
                          preferredStyle:(SOSAlertControllerStyle)preferredStyle;



+ (instancetype)alertControllerWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message customView:(__kindof UIView *)customView preferredStyle:(SOSAlertControllerStyle)preferredStyle isOnStarStyle:(bool)isOnStarStyleRef;



/**
 返回一个AlertController实例
 
 @param imageURL 图片URL
 @param width   图片宽度，传CGFLOAT_MAX则显示图片实际宽度
 @param height  图片高度，传CGFLOAT_MAX则显示图片实际高度
 @param title 标题
 @param message 内容
 @param customView 自定义View
 @param preferredStyle style
 @return 实例
 */
+ (instancetype)alertControllerWithImageURL:(nonnull NSString  *)imageURL
                           placeholderImage:(UIImage*)placeholder
                                      width:(CGFloat)width
                                     height:(CGFloat)height
                                      title:(nullable NSString *)title
                                    message:(nullable NSString *)message
                                 customView:(nullable __kindof UIView *)customView
                             preferredStyle:(SOSAlertControllerStyle)preferredStyle;




/**
 添加按钮对象
 
 @param actions 按钮对象数组
 */
- (void)addActions:(NSArray <SOSAlertAction *>*)actions;


/**
 使用show方法显示,不要使用presentViewController
 */
- (void)show;
- (void)show:(BOOL)animated;
- (void)show:(BOOL)animated completion:(void (^ __nullable)(void))completion;
@end

NS_ASSUME_NONNULL_END
