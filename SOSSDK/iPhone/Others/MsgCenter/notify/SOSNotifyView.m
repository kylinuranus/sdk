//
//  SOSNotifyView.m
//  Onstar
//
//  Created by WQ on 2018/5/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSNotifyView.h"
#import "SOSNotifyCell.h"
#import "SOSCustomNotifyCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
struct EndPos{
    NSInteger sect;
    NSInteger row;
};
typedef struct EndPos EndPos;

@interface SOSNotifyView ()
@property (weak, nonatomic) IBOutlet UITableView *myTable;

@end

@implementation SOSNotifyView
{
    UITableView *table;
    SOSNotifyCell *tempCell;
    UIButton *btn_unread;
    NSInteger totalPage;       //未读消息总共有几页
    NSInteger pageNum;
    NSInteger currentPage;     //当前页码，
    BOOL isUnreadPress;       //是否点击了未读跳转
    BOOL isDragDown;          //是否下拉加载上一页数据
    BOOL isCheckEnd;          //是否检测当前为数据中最后一条消息
    BOOL isModifyHead;        //是否修改头高度
    BOOL isFirst;             //是否第一次渲染界面
    EndPos pos;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    pageNum = 1;
    isUnreadPress = NO;
    isDragDown = NO;
    isModifyHead = NO;
    self.myTable.delegate = self;
    self.myTable.dataSource  = self;
    self.myTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.myTable.backgroundColor = [UIColor Gray246];
    self.backgroundColor = [UIColor Gray246];
    [self.myTable registerNib:[UINib nibWithNibName:@"SOSNotifyCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [self.myTable registerClass:NSClassFromString(@"SOSCustomNotifyCell") forCellReuseIdentifier:@"SOSCustomNotifyCell"];
    self.myTable.estimatedRowHeight = 60;
    [self addHeadAndFoot];
    
}

+ (SOSNotifyView*)instanceView
{
    NSArray *arr = [[NSBundle SOSBundle] loadNibNamed:@"SOSNotifyView" owner:self options:nil];
    return arr[0];
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {

    }
    return self;
}



- (void)addHeadAndFoot
{
    
    @weakify(self)
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        self.myTable.mj_footer.hidden = NO;  //下拉刷新后有foot
        if (!self->isUnreadPress) {
            self->pageNum++;
        }else
        {
            self->pageNum = self->totalPage;     //点击未读调起的刷新，加载指定页数据
            self->isUnreadPress = NO;
            [self.parentVC cleanData];
        }
        [self.parentVC go:YES pageNum:self->pageNum];  //YES 下拉刷新
        if (self->pageNum > self->totalPage) {   //是否重置
            self->pageNum = self->totalPage;
        }
        self->isDragDown = YES;
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    [header setTitle:@"下拉加载信息" forState:MJRefreshStateIdle];
    [header setTitle:@"释放加载信息..." forState:MJRefreshStatePulling];
    [header setTitle:@"正在加载信息..." forState:MJRefreshStateRefreshing];
    self.myTable.mj_header = header;
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        self->pageNum--;
        if (self->pageNum>0) {
            [self.parentVC go:NO pageNum:self->pageNum];   //NO 上拉加载
        }else
        {
            [self.myTable.mj_footer endRefreshing];
            self.myTable.mj_footer.hidden = YES;
            self->pageNum = 1;
        }
        self->isDragDown = NO;
    }];
    
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在加载信息..." forState:MJRefreshStateRefreshing];
    self.myTable.mj_footer = footer;
    self.myTable.mj_footer.hidden = YES; //第一次进入页面自动滚动到底部并触发底部刷新回调，因此隐藏foot

}


- (void)addUnReadBtn
{

    totalPage = _totalNum > 0 ? ceil(_totalNum/10.0) : 0;     //总页数
    btn_unread = [UIButton new];
    btn_unread.backgroundColor = [UIColor whiteColor];
    NSInteger unReadnum = _unreadNum - 5;             //如果未读超过5条，则出现未读按钮，减去5条为按钮上显示的数字
    btn_unread.hidden = unReadnum > 0 ? NO : YES;
    NSString *s  =[NSString stringWithFormat:@"%ld条新消息",_unreadNum];
    [btn_unread setTitle:s forState:UIControlStateNormal];
    //btn.titleLabel.textAlignment = NSTextAlignmentLeft;
    btn_unread.titleLabel.font = [UIFont systemFontOfSize:12];
    UIColor *fontColor = [UIColor colorWithRed:30/255.0 green:144/255.0 blue:255/255.0 alpha:1];
    [btn_unread setTitleColor:fontColor forState:UIControlStateNormal];

    btn_unread.layer.masksToBounds = YES;
    btn_unread.layer.cornerRadius = 14;
    btn_unread.layer.borderColor = [UIColor colorWithRed:246/255.0 green:243/255.0 blue:247/255.0 alpha:1].CGColor;
    btn_unread.layer.borderWidth = 1;
    [self addSubview:btn_unread];
    
    [btn_unread mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(90);
        make.right.equalTo(self.mas_right).offset(24);
        make.width.mas_equalTo(140);
        make.height.mas_equalTo(30);
    }];
    
    UIImageView *v = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_up_new massge"]];
    [btn_unread addSubview:v];
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(btn_unread.mas_centerY);
        make.left.equalTo(btn_unread.mas_left).offset(8);
        make.width.mas_equalTo(18);
        make.height.mas_equalTo(18);
    }];
    
    @weakify(self)
    [[btn_unread rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        [self unReadOnPress];
    }];
}

