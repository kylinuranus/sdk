//
//  LoggerTableViewCell.m
//  HDWindowLogger
//
//  Created by Damon on 2019/5/28.
//  Copyright © 2019 Damon. All rights reserved.
//

#import "HDLoggerTableViewCell.h"
#import "HDWindowLogger.h"

@interface HDLoggerTableViewCell ()
@property (strong, nonatomic) UILabel *mContentLabel;
@end

@implementation HDLoggerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self p_createUI];
    }
    return self;
}

- (void)p_createUI {
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.mContentLabel];
    [self.mContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           make.edges.mas_equalTo(self.contentView);
       }];
}

- (void)updateWithLoggerItem:(HDWindowLoggerItem *)item {
    [self.mContentLabel setText:[item getFullContentString]];
    switch (item.mLogItemType) {
        case kHDLogTypeNormal: {
            [self.mContentLabel setTextColor:[UIColor whiteColor]];
        }
            break;
        case kHDLogTypeWarn: {
            [self.mContentLabel setTextColor:[UIColor yellowColor]];
        }
            break;
        case kHDLogTypeError: {
            [self.mContentLabel setTextColor:[UIColor redColor]];
        }
            break;
        case kHDLogTypeSuccess: {
            [self.mContentLabel setTextColor:[UIColor greenColor]];
        }
            break;
        default:
            break;
    }
    
    
    CGSize size = [self.mContentLabel sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width, MAXFLOAT)];
    [self.mContentLabel setFrame:CGRectMake(0, 0, size.width, ceil(size.height) + 1)];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -
#pragma mark - LazyLoad
- (UILabel *)mContentLabel {
    if (!_mContentLabel) {
        _mContentLabel = [[UILabel alloc] init];
        _mContentLabel.numberOfLines = 0;
        _mContentLabel.font = [UIFont systemFontOfSize:13];
    }
    return _mContentLabel;
}
@end
