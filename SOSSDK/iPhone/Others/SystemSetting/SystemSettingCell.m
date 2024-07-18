//
//  CustomTableViewCell.m
//  Onstar
//
//  Created by Onstar on 4/10/13.
//
//

#import "SystemSettingCell.h"
#import "Util.h"
#import "AppPreferences.h"

@interface SystemSettingCell () {
    UITapGestureRecognizer *tapGesture;
    UISwitch *switchCell1;
}

@end

@implementation SystemSettingCell
//@synthesize iconImageView, subLable;
//@synthesize cellTarget, cellSelector, cellStyle;
//@synthesize switchStyleStatus;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier Style:(CellStyle) cellStyle     {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.cellStyle = cellStyle;
        [self buildCell];
    }
    return self;
}
- (void)layoutSubviews     {
    [super layoutSubviews];
    // cell.textLabel
    CGFloat textEndX = 0;
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
//            CGSize textSize = [[(UILabel *)subView text] sizeWithFont:[(UILabel *)subView font]];
            CGSize textSize = [[(UILabel *)subView text] sizeWithAttributes:@{NSFontAttributeName:[(UILabel *)subView font]}];
            textEndX = textSize.width + subView.frame.origin.x;
        }
    }
    
    
    // cell.detailTextLabel
    for (UIView *subView in self.contentView.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            CGRect dframe = subView.frame;
            CGRect adjustFrame = dframe;
            if (dframe.origin.x < textEndX) {
                CGFloat detailTextwidth = dframe.size.width - (textEndX - dframe.origin.x);
                adjustFrame = CGRectMake(textEndX,
                                         dframe.origin.y,
                                         detailTextwidth,
                                         dframe.size.height);
            }
            subView.frame = adjustFrame;
        }
    }
    if (ISIPAD) {
        self.detailTextLabel.frame = CGRectMake(540, self.frame.size.height/2 - 30, 120, 60);
        self.detailTextLabel.font = [UIFont systemFontOfSize:20.0f];
    }
    
    UIView *lineView = [[UIView alloc] init];
    lineView.frame = CGRectMake(15.0f, self.frame.size.height - 1.0f, self.frame.size.width - 30, 1.0f);
    [self.contentView addSubview:lineView];
    lineView.backgroundColor = [UIColor lightGrayColor];
    lineView.alpha = 0.5f;
    
    switchCell1.frame = ISIPAD?CGRectMake(580, 12, 127, 73): CGRectMake(self.frame.size.width - 65, 10, 62, 35);
    
    _subLable.frame = ISIPAD?CGRectMake(25, 25, 400, 60):CGRectMake(15, 0, self.frame.size.width*0.5, self.frame.size.height);

}

- (void)setCellStyle:(CellStyle)cellStyle     {
    if (_cellStyle == cellStyle) {
        return;
    }
    _cellStyle = cellStyle;
    [self buildCell];
}

- (void)setTitleIcon:(UIImage *)_titleIcon AndTitleText:(NSString *)_titleText     {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithImage:_titleIcon];
        [_iconImageView setContentMode:UIViewContentModeScaleAspectFit];
        _iconImageView.frame = CGRectMake(15, 6, 30, 30);
        [self addSubview:_iconImageView];
    } else {
        [_iconImageView setImage:_titleIcon];
    }
    
    if (!_subLable) {
        CGRect subLableFrame = ISIPAD?CGRectMake(25, 25, 400, 60):CGRectMake(15, 0, self.frame.size.width*0.5, self.frame.size.height);
        _subLable = [[UILabel alloc] initWithFrame:subLableFrame];
        _subLable.backgroundColor = [UIColor clearColor];
        if (_titleText == nil || _titleText.length == 0) {
            _subLable.text = self.textLabel.text;
        } else {
            _subLable.text = _titleText;
        }
        _subLable.textColor = [UIColor colorWithHexString:@"0e1c2c"];
        _subLable.font = [UIFont systemFontOfSize:ISIPAD?30: 15];
        _subLable.adjustsFontSizeToFitWidth =YES;
        [self addSubview:_subLable];
    } else {
        if (_titleText == nil || _titleText.length == 0) {
            _subLable.text = self.textLabel.text;
        } else {
            _subLable.text = _titleText;
        }
    }
    
}

/**
	Build cell with custom style
 */
- (void)buildCell     {
   switch (self.cellStyle) {
        case CellStyleSwitch:
        {
//            [self checkMroCellStatus];
            self.accessoryView = nil;
            if (tapGesture) [self removeGestureRecognizer:tapGesture];
            switchCell1 = [[UISwitch alloc] init];
            dispatch_async(dispatch_get_main_queue(), ^{
                switchCell1.on = _switchStyleStatus;
            });
            [switchCell1 setOnTintColor:[UIColor colorWithHexString:@"1762cb"]];
            [switchCell1 addTarget:self.cellTarget action:self.cellSelector forControlEvents:UIControlEventValueChanged];
            [self.contentView addSubview:switchCell1];
            break;
        }
        case CellStyleDisclosureIndicator:
        {
            if (switchCell1)    [switchCell1 removeFromSuperview];
            tapGesture = [[UITapGestureRecognizer alloc]
                                                  initWithTarget:self action:@selector(doTap)];
            [self addGestureRecognizer:tapGesture];
            UIImageView *arrowImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cell_arrow"]];
            arrowImage.frame = ISIPAD?CGRectMake(550, 12, 23, 40): CGRectMake(289, 18, 10, 15);

            self.accessoryView = arrowImage;
            break;
        }
        default:
            break;
    }
}

//- (void)checkMroCellStatus  {
//    return;
//    //小O语音助手红点
////    if ([_subLable.text isEqualToString:NSLocalizedString(@"SettingVC_MrOName", nil)]) {
////        BOOL needNotNoticeMrOInSetting = [[NSUserDefaults standardUserDefaults] boolForKey:@"NEED_NOT_NOTICE_MRO_IN_SETTING"];
////        if (!needNotNoticeMrOInSetting) {
////            UIImageView *shouldNoticeImage = [[UIImageView alloc] initWithFrame:CGRectMake(110, 5, 7, 7)];
////            shouldNoticeImage.tag = 98765;
////            shouldNoticeImage.image = [UIImage imageNamed:@"icon_nor"];
////            shouldNoticeImage.hidden = NO;
////            if (![self.contentView viewWithTag:98765]) {
////                [self.contentView addSubview:shouldNoticeImage];
////            }
////        }   else    {
////            [self.contentView viewWithTag:98765].hidden = YES;
////        }
////    }
//}

// animate between regular and selected state
- (void)setSelected:(BOOL)selected animated:(BOOL)animated     {
    [super setSelected:selected animated:animated];
}

/**
	tap cell event
 */
- (void)doTap     {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.cellTarget performSelector:self.cellSelector];
#pragma clang diagnostic pop

}

- (void)addTarget:(id)target Selector:(SEL)selector     {
    self.cellTarget = target;
    self.cellSelector = selector;
}
 

- (void)dealloc     {
    self.cellSelector = nil;
}
@end
