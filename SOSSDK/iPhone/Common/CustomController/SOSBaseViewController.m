//
//  SOSBaseViewController.m
//  Onstar
//
//  Created by Onstar on 2017/10/25.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseViewController.h"

@interface SOSBaseViewController ()

@end

@implementation SOSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [SOSUtil onstarLightGray];
    
}

- (void)addNavBarBackBtn {
    [self addNavBarBackBtn:nil color:nil];
}

- (void)addNavBarBackBtn:(UIImage *)image color:(UIColor *)color{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image ? : [UIImage imageNamed:@"common_Nav_Back"] forState:UIControlStateNormal];
    button.size = CGSizeMake(30, 50);
    [button mas_makeConstraints:^(MASConstraintMaker *make){
        make.size.mas_equalTo(CGSizeMake(30, 44));
    }];

    button.backgroundColor = [UIColor clearColor];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, -1, 0, 0);
    [button addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    if (color) {
        button.tintColor = color;
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)goBack:(UIButton *)button {
    //子类实现
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    NSLog(@"%@ has dealloced", NSStringFromClass([self class]));
}


@end
