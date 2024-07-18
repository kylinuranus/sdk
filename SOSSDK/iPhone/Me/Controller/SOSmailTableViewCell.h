//
//  SOSmailTableViewCell.h
//  Onstar
//
//  Created by Genie Sun on 2017/3/23.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SendCodeBtn)(UIButton *sendBtn);

@interface SOSmailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *codeTf;
@property(nonatomic, strong) SendCodeBtn sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;

- (void)sendCodeBtn:(SendCodeBtn)sendbtn;

@end
