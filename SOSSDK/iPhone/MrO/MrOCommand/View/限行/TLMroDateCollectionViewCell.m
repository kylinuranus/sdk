//
//  TLMroDateCollectionViewCell.m
//  Onstar
//
//  Created by TaoLiang on 2017/11/22.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "TLMroDateCollectionViewCell.h"

@interface TLMroDateCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *dateBtn;

@end

@implementation TLMroDateCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.contentView.backgroundColor = [UIColor whiteColor];
    _dateBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _dateBtn.userInteractionEnabled = NO;
    _dateBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_dateBtn setBackgroundColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_dateBtn setBackgroundColor:[UIColor colorWithHexString:@"2C3963"] forState:UIControlStateSelected];
   
    _dateBtn.layer.cornerRadius = 20;
    _dateBtn.layer.masksToBounds = YES;
    
}

- (void)setDateString:(NSString *)dateString {
    _dateString = dateString;
    NSString *cookedDateString = [dateString stringByReplacingOccurrencesOfString:@"月" withString:@"月\n"];
    NSArray *array = [cookedDateString componentsSeparatedByString:@"\n"];
    NSString *month = array[0];
    NSString *day = array[1];
    NSAttributedString *attrMonth = [[NSAttributedString alloc] initWithString:month attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:9]}];
    NSAttributedString *attrDay = [[NSAttributedString alloc] initWithString:day attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:attrMonth];
    [attrString appendString:@"\n"];
    [attrString appendAttributedString:attrDay];
    [_dateBtn setAttributedTitle:attrString forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    _dateBtn.selected = selected;
}

@end

