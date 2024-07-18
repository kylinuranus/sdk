//
//  SOSUtilConfig.h
//  Onstar
//
//  Created by Genie Sun on 2017/7/25.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

#define STATUS_GRAY     @"CFCFCF"
#define STATUS_RED      @"C50000"
#define STATUS_YELLOW   @"F18F19"
#define STATUS_GREEN    @"304D8F"

typedef NS_ENUM(NSUInteger ,POSITION){
    LEFT_POSITION,
    RIGHT_POSITION
};

@interface SOSUtilConfig : NSObject

/**
 实现view一角及多角的圆角

 @param viewCorner 需要实现的view
 @param corners 上下左右
 @param cornerRadii 圆弧大小
 */
+ (void) setView:(UIView *)viewCorner RoundingCorners:(UIRectCorner)corners withRadius:(CGSize)cornerRadii;

/**
 设置Label文本后面加额外的imageview

 @param attribute 文本
 @param image image
 */
+ (NSMutableAttributedString *) setLabelAttributedText:(NSString*)attribute AttachmentWithView:(UIImage *)image withImagePosition:(POSITION)position;


/**
 设置Label文本后面加额外的imageview
 
 @param attribute 文本
 @param image image
 @param imgRect image偏移量,宽高值无意义
 */
+ (NSMutableAttributedString *) setLabelAttributedText:(NSString*)attribute AttachmentWithView:(UIImage *)image ImageOffset:(CGRect)imgRect withImagePosition:(POSITION)position;

/**
 旋转view

 @param imageView 需要选择的view
 */
+ (void) transformRotationWithView:(UIImageView *)imageView;

/**
 恢复旋转view

 @param imageView 需要选择的view
 */
+ (void) transformIdentityStatusWithView:(UIImageView *)imageView;
/**
 custom navigationBar

 @param title title
 @param target id
 @param action SEL
 */
+ (void) setNavigationBarItemTitle:(NSString *)title target:(id)target selector:(SEL)action;

/**
 根据textfield添加cancel keyboard btn

 @param tf textfield
 */
+ (void) setCancelBackKeyBoardWithTextField:(UITextField *)tf target:(id)tar;

/**
 不同车型不同logo icon

 @return image
 */
+ (UIImage *)returnImageBySortOfCarbrand;

+ (void)rotateView:(UIView *)view;
+ (void)stopRotateAndHideView:(UIView *)view;
@end
