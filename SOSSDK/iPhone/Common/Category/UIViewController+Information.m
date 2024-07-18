//
//  UIViewController+Information.m
//  Onstar
//
//  Created by Apple on 16/8/16.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "UIViewController+Information.h"
#import <objc/runtime.h>


static const void *kBackRecordFunctionID = "backRecordFunctionID";
static const void *kNavigationBackButton = "navigationBackButton";
static const void *kBackDaapFunctionID = "backDaapFunctionID";
static const void *kBackClickBlockID = "backClickBlockID";

//backDaapFunctionID
@implementation UIViewController (Information)

#pragma mark - 字符串类型的动态绑定
- (completedBlock)backClickBlock	{
    return objc_getAssociatedObject(self, kBackClickBlockID);
}

- (void)setBackClickBlock:(completedBlock)backClickBlock	{
    objc_setAssociatedObject(self, kBackClickBlockID, backClickBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


- (NSString *)backRecordFunctionID {
    return objc_getAssociatedObject(self, kBackRecordFunctionID);
}

- (void)setBackRecordFunctionID:(NSString *)backRecordFunctionID {
    objc_setAssociatedObject(self, kBackRecordFunctionID, backRecordFunctionID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)backDaapFunctionID {
    return objc_getAssociatedObject(self, kBackDaapFunctionID);

}

- (void)setBackDaapFunctionID:(NSString *)backDaapFunctionID {
    objc_setAssociatedObject(self, kBackDaapFunctionID, backDaapFunctionID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


- (UIButton *)navigationBackButton {
    return objc_getAssociatedObject(self, kNavigationBackButton);
}

- (void)setNavigationBackButton:(UIButton *)navigationBackButton {
    objc_setAssociatedObject(self, kNavigationBackButton, navigationBackButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController *)findVCInSelfNavWithClassName:(NSString *)className     {
    UIViewController *vc = nil;
    for (vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:NSClassFromString(className)]) {
            break;
        }
    }
    return vc;
}

- (void)setRightBarButtonItemWithTitle:(NSString *)title AndActionBlock:(void (^)(id item))block	{
    UIBarButtonItem *rightItem = [self getBarButtonItemWithTitle:title AndActionBlock:block];
    self.navigationItem.rightBarButtonItem = rightItem;
}
- (void)setLeftBackBtnCallBack:(dispatch_block_t)callBack {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"common_Nav_Back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_Nav_Back"] forState:UIControlStateHighlighted];
    button.size = CGSizeMake(30, 44);
    button.backgroundColor = [UIColor clearColor];
    // 让按钮内部的所有内容左对齐
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    // 让按钮的内容往左边偏移10
    button.contentEdgeInsets = UIEdgeInsetsMake(0, -1, 0, 0);
    [button sizeToFit];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        callBack();
    }];
    self.navigationItem.leftBarButtonItem = leftItem;
}
- (UIButton *)addRightButtonTitle:(NSString *)title callBack:(dispatch_block_t)callBack {
    UIBarButtonItem *rightItem = [self getBarButtonItemWithTitle:title AndActionBlock:nil];
    return nil;
}
- (void)setRightBarButtonItemWithImageName:(NSString *)imageName callBack:(dispatch_block_t)callBack {
    UIImage *image = [UIImage imageNamed:imageName];
    UIBarButtonItem *rightItem = [self getBarButtonItemImage:image callBack:callBack];
    self.navigationItem.rightBarButtonItem = rightItem;
}
- (void)setLeftBarButtonItemWithTitle:(NSString *)title AndActionBlock:(void (^)(id item))block	{
    UIBarButtonItem *rightItem = [self getBarButtonItemWithTitle:title AndActionBlock:block];
    self.navigationItem.leftBarButtonItem = rightItem;
}

- (UIBarButtonItem *)getBarButtonItemWithTitle:(NSString *)title AndActionBlock:(void (^)(id item))block	{
    UIButton *rightButton = [[UIButton alloc] init];
    [rightButton setTitleForNormalState:title];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightButton setTitleColor:[UIColor colorWithHexString:@"067FE0"] forState:UIControlStateNormal];
    [rightButton sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [[rightButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        block(item);
    }];
    return item;
}
- (void)clearNavVCWithClassNameArray:(NSArray<NSString *> *)classNameArray      {
    NSMutableArray *navVcArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [navVcArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIViewController *vc = obj;
        for (NSString *className in classNameArray) {
            if ([vc isKindOfClass:NSClassFromString(className)]) {
                [navVcArray removeObject:vc];
            }
        }
    }];
    [self.navigationController setViewControllers:navVcArray];
}
- (UIBarButtonItem *)getBarButtonItemImage:(UIImage *)image callBack:(dispatch_block_t)callBack {
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setImage:image forState:UIControlStateNormal];
    [rightButton setImage:image forState:UIControlStateHighlighted];
    [rightButton sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [[rightButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        callBack();
    }];
    return item;
}
@end
