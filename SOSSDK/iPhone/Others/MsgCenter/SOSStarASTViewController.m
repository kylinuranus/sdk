//
//  SOSStarASTViewController.m
//  Onstar
//
//  Created by Onstar on 2019/9/3.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSStarASTViewController.h"
#import "SOSOnstarASTCell.h"
#import "SOSFlexibleAlertController.h"
#import "AccountInfoUtil.h"
#import <MGSwipeTableCell/MGSwipeButton.h>

@interface SOSCategorySelectView:UIView{
    NSInteger categoryType;
    UIButton * selectB;
    
}
- (NSInteger)category;
@end
@implementation SOSCategorySelectView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}
-(void)initUI{
    UILabel *title = [[UILabel alloc] init];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"请选择提醒类型"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size: 13],NSForegroundColorAttributeName: [UIColor colorWithRed:40/255.0 green:41/255.0 blue:47/255.0 alpha:1.0]}];

    title.attributedText = string;
    title.textAlignment = NSTextAlignmentLeft;
    [self addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).mas_offset(18);
        make.leading.mas_equalTo(self).mas_offset(34);
    }];
    
    UIButton * button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    [button1 setTitle:@"预约日程提醒" forState:0];
    button1.tag = 1;
    [button1 setTitleColor:[UIColor colorWithHexString:@"#4E5059"] forState:0];
    [button1.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 12]];
    [button1 setImage:[UIImage imageNamed:@"icon_nav_uncheck_idle_25x25"] forState:UIControlStateNormal];
    [button1 setImage:[UIImage imageNamed:@"icon_nav_checked_idle_25x25"] forState:UIControlStateSelected];
    [button1 addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
     [self addSubview:button1];
    [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(title);
        make.top.mas_equalTo(title.mas_bottom).mas_offset(5);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(40);
    }];
    
    UIButton * button2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    button2.tag = 2;
    [button2.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 12]];
    [button2 setTitle:@"蓝键口述笔记" forState:0];
    [button2 setTitleColor:[UIColor colorWithHexString:@"#4E5059"] forState:0];
    [button2 setImage:[UIImage imageNamed:@"icon_nav_uncheck_idle_25x25"] forState:UIControlStateNormal];
    [button2 setImage:[UIImage imageNamed:@"icon_nav_checked_idle_25x25"] forState:UIControlStateSelected];
    [button2 addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button2];
    [button2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(title);
        make.top.mas_equalTo(button1.mas_bottom).mas_offset(5);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(40);
    }];
    
    UIButton * button3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    button3.tag = 3;
    [button3.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 12]];
    [button3 setTitle:@"综合资讯查询" forState:0];
    [button3 setTitleColor:[UIColor colorWithHexString:@"#4E5059"] forState:0];
    [button3 setImage:[UIImage imageNamed:@"icon_nav_uncheck_idle_25x25"] forState:UIControlStateNormal];
    [button3 setImage:[UIImage imageNamed:@"icon_nav_checked_idle_25x25"] forState:UIControlStateSelected];
    [button3 addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button3];
    [button3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(title);
        make.top.mas_equalTo(button2.mas_bottom).mas_offset(5);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(40);
    }];
}
-(void)click:(UIButton *)sender{
    if (selectB) {
        selectB.selected = NO;
    }
    sender.selected = !sender.selected;
    if (sender.selected) {
        selectB = sender;
        categoryType = sender.tag;
    }
}
- (NSInteger)category{
    return categoryType;
}
@end

@interface SOSStarASTViewController ()<UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate>{
    int pageNum;
    NSInteger currentCategory;
    NSMutableArray *starASTArray;
    UITableView * table;
    UILabel * clearL;
}

@end

