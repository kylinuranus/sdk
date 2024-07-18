//
//  LBSConsigneeCell.h
//  LBSTest
//
//  Created by jieke on 2019/6/13.
//  Copyright © 2019 jieke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBSConsigneeCell : UITableViewCell

@property (nonatomic, copy) void(^changeTextFieldBlock)(NSString *textFieldString);
@property (nonatomic, strong) UITextField *textField;

- (void)setShowText:(NSString *)text;

@end
