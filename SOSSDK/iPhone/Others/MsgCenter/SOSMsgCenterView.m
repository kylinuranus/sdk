//
//  SOSMsgCenterView.m
//  Onstar
//
//  Created by WQ on 2018/5/21.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSMsgCenterView.h"
#import "UIImageView+Banner.h"
#import "TYCyclePagerView.h"
#import "TYPageControl.h"
#import "SOSCycleBannerViewCell.h"
#import "SOSMsgCenterCell.h"
#import "SOSMsgCenterBanner.h"

#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
@interface SOSMsgCenterView () <UITableViewDelegate,UITableViewDataSource>
{
    SOSMsgCenterBanner *bannerV;
}
@property (weak, nonatomic) IBOutlet UILabel *lb_empty;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIView *bannerBg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (strong, nonatomic) NSIndexPath* editingIndexPath;  //当前左滑cell的index，在代理方法中设置

@property (weak, nonatomic) IBOutlet UILabel *lb_tuijian;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableTopWithNoBanner;

@end

@implementation SOSMsgCenterView
{
    NSMutableArray *datas;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    bannerV = [SOSMsgCenterBanner instanceView];
    [self.bannerBg addSubview:bannerV];
    [bannerV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bannerBg);
    }];
    
    self.myTableView.delegate = self;
    self.myTableView.dataSource  = self;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.myTableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:243/255.0 blue:247/255.0 alpha:1];
    self.backgroundColor = [UIColor colorWithRed:246/255.0 green:243/255.0 blue:247/255.0 alpha:1];
    //self.myTableView.hidden = YES;
}


+ (SOSMsgCenterView*)instanceView
{
    NSArray *arr = [[NSBundle SOSBundle] loadNibNamed:@"SOSMsgCenterView" owner:self options:nil];
    return arr[0];
}
    

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"initWithCoder---------");
    if (self = [super initWithCoder:aDecoder]) {
        datas = [NSMutableArray array];
    }
    return self;
}

- (void)update
{
    datas = [NSMutableArray arrayWithArray:_model.notificationStatusList];
    [self.myTableView reloadData];
    if (datas.count <= 0) {
        [self bringSubviewToFront:self.lb_empty];
    }
}


- (void)hiddenBanner
{
    self.lb_tuijian.hidden = YES;
    self.bannerBg.hidden = YES;
    self.lb_empty.hidden = NO;
    self.tableViewHeight.priority = 250;
    self.tableTopWithNoBanner.priority = 750;
}


- (void)updateBanner
{
    self.lb_tuijian.hidden = NO;
    self.bannerBg.hidden = NO;
    self.lb_empty.hidden = YES;
    self.tableViewHeight.priority = 750;
    self.tableTopWithNoBanner.priority = 250;

    [bannerV refreshWithBanners:_banners];
}

- (void)viewDidLayout
{
    NSLog(@"viewDidLayout-----");
    if (self.editingIndexPath)
    {
        [self configSwipeButtons];
    }
}

- (void)configSwipeButtons
{
    // 获取选项按钮的reference
    if (SYSTEM_VERSION_GREATER_THAN(@"11.0"))
    {
        // iOS 11层级 (Xcode 9编译): UITableView -> UISwipeActionPullView
        for (UIView *subview in self.myTableView.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISwipeActionPullView")] && [subview.subviews count] >0)
            {
                // 和iOS 10的按钮顺序相反
                UIButton *deleteButton = subview.subviews[0];
                [self configDeleteButton:deleteButton];
            }
        }
    }
    else
    {
        // iOS 8-10层级: UITableView -> UITableViewCell -> UITableViewCellDeleteConfirmationView
        SOSMsgCenterCell *tableCell = [self.myTableView cellForRowAtIndexPath:self.editingIndexPath];
        for (UIView *subview in tableCell.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")] && [subview.subviews count] >0)
            {
                UIButton *deleteButton = subview.subviews[0];
                [self configDeleteButton:deleteButton];
                [subview setBackgroundColor:[UIColor colorWithHexString:@"E5E8E8"]];
            }
        }
    }
}


- (void)configDeleteButton:(UIButton*)delBtn
{
    if (delBtn)
    {
        [delBtn setTitle:@"" forState:UIControlStateNormal];
        delBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [delBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        delBtn.titleEdgeInsets = UIEdgeInsetsMake(70, 20, 30, 44);
        
        UIImageView *v = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_delete_massge"]];
        [delBtn addSubview:v];
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            //make.top.equalTo(deleteButton.mas_top).offset(0);
            make.left.equalTo(delBtn.mas_left).offset(30);
            make.centerY.equalTo(delBtn.mas_centerY).offset(-10);
            make.width.height.mas_equalTo(20);
        }];
        
        UILabel *lb = [UILabel new];
        lb.text = @"清除消息";
        lb.font = [UIFont systemFontOfSize:12];
        lb.textColor = [UIColor whiteColor];
        lb.textAlignment = NSTextAlignmentCenter;
        [delBtn addSubview:lb];
        [lb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(v.mas_bottom).offset(2);
            make.centerX.equalTo(v.mas_centerX).offset(0);
            make.width.mas_equalTo(70);
            make.height.mas_equalTo(16);
        }];
    }
}


#pragma mark - table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    SOSMsgCenterCell *cell ;
    if (!cell) {
        cell = [[NSBundle SOSBundle] loadNibNamed:@"SOSMsgCenterCell" owner:self options:nil][0];
    }
//    cell.tag = [indexPath row];
    [cell fillData:datas[indexPath.row]];
    return cell;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MessageModel *m = datas[indexPath.row];
    if ([m.category isEqualToString:@"ACTIVITY"]) {
        [_parent goActivity];
    }else
    {
        if ([m.category isEqualToString:@"STARAST"]) {
            [_parent goStarAst];
        }else{
           [_parent goNotifyWithCategory:m.category categoryTitle:m.categoryZh];
        }
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MessageModel *m = datas[indexPath.row];
        NSLog(@"删除");
        NSString *str = indexPath.row == 0 ? My_massage_activity_delete : My_massage_notificition_delete;
        [SOSDaapManager sendActionInfo:str];
        [_parent delMsg:m.category];
        // 刷新
        //[datas removeObjectAtIndex:0];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


//即将进入编辑状态
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.editingIndexPath = indexPath;
    [_parent.view setNeedsLayout];   // 触发- (void)viewDidLayoutSubviews
}

//即将退出编辑状态
- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.editingIndexPath = nil;
}


- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
