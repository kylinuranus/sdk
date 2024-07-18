//
//  SOSPersonInfoItem.m
//  Onstar
//
//  Created by lizhipan on 2017/8/3.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSPersonInfoItem.h"
#import "UITextField+Keyboard.h"


@implementation SOSPersonInfoItem

- (instancetype)initWithItemDesc:(NSString *)itemDesc itemResult:(NSString *)result itemIndex:(NSInteger )index_ isNecessary:(BOOL)isNecess rightArrowVisiable:(BOOL)showRightArrow
{
    {
        if (self = [super init]) {
            _itemDescription = itemDesc;
            _itemResult      = result;
            _itemIndex       = index_;
            _isNecessities   = isNecess;
            _accessoryVisiable = showRightArrow;
        }
        return self;
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
- (NSString *)personInfoValue
{
    if (self.rightFieldView && [self.rightFieldView respondsToSelector:@selector(text)]) {

        if ([self.rightFieldView respondsToSelector:@selector(realText)]) {
            return [self.rightFieldView performSelector:@selector(realText)];
        }
        else
        {
            return [self.rightFieldView performSelector:@selector(text)];
        }
    }
    else
    {
        return _itemResult;
    }
}
#pragma clang diagnostic pop

- (BOOL)isValidateValue
{
    return ![self.itemPlaceholder hasPrefix:@"请"];
}
- (void)setRightFieldView:(UIView *)rightFieldView {
    if ([rightFieldView isKindOfClass:[UITextField class]]) {
        _maxInputLength = ((UITextField *)rightFieldView).maxInputLength;
        _keyBoardType = ((UITextField *)rightFieldView).keyboardType;
    }
    _rightFieldView = rightFieldView;
    _rightFieldView.tag = 111;
}

@end