@implementation SOSStarASTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"随星助理";
    
    @weakify(self);
    [self setRightBarButtonItemWithImageName:@"sos_messagecenter_selector" callBack:^{
        SOSCategorySelectView * cus = [[SOSCategorySelectView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*0.7, 200)];
        @weakify(cus);
        SOSFlexibleAlertController * selector = [SOSFlexibleAlertController alertControllerWithImage:nil title:nil message:nil customView:cus preferredStyle:SOSAlertControllerStyleAlert];
        SOSAlertAction *action1 = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
        }];
        SOSAlertAction *action2 = [SOSAlertAction actionWithTitle:@"确定" style:SOSAlertActionStyleDefault handler:^(SOSAlertAction * _Nonnull action) {
            @strongify(cus);
            @strongify(self);
           
            [self->table.mj_footer resetNoMoreData];
            switch ([cus category]) {
                case 1:
                    [self loadDataWithSecondCategory:1 isFirstPage:YES];
                    break;
                case 2:
                    [self loadDataWithSecondCategory:2 isFirstPage:YES];
                    break;
                case 3:
                    [self loadDataWithSecondCategory:3 isFirstPage:YES];
                    break;
                default:
                    break;
            }
        }];
        [selector addActions:@[action1,action2]];
        [selector show];
        
    }];
    
    table = [[UITableView alloc] init];
    table.delegate = self;
    table.dataSource = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [table registerClass:SOSOnstarASTCell.class forCellReuseIdentifier:@"SOSOnstarASTCell"];
    [self.view addSubview:table];
    [table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(searchMore )];
    [footer setTitle:@"全部加载，没有更多了。。。" forState:MJRefreshStateNoMoreData];
    table.mj_footer = footer;
    
    starASTArray = [NSMutableArray array];
    [self loadDataWithSecondCategory:0 isFirstPage:YES];
}
-(void)searchMore{
    [self loadDataWithSecondCategory:currentCategory isFirstPage:NO];
}
-(void)loadDataWithSecondCategory:(NSInteger)category isFirstPage:(BOOL)isFirst{
    if (isFirst) {
       [Util showLoadingView];
       pageNum = 1;
    }
    NSString *url;
    currentCategory = category;
    switch (category) {
        case 0:
            url = [[Util getConfigureURL] stringByAppendingFormat:(GET_MESSAGE_LIST),[CustomerInfo sharedInstance].userBasicInfo.idpUserId,@"STARAST",pageNum];
            break;
        case 1:
            url = [[[Util getConfigureURL] stringByAppendingFormat:(GET_MESSAGE_LIST),[CustomerInfo sharedInstance].userBasicInfo.idpUserId,@"STARAST",pageNum] stringByAppendingString:@"&secondCategory=PRECALL"];
            break;
        case 2:
            url = [[[Util getConfigureURL] stringByAppendingFormat:(GET_MESSAGE_LIST),[CustomerInfo sharedInstance].userBasicInfo.idpUserId,@"STARAST",pageNum] stringByAppendingString:@"&secondCategory=BLUENOTE"];
            break;
        case 3:
            url = [[[Util getConfigureURL] stringByAppendingFormat:(GET_MESSAGE_LIST),[CustomerInfo sharedInstance].userBasicInfo.idpUserId,@"STARAST",pageNum] stringByAppendingString:@"&secondCategory=COMINF"];
            break;
        default:
            break;
    }
    if (isFirst) {
        if (starASTArray.count>0) {
            [starASTArray removeAllObjects];
        }
        if (clearL && clearL) {
            [self dismissClear];
        }
    }
   
    @weakify(self);
    SOSNetworkOperation* sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        @strongify(self);
        MessageCenterListModel *m = [MessageCenterListModel mj_objectWithKeyValues:responseStr];
        if (isFirst) {
            if (m) {
                if (m.notifications.count>0) {
                    [starASTArray addObjectsFromArray:m.notifications];
                     pageNum++;
                }else{
                    [self promoptClear];
                }
            }else{
                [self promoptClear];
            }
            [self->table reloadData];
            [Util hideLoadView];
        }else{
            if (m) {
                if (m.notifications.count == 10) {
                    [starASTArray addObjectsFromArray:m.notifications];
                    pageNum++;
                    [table.mj_footer endRefreshing];
                }else{
                    [starASTArray addObjectsFromArray:m.notifications];
                    [table.mj_footer endRefreshingWithNoMoreData];
                }
            }else{
                 [table.mj_footer endRefreshingWithNoMoreData];
            }
            [self->table reloadData];
        }
       
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (isFirst) {
            @strongify(self);
            [Util hideLoadView];
            [self promoptClear];
        }else{
            [table.mj_footer endRefreshingWithNoMoreData];
        }
        
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}
//-(void)sdad{
//    if (_musics.count < count) {
//        [_tableView.mj_footer endRefreshing];
//    }else {
//        [_tableView.mj_footer endRefreshingWithNoMoreData];
//    }
//    _page++;
//}
-(void)promoptClear{
    if (!clearL) {
         clearL = [[UILabel alloc] init];
        [clearL setText:@"空空如也，啥也没有～"];
        [clearL setTextAlignment:NSTextAlignmentCenter];
        [clearL setFont:[UIFont systemFontOfSize:14.0f]];
        [clearL setTextColor:[UIColor lightGrayColor]];
    }
    [self.view addSubview:clearL];
    [clearL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(40);
    }];
}
-(void)dismissClear{
    if (clearL&&clearL.superview) {
        [clearL removeFromSuperview];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    SOSOnstarASTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SOSOnstarASTCell"];
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"sos_messagecenter_rowread"] backgroundColor:[UIColor clearColor]],
                         [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"sos_messagecenter_rowdelete"] backgroundColor:[UIColor clearColor]]];
    cell.leftSwipeSettings.transition = MGSwipeTransition3D;
    cell.delegate = self;
    [cell updateView:[starASTArray objectAtIndex:indexPath.row]];

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [starASTArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110.0f;
}
-(BOOL) swipeTableCell:(MGSwipeTableCell*)cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion
{
    NSLog(@"Delegate: button tapped, %@ position, index %d, from Expansion: %@",
          direction == MGSwipeDirectionLeftToRight ? @"left" : @"right", (int)index, fromExpansion ? @"YES" : @"NO");
    NSIndexPath * path = [table indexPathForCell:cell];
    if (index == 1) {
         [self deleteWithIndexPath:path];
    }else{
        [self changeReadStatusWithIndexPath:path];
    }    
    return YES;
}

