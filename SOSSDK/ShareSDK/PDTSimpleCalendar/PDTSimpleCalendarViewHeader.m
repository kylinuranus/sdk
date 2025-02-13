//
//  PDTSimpleCalendarViewHeader.m
//  PDTSimpleCalendar
//
//  Created by Jerome Miglino on 10/8/13.
//  Copyright (c) 2013 Producteev. All rights reserved.
//

#import "PDTSimpleCalendarViewHeader.h"

const CGFloat PDTSimpleCalendarHeaderTextSize = 12.0f;

@implementation PDTSimpleCalendarViewHeader

- (id)initWithFrame:(CGRect)frame    {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:self.textFont];
        [_titleLabel setTextColor:self.textColor];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];

        [self addSubview:_titleLabel];
        [_titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

        UIView *separatorView = [[UIView alloc] init];
        [separatorView setBackgroundColor:self.separatorColor];
        [self addSubview:separatorView];
        [separatorView setTranslatesAutoresizingMaskIntoConstraints:NO];

        __weak __typeof(self) weakSelf = self;
        [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(weakSelf);
            make.height.equalTo(@1);
        }];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@20);
            make.top.equalTo(@28);
        }];
    }

    return self;
}


#pragma mark - Colors

- (UIColor *)textColor    {
    if(_textColor == nil) {
        _textColor = [[[self class] appearance] textColor];
    }

    if(_textColor != nil) {
        return _textColor;
    }

    return [UIColor colorWithHexString:@"9EB0E3"];
}

- (UIFont *)textFont    {
    if(_textFont == nil) {
        _textFont = [[[self class] appearance] textFont];
    }

    if(_textFont != nil) {
        return _textFont;
    }

    return [UIFont fontWithName:@"DINNextLTPro-BoldCondensed" size:40];
}

- (UIColor *)separatorColor    {
    if(_separatorColor == nil) {
        _separatorColor = [[[self class] appearance] separatorColor];
    }

    if(_separatorColor != nil) {
        return _separatorColor;
    }

    return [UIColor colorWithHexString:@"F3F3F4"];
}


@end
