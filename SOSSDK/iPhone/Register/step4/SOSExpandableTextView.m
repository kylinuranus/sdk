//
//  SOSExpandableTextView.m
//  SelwynFormDemo
//
//  Created by BSW on 2017/6/24.
//  Copyright © 2017年 selwyn. All rights reserved.
//

#import "SOSExpandableTextView.h"
#import "SWFormCompat.h"
#import "NSString+JWT.h"
#define HAS_TEXT_CONTAINER [self respondsToSelector:@selector(textContainer)]
#define HAS_TEXT_CONTAINER_INSETS(x) [(x) respondsToSelector:@selector(textContainerInset)]

@interface SOSExpandableTextView()
@property (strong, nonatomic) UITextView *_placeholderTextView;
@end

static NSString * const kAttributedPlaceholderKey = @"attributedPlaceholder";
static NSString * const kPlaceholderKey = @"placeholder";
static NSString * const kFontKey = @"font";
static NSString * const kAttributedTextKey = @"attributedText";
static NSString * const kTextKey = @"text";
static NSString * const kExclusionPathsKey = @"exclusionPaths";
static NSString * const kLineFragmentPaddingKey = @"lineFragmentPadding";
static NSString * const kTextContainerInsetKey = @"textContainerInset";
static NSString * const kTextAlignmentKey = @"textAlignment";

@implementation SOSExpandableTextView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self preparePlaceholder];
    }
    return self;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self preparePlaceholder];
    }
    return self;
}
#else
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self preparePlaceholder];
    }
    return self;
}
#endif

- (void)preparePlaceholder
{
    NSAssert(!self._placeholderTextView, @"placeholder has been prepared already: %@", self._placeholderTextView);
    // the label which displays the placeholder
    // needs to inherit some properties from its parent text view
//    self.delegate = self;
    // account for standard UITextViewPadding
    
    CGRect frame = self.bounds;
    self._placeholderTextView = [[UITextView alloc] initWithFrame:frame];
    self._placeholderTextView.opaque = NO;
    self._placeholderTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self._placeholderTextView.backgroundColor = [UIColor clearColor];
    self._placeholderTextView.textColor = [UIColor colorWithWhite:0.7f alpha:0.7f];
    self._placeholderTextView.editable = NO;
    self._placeholderTextView.scrollEnabled = YES;
    self._placeholderTextView.userInteractionEnabled = NO;
    self._placeholderTextView.font = self.font;
    self._placeholderTextView.isAccessibilityElement = NO;
    self._placeholderTextView.contentOffset = self.contentOffset;
    self._placeholderTextView.contentInset = self.contentInset;
    
    if ([self._placeholderTextView respondsToSelector:@selector(setSelectable:)]) {
        self._placeholderTextView.selectable = NO;
    }
    
    if (HAS_TEXT_CONTAINER) {
        self._placeholderTextView.textContainer.exclusionPaths = self.textContainer.exclusionPaths;
        self._placeholderTextView.textContainer.lineFragmentPadding = self.textContainer.lineFragmentPadding;
    }
    
    if (HAS_TEXT_CONTAINER_INSETS(self)) {
        self._placeholderTextView.textContainerInset = self.textContainerInset;
    }
    
    if (_attributedPlaceholder) {
        self._placeholderTextView.attributedText = _attributedPlaceholder;
    } else if (_placeholder) {
        self._placeholderTextView.text = _placeholder;
    }
    
    [self setPlaceholderVisibleForText:self.text];
    
    self.clipsToBounds = YES;
    
    // some observations
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(textDidChange:)
                          name:UITextViewTextDidChangeNotification object:self];
    
    [self addObserver:self forKeyPath:kAttributedPlaceholderKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kPlaceholderKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kFontKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kAttributedTextKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kTextKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kTextAlignmentKey
              options:NSKeyValueObservingOptionNew context:nil];
    
    if (HAS_TEXT_CONTAINER) {
        [self.textContainer addObserver:self forKeyPath:kExclusionPathsKey
                                options:NSKeyValueObservingOptionNew context:nil];
        [self.textContainer addObserver:self forKeyPath:kLineFragmentPaddingKey
                                options:NSKeyValueObservingOptionNew context:nil];
    }
    
    if (HAS_TEXT_CONTAINER_INSETS(self)) {
        [self addObserver:self forKeyPath:kTextContainerInsetKey
                  options:NSKeyValueObservingOptionNew context:nil];
    }
    
    [self addAddressTextInputPredicate];

}

