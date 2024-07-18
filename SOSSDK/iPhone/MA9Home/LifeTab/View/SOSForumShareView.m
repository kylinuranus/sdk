//
//  SOSForumShareView.m
//  Onstar
//
//  Created by TaoLiang on 2019/2/15.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSForumShareView.h"
#import "SOSMusicCenterButton.h"

#define V_MARGIN 20
#define H_MARGIN 15
#define V_PADDING 10
#define H_PADDING 10
#define COLUMNS 4
#define BUTTON_HEIGHT 76
#define BUTTON_WIDTH 40

@implementation SOSForumShareView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setButtons:(NSArray<NSDictionary *> *)buttons {
    _buttons = buttons;
    [self layoutButtons];
}

- (void)buttonClicked:(UIButton *)btn {
    _btnClicked ? _btnClicked(btn.tag, _buttons[btn.tag]) : nil;
}

- (void)layoutButtons {
    [self removeAllSubviews];
    NSMutableArray<__kindof UIButton *> *btns = @[].mutableCopy;
    [_buttons enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SOSMusicCenterButton *btn = [SOSMusicCenterButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:obj[@"title"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [btn setTitleColor:[UIColor colorWithHexString:@"#4E5059"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:obj[@"image"]] forState:UIControlStateNormal];
        [btns addObject:btn];
        btn.tag = idx;
        [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }];
    
    __block __kindof UIButton *lastBtn = nil;
    __block __kindof UIButton *lastRowBtn = nil;
    __block NSUInteger lastRow = 0;
    __block NSUInteger currentRow = 0;
    [btns enumerateObjectsUsingBlock:^(__kindof UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        currentRow = idx / COLUMNS;
        if (currentRow != lastRow) {
            lastRow = currentRow;
            lastRowBtn = lastBtn;
        }
        
        BOOL isFirstRow = [self isFirstRowWithIndex:idx];
        BOOL isFirtColumn = [self isFirstColumnWithIndex:idx];
        BOOL isLastRow = [self isLastRowWithIndex:idx];
        BOOL isLastColumn = [self isLastColumnWithIndex:idx];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make){
//            make.size.mas_equalTo(CGSizeMake(BUTTON_WIDTH, BUTTON_HEIGHT));
            make.height.equalTo(@(BUTTON_HEIGHT));
            if (lastBtn) {
                make.width.equalTo(lastBtn);
            }
            
            if (isFirstRow) {
                make.top.equalTo(self).offset(V_MARGIN);
            }else {
                make.top.equalTo(lastRowBtn.mas_bottom).with.offset(V_PADDING);
            }
            
            if (isFirtColumn) {
                make.left.equalTo(self).offset(H_MARGIN);
            }else {
                make.left.equalTo(lastBtn.mas_right).offset(H_PADDING);
            }
            
            if (isFirstRow && isLastColumn) {
                make.right.equalTo(self).offset(-H_MARGIN);
            }
            
            if (isLastRow && isFirtColumn) {
                make.bottom.equalTo(self).offset(-V_MARGIN);
            }
            
        }];

        lastBtn = button;
    }];
}

- (BOOL)isFirstRowWithIndex:(NSInteger)index {
    return index / COLUMNS == 0;
}

- (BOOL)isFirstColumnWithIndex:(NSInteger)index {
    return index % COLUMNS == 0;
}

- (BOOL)isLastRowWithIndex:(NSInteger)index {
    NSInteger totalRow = ceil(_buttons.count / ((CGFloat)COLUMNS));//总行数
    return index / COLUMNS == totalRow - 1;
}

- (BOOL)isLastColumnWithIndex:(NSInteger)index {
    if (_buttons.count < COLUMNS) {
        //总数小于每行最大个数时，如果index是最后一个，那么也是最后一列
        return index == _buttons.count - 1;
    }
    return index % COLUMNS == COLUMNS - 1;
    
}
@end
