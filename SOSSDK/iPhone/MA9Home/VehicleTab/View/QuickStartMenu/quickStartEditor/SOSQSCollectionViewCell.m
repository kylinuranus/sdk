//
//  SOSQSCollectionViewCell.m
//  Onstar
//
//  Created by Onstar on 2019/1/11.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSQSCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@interface SOSQSCollectionViewCell ()
@property (nonatomic,strong) UIImageView *highlightIcon;
@end

@implementation SOSQSCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    self.backgroundColor = [UIColor redColor];
}

- (IBAction)deleteAppWithSender:(id)sender forEvent:(UIEvent *)event {
    if ([_delegate respondsToSelector:@selector(deleteFromSelectQSWithCell:event:)]) {
        [_delegate deleteFromSelectQSWithCell:self event:event];
    }
    if (!self.canDelete) {
        if ([_delegate respondsToSelector:@selector(addFromAllQSWithCell:event:)]) {
            [_delegate addFromAllQSWithCell:self event:event];
        } 
    }else{
        if ([_delegate respondsToSelector:@selector(deleteFromAllQSWithCell:event:)]) {
            [_delegate deleteFromAllQSWithCell:self event:event];
        }
    }
   
}

- (UIImageView *)highlightIcon {
    if (!_highlightIcon) {
        _highlightIcon = [UIImageView new];
        //        self.highlightIcon.hidden = YES;
        _highlightIcon.layer.cornerRadius = 30;
        _highlightIcon.clipsToBounds = YES;
        [self.contentView addSubview:_highlightIcon];
        [_highlightIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.appIcon);
        }];
        [self.contentView sendSubviewToBack:_highlightIcon];
    }
    return _highlightIcon;
}

- (UIImageView *)loadingIcon {
    if (!_loadingIcon) {
        _loadingIcon = UIImageView.new;
        _loadingIcon.hidden = YES;
        _loadingIcon.image = [UIImage imageNamed:@"icon_loading_60x60"];
        [self.contentView addSubview:_loadingIcon];
        [_loadingIcon mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.mas_equalTo(self.appIcon);
        }];

        [self.contentView sendSubviewToBack:_loadingIcon];
    }
    return _loadingIcon;
}

- (void)setHighlighted:(BOOL)highlighted {
    self.highlightIcon.image = highlighted ? [UIImage imageWithColor:UIColorHex(#DDE8FF)] : nil;
}

- (void)shouldLoading:(BOOL)shouldLoading {
    if (shouldLoading) {
        [SOSUtilConfig rotateView:self.loadingIcon];
    }else {
        [SOSUtilConfig stopRotateAndHideView:_loadingIcon];
    }
}

- (void)setSelectqsArray:(NSMutableArray *)selectArray allqsArray:(NSMutableArray *)allArray indexPath:(NSIndexPath *)indexPath{
    id<SOSQSModelProtol> model = [allArray[indexPath.section] objectAtIndex:indexPath.row];
    self.appTitle.text = [model modelTitle];
    NSString *imageName = model.modelImage;
    if ([imageName hasPrefix:@"http"]) {
        [_appIcon sd_setImageWithURL:imageName.mj_url placeholderImage:[UIImage imageNamed:@"icon_警示类别"]];
    }else {
        _appIcon.image = [UIImage imageNamed:[model modelImage]];
    }
    if ([selectArray  containsObject:model]) {// 是否存在首选数组中
//        NSLog(@"已存在地址是=====%p", &model);
        [self.delegateApp setBackgroundImage:[UIImage imageNamed:@"vehicle_qs_delete"] forState:UIControlStateNormal];
        self.canDelete = YES;
    } else {
//        NSLog(@"比死啊吧=====%d", self.delegateApp.hidden);
        [self.delegateApp setBackgroundImage:[UIImage imageNamed:@"vehicle_qs_add"] forState:UIControlStateNormal];
        self.canDelete = NO;
    }
}

#pragma mark - 是否处于编辑状态
- (void)setInEditState:(BOOL)inEditState{
    if (inEditState) {
        self.delegateApp.hidden = NO;
    } else {
        self.delegateApp.hidden = YES;
    }
}

@end
