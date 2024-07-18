//
//  ErrorPageViewController.m
//  Onstar
//
//  Created by Vicky on 16/3/1.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "ErrorPageVC.h"
#import "UIBarButtonItem+Extension.h"

@interface ErrorPageVC ()

@end

@implementation ErrorPageVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = _errorTitle;
    _ImageView.image = [UIImage imageNamed:_imageName];
    _labelDetail.text = _detail;

    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(errorPageBackTapped) image:@"common_Nav_Back" highImage:@"common_Nav_Back"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refresh)];
    [self.view addGestureRecognizer:tap];
}

- (void)refresh {
    if (self.refreshBlock) {
        self.refreshBlock();
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }
}

- (id)initWithErrorPage:(NSString *)title imageName:(NSString *)imageName detail:(NSString *)detail{
    self = [super initWithNibName:@"ErrorPageVC" bundle:nil];
    if (self)
    {
        _errorTitle = title;
        _imageName= imageName;
        _detail = detail;
    }
    return self;
}

- (void)errorPageBackTapped {
    if (_delegate && [_delegate respondsToSelector:@selector(errorPageBackTapped)]) {
        [_delegate errorPageBackTapped];
    }
}



@end
