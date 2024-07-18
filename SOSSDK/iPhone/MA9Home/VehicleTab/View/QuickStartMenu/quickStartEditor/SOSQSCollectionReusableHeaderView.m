//
//  SOSQSCollectionReusableHeaderView.m
//  Onstar
//
//  Created by Onstar on 2019/1/11.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSQSCollectionReusableHeaderView.h"

@implementation SOSQSCollectionReusableHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor whiteColor];
    UIView *bottomLine = [UIView new];
    bottomLine.backgroundColor = [UIColor colorWithHexString:@"#F3F3F4"];
    [self addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@1);
    }];

}

@end
