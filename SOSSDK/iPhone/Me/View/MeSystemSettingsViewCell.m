//
//  MeSystemSettingsViewCell.m
//  Onstar
//
//  Created by Apple on 16/7/11.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "MeSystemSettingsViewCell.h"

NSString * const MeSystemSettings_CellID = @"MeSystemSettings_CellID";

@interface MeSystemSettingsViewCell()
{
    UITapGestureRecognizer *tapGesture;
}
@property (weak, nonatomic) IBOutlet UISwitch *mySwitch;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrowImgV;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *noArrowDetailLabel;
@end

@implementation MeSystemSettingsViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _titleTextLabel.adjustsFontSizeToFitWidth = YES;
    _detailLabel.adjustsFontSizeToFitWidth = YES;
    _noArrowDetailLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)setCellData:(SystemSettingCellData *)cellData
{
    _cellData = cellData;
    _titleTextLabel.text = _cellData.titleText;
    _titleTextLabel.textColor = [UIColor colorWithHexString:@"151b32"];
    if (_cellData.cellStyle==CellStyleSwitch) {
        _mySwitch.hidden = NO;
        _rightArrowImgV.hidden = YES;
        _detailLabel.hidden = YES;
        _noArrowDetailLabel.hidden = YES;
    }
    else if (_cellData.cellStyle==CellStyleSwitchWithSubText)
    {
        _mySwitch.hidden = NO;
        _titleTextLabel.hidden = NO;
        _detailLabel.hidden = NO;
        _detailLabel.text = _cellData.subtitleText;
        _noArrowDetailLabel.hidden = YES;
        _rightArrowImgV.hidden = YES;
        [self removeAllAutoLayout];

    }
    else if (_cellData.cellStyle==CellStyleLabel)
    {
        _mySwitch.hidden = YES;
        _rightArrowImgV.hidden = YES;
        _detailLabel.hidden = YES;
        _noArrowDetailLabel.hidden = NO;
        _noArrowDetailLabel.text = _cellData.subtitleText;
    }
    else if (_cellData.cellStyle==CellStyleNone)
    {
        _mySwitch.hidden = YES;
        _rightArrowImgV.hidden = YES;
        _detailLabel.hidden = YES;
        _noArrowDetailLabel.hidden = YES;
    }
    else
    {
        _mySwitch.hidden = YES;
        _rightArrowImgV.hidden = NO;
        _detailLabel.hidden = NO;
        _noArrowDetailLabel.hidden = YES;
        _detailLabel.text = _cellData.subtitleText;
    }
    [self buildCell];
}
- (void)removeAllAutoLayout{
    [self.contentView removeConstraints:self.contentView.constraints];
    [self.titleTextLabel removeConstraints:self.titleTextLabel.constraints];
    [self.detailTextLabel removeConstraints:self.detailTextLabel.constraints];
    [self.rightArrowImgV removeConstraints:self.rightArrowImgV.constraints];
    [self.mySwitch removeConstraints:self.mySwitch.constraints];
    [self.noArrowDetailLabel removeConstraints:self.noArrowDetailLabel.constraints];
    [self removeConstraints:self.constraints];
    
}

- (void)buildCell{
    switch (_cellData.cellStyle) {
        case CellStyleSwitch:
        {
            if (tapGesture) [self removeGestureRecognizer:tapGesture];
            dispatch_async(dispatch_get_main_queue(), ^{
                _mySwitch.on = _cellData.switchStyleStatus;
            });
            [_mySwitch removeTarget:nil action:nil forControlEvents:UIControlEventValueChanged];
            [_mySwitch addTarget:_cellData.cellTarget action:_cellData.cellSelector forControlEvents:UIControlEventValueChanged];
            break;
        }
        case CellStyleSwitchWithSubText:
        {
            [_titleTextLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(16.0f);
                make.top.mas_equalTo(16.0f);
                //            make.right.mas_equalTo(_mySwitch.left).mas_offset(20.0f);
            }];
            [_detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(16.0f);
                make.top.mas_equalTo(40);
                make.width.mas_equalTo(201);
                //            make.width.mas_equalTo(100.0f);
            }];
            

        }
             break;
           
        case CellStyleDisclosureIndicator:
        {
            if (tapGesture) [self removeGestureRecognizer:tapGesture];
            tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTap)];
            [self addGestureRecognizer:tapGesture];
            break;
        }
        case CellStyleLabel:
        {
            if (tapGesture) [self removeGestureRecognizer:tapGesture];
            break;
        }
        case CellStyleNone:
        {
            if (tapGesture) [self removeGestureRecognizer:tapGesture];
            tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTap)];
            [self addGestureRecognizer:tapGesture];
            break;
        }
        default:
            break;
    }
}

- (void)doTap {

    if ([_cellData.cellTarget respondsToSelector:_cellData.cellSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_cellData.cellTarget performSelector:_cellData.cellSelector];
#pragma clang diagnostic pop
    }
}

@end
