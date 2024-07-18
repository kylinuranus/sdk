//
//  SOSPageScrollViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/7/28.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSPageScrollViewController.h"

@interface SOSPageScrollViewController ()
@end

@implementation SOSPageScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    if (@available(iOS 11.0, *)) {
        
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    for (UIViewController * pageVC in self.pageControllers) {
        [self addChildViewController:pageVC];
    }
    _mainView = [[SOSPageScrollMainView alloc] initWithFrame:self.view.frame tableViews:self.pageControllers tableTitle:self.pageTitles headerScrollParameter:_scrollPara];
    [_mainView configHeaderView:_headerMainView withBackground:_headerbg];
    if (_scrollBlock) {
        [_mainView setScrollBlock:_scrollBlock];
    }
    [self.view addSubview:_mainView];
    [_mainView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];
}

- (void)configHeaderView:(UIView *)headerV headerBackground:(UIImage *)bgimage 
{
    _headerMainView = headerV;
    _headerbg = bgimage;
}

- (void)configScrollControllers:(NSArray *)pageControllers controllerTitles:(NSArray *)titles
{
    self.pageControllers = pageControllers;
    self.pageTitles = titles;
}

- (void)configHeaderScrollParameter:(SOSPageScrollParaCenter *)para
{
    _scrollPara = para;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
