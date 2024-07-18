//
//  SOSPinPasswordView.m
//  Onstar
//
//  Created by onstar on 2018/12/26.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSPinPasswordView.h"

@interface PinTextField : UITextField @end

@implementation PinTextField

- (void)deleteBackward {
    [super deleteBackward];
    
    if ([self.delegate respondsToSelector:@selector(sos_textFieldDeleteBackward:)]) {
        [self.delegate performSelector:@selector(sos_textFieldDeleteBackward:) withObject:self];
    }
}

@end

@interface SOSPinPasswordView ()<UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *textFieldArray;
@property (nonatomic, strong) PinTextField *movingTextField;
@property (nonatomic, assign) int currentIndex;
@end

@implementation SOSPinPasswordView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initUI];
    }
    return self;
}


- (PinTextField *)getTextField {
    PinTextField *textField = [PinTextField new];
    textField.backgroundColor = UIColorHex(#F3F5FE);
    textField.layer.cornerRadius = 4;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.tintColor = UIColorHex(#4E5059);
//    textField.delegate = self;
    textField.secureTextEntry = YES;
    textField.keyboardType = UIKeyboardTypeNamePhonePad;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    return textField;
}

- (PinTextField *)movingTextField {
    if (!_movingTextField) {
        _movingTextField = [self getTextField];
        _movingTextField.delegate = self;
        [_movingTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:_movingTextField];
    }
    return _movingTextField;
}

- (void)initUI {
    
    for (int i = 0; i < 6; i++) {
        PinTextField *textField = [self getTextField];
        textField.tag = 100 + i;
        textField.enabled = NO;
        [self addSubview:textField];
        [self.textFieldArray addObject:textField];
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(44);
            make.top.bottom.mas_equalTo(self);
        }];
    }
    [self.textFieldArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:38 leadSpacing:10 tailSpacing:10];
    [self updateMovingTextFieldStatusWithTextField:self.textFieldArray.firstObject];
    @weakify(self)
    [self setTapActionWithBlock:^{
        NSLog(@"xxx");
        @strongify(self)
        [self setFirstResponser];
    }];
    self.userInteractionEnabled = YES;
}

- (void)setFirstResponser {
    
    [self updateMovingTextFieldStatusWithTextField:_textFieldArray[_currentIndex]];
//    [self.textFieldArray enumerateObjectsUsingBlock:^(UITextField* textField, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (!textField.text.isNotBlank) {
////            [textField becomeFirstResponder];
//            [self updateMovingTextFieldStatusWithTextField:textField];
//            *stop = YES;
//        }
//    }];
}

- (void)updateMovingTextFieldStatusWithTextField:(UITextField *)textField {
    self.movingTextField.text = @"";
    [self.movingTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(textField);
    }];
//    [self layoutIfNeeded];
}

#pragma mark getter

- (NSMutableArray *)textFieldArray {
    if (!_textFieldArray) {
        _textFieldArray = @[].mutableCopy;
    }
    return _textFieldArray;
}

#pragma mark textFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if (string.length == 0) {
//        //删除
//        NSInteger index = textField.tag-100;
//        if (index - 1 >= 0) {
//            UITextField *lastTextField = self.textFieldArray[index-1];
//            lastTextField.text = @"";
//            lastTextField.enabled = YES;
//            [lastTextField becomeFirstResponder];
//        }
//    }else
    if ([string stringByTrim].length == 0) {
        return NO;
    }else {
        return [Util isCorrectEngineNum:string];
    }
    return YES;
}

- (void)sos_textFieldDeleteBackward:(PinTextField *)textField {
//    NSInteger index = textField.tag-100;
    if (_currentIndex - 1 >= 0) {
        UITextField *lastTextField = self.textFieldArray[--_currentIndex];
        lastTextField.text = @"";
//        lastTextField.enabled = YES;
//        [lastTextField becomeFirstResponder];
        [self updateMovingTextFieldStatusWithTextField:lastTextField];
    }
}

/**
 *  值变化
 */
- (void)textFieldDidChange:(UITextField *)textField
{
//    NSLog(@"%@", textField.text);
//    NSInteger index = textField.tag-100;
    UITextField *currentTextField = self.textFieldArray[_currentIndex];
    currentTextField.text = textField.text;
    if (_currentIndex + 1 < self.textFieldArray.count) {
        UITextField *nextTextField = self.textFieldArray[++_currentIndex];
//        nextTextField.enabled = YES;
//        [nextTextField becomeFirstResponder];
//        nextTextField.text = self.movingTextField.text;
        [self updateMovingTextFieldStatusWithTextField:nextTextField];
    }else {
        //输入完成
        !self.didCompleteInputBlock?:self.didCompleteInputBlock([self pinCode]);
    }
//    textField.enabled = NO;
}

- (void)didMoveToWindow {
    //给你0.3s做动画
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.superview.height != 0) {
//            [self.textFieldArray.firstObject becomeFirstResponder];
            [self.movingTextField becomeFirstResponder];
        }
    });
    
}

- (NSString *)pinCode {
    NSMutableString *pin = [[NSMutableString alloc] init];
    [self.textFieldArray enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL * _Nonnull stop) {
        [pin appendString:textField.text];
    }];
    return pin.copy;
}


@end