/////
////UI中左滑删除需要使用图片，iOS11后有API直接配置，使用trailingSwipeActionsConfigurationForRowAtIndexPath配置即可。
//- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
//    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
////        handler ? handler(indexPath) : nil;
//        [self deleteWithIndexPath:indexPath];
//
//        completionHandler(YES);
//    }];
//    //iOS11以前的图标需要去SOSInfoFlowTableViewBaseCell中设置
////    deleteAction.backgroundColor = [UIColor colorWithHexString:@"#F3F5FE"];
//    deleteAction.image = [UIImage imageNamed:@"sos_messagecenter_rowdelete"];
//
//    UIContextualAction *readAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
//        [self changeReadStatusWithIndexPath:indexPath];
//        completionHandler(YES);
//    }];
//    //iOS11以前的图标需要去SOSInfoFlowTableViewBaseCell中设置
////    readAction.backgroundColor = [UIColor colorWithHexString:@"#F3F5FE"];
//    readAction.image = [UIImage imageNamed:@"sos_messagecenter_rowread"];
//    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[readAction,deleteAction]];
//    return config;
//}
////iOS11之前，没有相关API配置图片且没有trailingSwipeActionsConfigurationForRowAtIndexPath这个API，使用editActionsForRowAtIndexPath这个API生成滑动删除,并且需要在SOSInfoFlowTableViewBaseCell的layoutSubView中修改图片。
//- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)  {
//         [self deleteWithIndexPath:indexPath];
////        handler ? handler(indexPath) : nil;
//    }];
////    [deleteAction setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"sos_messagecenter_rowdelete"]]];
//
//    UITableViewRowAction *readAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"已读" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)  {
////        handler ? handler(indexPath) : nil;
//        [self changeReadStatusWithIndexPath:indexPath];
//    }];
//    //        [readAction setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"sos_messagecenter_rowread"]]];
//    return @[readAction,deleteAction];
//}
-(void)deleteWithIndexPath:(NSIndexPath *)indexPath{
    SOSOnstarASTCell * currentCell = [table cellForRowAtIndexPath:indexPath];
    [AccountInfoUtil updateInfoReadStatusWithNotifyId:currentCell.model.notificationId isDelete:YES];

    [table beginUpdates];
    [starASTArray removeObjectAtIndex:indexPath.row];
    [table deleteRowAtIndexPath:indexPath  withRowAnimation:UITableViewRowAnimationAutomatic];
    [table endUpdates];
}


-(void)changeReadStatusWithIndexPath:(NSIndexPath *)indexPath{
    SOSOnstarASTCell * currentCell = [table cellForRowAtIndexPath:indexPath];
    if (!currentCell.model.status.boolValue) {
        [currentCell setMsgReadState];
        
    }else{
        [Util toastWithMessage:@"该信息已读"];
    }
}
@end