- (void)unReadOnPress
{
    [SOSDaapManager sendActionInfo:My_massage_notificition_showallmessage];
    btn_unread.hidden = YES;
    [self.myTable scrollToTop];
    NSInteger num = self.unreadNum - 5;
    if (num <= 5) {   //不到一页不用加载
        return;
    }
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        self->isUnreadPress = YES;
        [self.myTable.mj_header beginRefreshing];
    });
}


- (void)begin
{
    isFirst = YES;
    [self addUnReadBtn];
    [self update];
    [self.myTable scrollToRow:_datas.lastObject.count-1 inSection:_datas.count-1 atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    isFirst = NO;
}

- (void)update
{
    isCheckEnd = NO;
    [self endRefresh];
    [self.myTable reloadData];
    [self.myTable layoutIfNeeded];  //强制重绘并等待完成
    [self scrollToCurrent];
    [self getEndPos];
}

- (void)scrollToCurrent
{
    if (!isFirst) {      //第一次进入当前页面，无滚动
        NSInteger row = 0;
        NSInteger sect = 0;
        NSInteger count = 0;
        BOOL isOver = NO;
        NotifyOrActModel *m = _datas[0][0];
        NSInteger num = m.pageNum*10-9;
        if (isDragDown) {
            for (long int i = _datas.count-1; i >= 0; i--)
            {
                if (isOver) {
                    break;
                }
                for (long int j = _datas[i].count-1; j >= 0; j--)
                {
                    if (count == num)
                    {
                        row = j;
                        sect = i;
                        isOver = YES;
                        break;
                    }
                    count++;
                }
            }
            [self.myTable scrollToRow:row inSection:sect atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
}


- (void)getEndPos
{
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        self->isCheckEnd = YES;
        self->pos.sect = 0;
        self->pos.row = 0;
    });

}

- (void)endRefresh
{
    [self.myTable.mj_header endRefreshing];
    [self.myTable.mj_footer endRefreshing];
}

- (void)editHead
{
    isModifyHead = YES;
    [self.myTable reloadData];
}


#pragma mark uitableView delegate----------------

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 && isModifyHead) {
        return 64.0;
    }else
    {
        return 44.0;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [UIView new];
    if (_useCustomCell) {
        v.backgroundColor = [UIColor clearColor];

    }else{
        v.backgroundColor = [UIColor Gray246];
    }
    
    if (section == 0 && isModifyHead) {
        UILabel *lb = [UILabel new];
        lb.text = @"———— 所有通知已加载完成 ————";
        lb.textColor =  [UIColor Gray185];
        lb.font = [UIFont systemFontOfSize:12];
        [v addSubview:lb];
        
        [lb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(v.mas_top).offset(6);
            make.centerX.equalTo(v.mas_centerX);
            make.width.mas_equalTo(214);
            make.height.mas_equalTo(14);
        }];
    }

    UIImageView *bg = [UIImageView new];
    bg.backgroundColor = [UIColor Gray185];
    bg.layer.masksToBounds = YES;
    bg.layer.cornerRadius = 12;
    [v addSubview:bg];
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(v.mas_centerX);
        if (section == 0 && isModifyHead) {
            make.centerY.equalTo(v.mas_centerY).offset(14);
        }else
        {
            make.centerY.equalTo(v.mas_centerY);
        }
        make.width.mas_equalTo(114);
        make.height.mas_equalTo(26);
    }];
    
    NSArray *arr = _datas[section];
    NotifyOrActModel *m = (NotifyOrActModel*)arr[0];
    UILabel *lb_date = [UILabel new];
    lb_date.text = m.sendDate;
    lb_date.textColor = [UIColor whiteColor];
    lb_date.font = [UIFont systemFontOfSize:12];
    lb_date.textAlignment = NSTextAlignmentCenter;
    [bg addSubview:lb_date];
    
    [lb_date mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bg.mas_centerX);
        make.centerY.equalTo(bg.mas_centerY);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(30);
    }];
    
    return v;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _datas ? _datas.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_datas) {
        NSArray *arr = _datas[section];
        return arr.count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotifyOrActModel *m = (NotifyOrActModel*)_datas[indexPath.section][indexPath.row];
    UITableViewCell * cell ;
    if (_useCustomCell) {
        cell = (SOSCustomNotifyCell *)([tableView dequeueReusableCellWithIdentifier:@"SOSCustomNotifyCell"]);
        [(SOSCustomNotifyCell *)cell updateView:m];
        
    }else{
        cell = (SOSNotifyCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
        [(SOSNotifyCell *)cell fillData:m];
        ((SOSNotifyCell *)cell).onPress = ^(NSString *url,NSString *notifyId) {
            NSLog(@"点击了查看详情=======");
            [SOSDaapManager sendSysBanner:notifyId funcId:My_massage_detail];
            SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:url];
            //        vc.isH5Title = 0;     //CR 要求不再传标题
            //        vc.titleStr = m.title;
            [(UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
        };

    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tag = indexPath.row;
    pageNum = m.pageNum;
    if (isCheckEnd && pos.sect == indexPath.section && pos.row == indexPath.row ) {
        btn_unread.hidden = YES;
    }

    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{ return 1;}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
    view.backgroundColor = [UIColor colorWithHexString:@"e8ebef"];
    return view;
}

- (void)dealloc
{
    NSLog(@"-----dealloc-----");
}

@end
