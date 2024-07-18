//
//  TPKeyboardAvoidingScrollView.h
//
//  Created by Michael Tyson on 11/04/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

typedef enum {
	TPKeyboardAvoidingScrollViewTypeAdjust = 0,
    TPKeyboardAvoidingScrollViewManual
} TPKeyboardAvoidingScrollViewType;

@interface TPKeyboardAvoidingScrollView : UIScrollView {
    UIEdgeInsets    _priorInset;
    BOOL            _priorInsetSaved;
    BOOL            _keyboardVisible;
    CGRect          _keyboardRect;
    CGSize          _originalContentSize;
    CGFloat         offset;
}

@property (assign, nonatomic) TPKeyboardAvoidingScrollViewType type;
@property (assign, nonatomic) CGFloat offset;

- (void)adjustOffsetToIdealIfNeeded;

@end