- (void)setPlaceholder:(NSString *)placeholderText
{
    _placeholder = [placeholderText copy];
    _attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderText];
    
    [self resizePlaceholderFrame];
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholderText
{
    _placeholder = attributedPlaceholderText.string;
    _attributedPlaceholder = [attributedPlaceholderText copy];
    
    [self resizePlaceholderFrame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self._placeholderTextView.textAlignment = self.textAlignment;
    [self resizePlaceholderFrame];
}

- (void)resizePlaceholderFrame
{
    CGRect frame = self._placeholderTextView.frame;
    frame.size = self.bounds.size;
    self._placeholderTextView.frame = frame;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kAttributedPlaceholderKey]) {
        self._placeholderTextView.attributedText = [change valueForKey:NSKeyValueChangeNewKey];
    }
    else if ([keyPath isEqualToString:kPlaceholderKey]) {
        self._placeholderTextView.text = [change valueForKey:NSKeyValueChangeNewKey];
    }
    else if ([keyPath isEqualToString:kFontKey]) {
        self._placeholderTextView.font = [change valueForKey:NSKeyValueChangeNewKey];
    }
    else if ([keyPath isEqualToString:kAttributedTextKey]) {
        NSAttributedString *newAttributedText = [change valueForKey:NSKeyValueChangeNewKey];
        [self setPlaceholderVisibleForText:newAttributedText.string];
    }
    else if ([keyPath isEqualToString:kTextKey]) {
        NSString *newText = [change valueForKey:NSKeyValueChangeNewKey];
        [self setPlaceholderVisibleForText:newText];
    }
    else if ([keyPath isEqualToString:kExclusionPathsKey]) {
        self._placeholderTextView.textContainer.exclusionPaths = [change objectForKey:NSKeyValueChangeNewKey];
        [self resizePlaceholderFrame];
    }
    else if ([keyPath isEqualToString:kLineFragmentPaddingKey]) {
        self._placeholderTextView.textContainer.lineFragmentPadding = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        [self resizePlaceholderFrame];
    }
    else if ([keyPath isEqualToString:kTextContainerInsetKey]) {
        NSValue *value = [change objectForKey:NSKeyValueChangeNewKey];
        self._placeholderTextView.textContainerInset = value.UIEdgeInsetsValue;
    }
    else if ([keyPath isEqualToString:kTextAlignmentKey]) {
        NSNumber *alignment = [change objectForKey:NSKeyValueChangeNewKey];
        self._placeholderTextView.textAlignment = alignment.intValue;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor
{
    self._placeholderTextView.textColor = placeholderTextColor;
}

- (UIColor *)placeholderTextColor
{
    return self._placeholderTextView.textColor;
}

- (void)textDidChange:(NSNotification *)aNotification
{
    
    [self setPlaceholderVisibleForText:self.text];
}

- (BOOL)becomeFirstResponder
{
    if (!self.isFirstResponder) {
        [self setPlaceholderVisibleForText:self.text];
        if ([self respondsToSelector:@selector(realText)]) {
            self.text = [self performSelector:@selector(realText)];
        }
    }
   
    return [super becomeFirstResponder];
}
- (BOOL)resignFirstResponder;
{
    if ([self respondsToSelector:@selector(realText)]) {
        [self performSelector:@selector(setRealText:) withObject:self.text] ;
        self.text = [self.text addressStringInterceptionHide];
    }
    return [super resignFirstResponder];
}
- (void)setPlaceholderVisibleForText:(NSString *)text
{
    if (text.length < 1) {
        if (self.fadeTime > 0.0) {
            if (![self._placeholderTextView isDescendantOfView:self]) {
                self._placeholderTextView.alpha = 0;
                [self addSubview:self._placeholderTextView];
                [self sendSubviewToBack:self._placeholderTextView];
            }
            [UIView animateWithDuration:_fadeTime animations:^{
                self._placeholderTextView.alpha = 1;
            }];
        }
        else {
            [self addSubview:self._placeholderTextView];
            [self sendSubviewToBack:self._placeholderTextView];
            self._placeholderTextView.alpha = 1;
        }
    }
    else {
        if (self.fadeTime > 0.0) {
            [UIView animateWithDuration:_fadeTime animations:^{
                self._placeholderTextView.alpha = 0;
            }];
        }
        else {
            [self._placeholderTextView removeFromSuperview];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:kAttributedPlaceholderKey];
    [self removeObserver:self forKeyPath:kPlaceholderKey];
    [self removeObserver:self forKeyPath:kFontKey];
    [self removeObserver:self forKeyPath:kAttributedTextKey];
    [self removeObserver:self forKeyPath:kTextKey];
    [self removeObserver:self forKeyPath:kTextAlignmentKey];
    
    if (HAS_TEXT_CONTAINER) {
        [self.textContainer removeObserver:self forKeyPath:kExclusionPathsKey];
        [self.textContainer removeObserver:self forKeyPath:kLineFragmentPaddingKey];
    }
    
    if (HAS_TEXT_CONTAINER_INSETS(self)) {
        [self removeObserver:self forKeyPath:kTextContainerInsetKey];
    }
}
/// 最大输入长度,(汉字 * 1, 数字/字母 * 1), 若输入超出,截取到最大输入长度
- (void)setMaxInputLength:(int)maxInputLength   {
    objc_setAssociatedObject(self, @selector(maxInputLength), @(maxInputLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.rac_textSignal subscribeNext:^(NSString *x) {
        if (x.length > maxInputLength && maxInputLength > 0) {
            self.text = [x substringToIndex:maxInputLength];
        }
    }];
}
- (void)addAddressTextInputPredicate   {
    [self.rac_textSignal  subscribeNext:^(NSString *x) {

        for (int i = 0; i < x.length; i++) {
            NSRange range = NSMakeRange( i, 1);
            NSString *subStr  = [x substringWithRange:range];
            NSLog(@"------%@",subStr);
            if ([subStr isNotBlank]) {
                NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d\\s*]*$";
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
                BOOL isMatch = [pred evaluateWithObject:subStr];
                if (!isMatch) {
                    NSLog(@"----!isMatch");
                    self.text = [self.text stringByReplacingOccurrencesOfString:subStr withString:@""];
                }
            }

        }
//        self.text = [self.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
