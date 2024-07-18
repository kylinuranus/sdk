//
//  SOSPersonalInformationTableViewCell.m
//  Onstar
//
//  Created by lizhipan on 2017/8/3.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSPersonalInformationTableViewCell.h"
#import "SOSPersonalInfomationViewController.h"
#import "UITextField+Keyboard.h"
#import "Masonry.h"

@implementation SOSPersonalInformationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.separatorInset = UIEdgeInsetsZero;
}
- (void)configCellData:(SOSPersonInfoItem *)item
{
    _itemDesc.text = item.itemDescription;
    //    if (self.currentRightView) {
    //        [self.currentRightView removeFromSuperview];
    //    }
    
    UIView *v = [self.contentView viewWithTag:111];
    if (v) {
        [v removeFromSuperview];
    }
    if (item.rightFieldView) {
        _itemValue.hidden = YES;
        _necessaryFlag.hidden = !item.isNecessities;
        //        self.currentRightView = item.rightFieldView;
        self.accessoryType = UITableViewCellAccessoryNone;
        [self.contentView addSubview:item.rightFieldView];
        [item.rightFieldView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).with.offset(100);
            make.top.equalTo(self.contentView).with.offset(0);
            make.right.equalTo(self.contentView).with.offset(10);
            make.bottom.equalTo(self.contentView).with.offset(0);
        }];
        //还原 rightFieldView 为 UITextField 时的 maxInputLength & keyboardType
        if ([item.rightFieldView isKindOfClass:[UITextField class]]) {
            ((UITextField *)item.rightFieldView).maxInputLength = item.maxInputLength;
            ((UITextField *)item.rightFieldView).keyboardType = item.keyBoardType;
            
            //text改变
            [((UITextField *)item.rightFieldView).rac_textSignal subscribeNext:^(NSString *x) {
                //邮编只能输入数字
                if (item.itemIndex == 9) {
                    NSString *tempText = [x copy];
                    for (int i = 0; i < x.length; i++) {
                        NSRange range = NSMakeRange(i, 1);
                        NSString *subString = [x substringWithRange:range];
                        if (![Util isNumeber:subString]) {
                            tempText = [tempText stringByReplacingCharactersInRange:range withString:@" "];
                        }
                    }
                    ((UITextField *)item.rightFieldView).text = [tempText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                }
            }];
            //结束输入
            [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UITextFieldTextDidEndEditingNotification object:((UITextField *)item.rightFieldView)] subscribeNext:^(id x) {
                //邮编长度只能为6位
                if (item.itemIndex == 9) {
                    NSString * text = ((UITextField *)item.rightFieldView).text;
                    if (text.isNotBlank) {
                        if (text.length<6) {
                           [Util toastWithMessage:@"邮编格式错误"];
                        }
                    }
                }
            }];
        }
    }   else    {
        _itemValue.hidden = NO;
        _itemValue.text = item.itemPlaceholder;
        _necessaryFlag.hidden = !item.isNecessities;
        self.accessoryType = item.accessoryVisiable ?UITableViewCellAccessoryDisclosureIndicator: UITableViewCellAccessoryNone;
    }
    
    /** 安全问题 */
    if (item.itemIndex == 16) {
//        if ([CustomerInfo sharedInstance].bbwcDone) {
//            item.rightFieldView.userInteractionEnabled = NO;
//            UIButton *modifyButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0, 50, 50)];
//            [modifyButton setImage:[UIImage imageNamed:@"小车"] forState:UIControlStateNormal];
//            [modifyButton setBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
//                [((SOSPersonalInfomationViewController *)self.viewController) checkPINWithCompleteBlock:^{
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        ((UITextField *)item.rightFieldView).text = @"";
//                        item.rightFieldView.userInteractionEnabled = YES;
//                        [item.rightFieldView becomeFirstResponder];
//                    });
//                }];
//            }];
//            modifyButton.tag = 112;
//            [self.contentView addSubview:modifyButton];
//        }
    }   else    {
        [[self.contentView viewWithTag:112] removeFromSuperview];
    }
}

- (void)updateCellValue:(NSString *)itemValue
{ 
    _itemValue.text = itemValue;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
