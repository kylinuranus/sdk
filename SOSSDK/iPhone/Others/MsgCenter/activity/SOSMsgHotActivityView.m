//
//  SOSMsgHotActivityView.m
//  Onstar
//
//  Created by WQ on 2018/5/22.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSMsgHotActivityView.h"
#import "TLSOSRefreshHeader.h"
#import "SOSMsgHotActivityHead.h"
#import "SOSMsgActCell.h"

@interface SOSMsgHotActivityView () <UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *myCollection;
@property (weak, nonatomic) IBOutlet UIButton *btn_unRead;

@end

struct EndPos{
    NSInteger sect;
    NSInteger row;
};
typedef struct EndPos EndPos;


@implementation SOSMsgHotActivityView
{
    NSArray *dataArray;
    NSInteger pageNum;
    NSInteger totalPage;       //未读消息总共有几页
    BOOL isUnreadPress;       //是否点击了未读跳转
    BOOL isDragDown;          //是否下拉加载上一页数据
    NSInteger tempCount;
    BOOL isCheckEnd;          //是否检测当前为数据中最后一条消息
    BOOL isModifyHead;        //是否修改头高度
    BOOL isFirst;             //是否第一次渲染界面

    EndPos pos;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"layoutSubviews----");
}

+ (SOSMsgHotActivityView*)instanceView
{
    NSArray *arr = [[NSBundle SOSBundle] loadNibNamed:@"SOSMsgHotActivityView" owner:self options:nil];
    return arr[0];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    tempCount = 10;
    pageNum = 1;
    isModifyHead = NO;
    isUnreadPress = NO;
    isDragDown = NO;
    self.btn_unRead.hidden = YES;
    //self.backgroundColor = [UIColor colorWithHexString:@"C7CFD8"];
    self.backgroundColor = [UIColor Gray246];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //预估高度
    if (@available(iOS 10.0, *)) {
        layout.estimatedItemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 250);
        layout.itemSize = UICollectionViewFlowLayoutAutomaticSize;
        
    } else {
        layout.itemSize = CGSizeMake(SCREEN_WIDTH-10, 223);
    }
    
    layout.minimumLineSpacing = 0;
    self.myCollection.collectionViewLayout = layout;
    [self.myCollection registerNib:[UINib nibWithNibName:@"SOSMsgActCell" bundle:nil] forCellWithReuseIdentifier:@"LastCell"];
    [self.myCollection registerClass:[SOSMsgHotActivityHead class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"head"];
    self.myCollection.backgroundColor = [UIColor colorWithRed:246/255.0 green:243/255.0 blue:247/255.0 alpha:1];
    self.myCollection.delegate = self;
    self.myCollection.dataSource = self;
    self.myCollection.showsVerticalScrollIndicator = NO;
    [self addHeadAndFoot];
    
    self.btn_unRead.layer.masksToBounds = YES;
    self.btn_unRead.layer.cornerRadius = 12;

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
        self.myCollection.mj_footer.hidden = NO;
        if (!self->isUnreadPress) {
            self->pageNum++;
        }else
        {
            self->pageNum = self->totalPage;  //点击未读调起的刷新，加载指定页数据
            self->isUnreadPress = NO;
            [self.parent cleanData];
        }

        [self.parent go:YES pageNO:self->pageNum];
        if (self->pageNum > self->totalPage) {   //是否重置
            self->pageNum = self->totalPage;
        }
        self->isDragDown = YES;
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    [header setTitle:@"下拉加载信息" forState:MJRefreshStateIdle];
    [header setTitle:@"释放加载信息..." forState:MJRefreshStatePulling];
    [header setTitle:@"正在加载信息..." forState:MJRefreshStateRefreshing];
    self.myCollection.mj_header = header;
    
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        self->pageNum--;
        if (self->pageNum>0) {
            [self.parent go:NO pageNO:self->pageNum];
        }else
        {
            [self.myCollection.mj_footer endRefreshing];
            self.myCollection.mj_footer.hidden = YES;  //没有下一页时不需要foot
            self->pageNum = 1;      //第一次进入页面自动滚动到底部并触发底部刷新回调，因此重置pageNum
        }
        self->isDragDown = NO;
    }];
    
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在加载信息..." forState:MJRefreshStateRefreshing];
    self.myCollection.mj_footer = footer;
    self.myCollection.mj_footer.hidden = YES;
}


- (void)begin
{
    isFirst = YES;
    totalPage = _totalNum > 0 ? ceil(_totalNum/10.0) : 0;     //总页数
    [self update];
   
}

- (void)update
{
    isCheckEnd = NO;
    NSInteger num = self.unreadNum - 5;
    self.btn_unRead.hidden = num > 0 ? NO : YES;
    [self.btn_unRead setTitle:[NSString stringWithFormat:@"%ld条新消息",self.unreadNum] forState:UIControlStateNormal];
    [self.myCollection.mj_header endRefreshing];
    [self.myCollection.mj_footer endRefreshing];
    [self.myCollection reloadData];
    [self.myCollection performBatchUpdates:nil completion:^(BOOL finished) {
        [self layoutIfNeeded];
        if (isUnreadPress) {
            [self.myCollection scrollToTop];
        }else{
            [self scrollToCurrent];
        }
    }];
    [self getEndPos];
    
}

- (void)scrollToCurrent
{
    if (!isFirst && _datas.count > 0) {             //第一次进入当前页面无滚动
        NSInteger row = 0;
        NSInteger sect = 0;
        NSInteger count = 0;
        BOOL isOver = NO;
        NotifyOrActModel *m = _datas[0][0];  //数组中的距离现在最远的一条数据，确定是第几页的
        NSInteger num = m.pageNum*10-9;   //最远那一页的第一条数据
        
        if (isDragDown) {         //下拉加载上一页数据时
            for (long int i = _datas.count-1; i >= 0; i--)    //因从底部开始显示，因此数据中每个section都是倒序遍历
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
            NSIndexPath *bottomIndexPath=[NSIndexPath indexPathForItem:row inSection:sect];
            [self.myCollection scrollToItemAtIndexPath:bottomIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }

    }else{
        if (isFirst) {
            CGPoint
            bottomOffset=CGPointMake(0,self.myCollection.contentSize.height-self.myCollection.bounds.size.height);
            [self.myCollection setContentOffset:bottomOffset animated:NO];
            isFirst = NO;
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
    [self.myCollection.mj_header endRefreshing];
    [self.myCollection.mj_footer endRefreshing];

}

- (void)editHead
{
    isModifyHead = YES;
    [self.myCollection reloadData];
}



#pragma mark=========================== UICollectionViewDataSource 代理方法====================================

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    if (section == 0 && isModifyHead) {
        return  CGSizeMake(0, 60);
    }else
    {
        return  CGSizeMake(0, 40);
    }

}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"head";
    
    SOSMsgHotActivityHead *view =  [collectionView dequeueReusableSupplementaryViewOfKind :kind   withReuseIdentifier:reuseIdentifier   forIndexPath:indexPath];
    NotifyOrActModel *m = (NotifyOrActModel*)_datas[indexPath.section][indexPath.row];

    view.lb_date.text = m.sendDate;
    
    if (indexPath.section == 0 && isModifyHead) {
        [view becomeFirstHead];
    }else
    {
        [view reset];
    }
    return view;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return  _datas ?  _datas.count : 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    if (_datas.count - 1 > section) {
        NSArray *arr = [NSArray arrayWithArray:_datas[section]];;
        return arr.count;
//    }
//    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
        
    SOSMsgActCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LastCell" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    NotifyOrActModel *m = (NotifyOrActModel*)_datas[indexPath.section][indexPath.row];
    pageNum = m.pageNum;
    if (isCheckEnd && pos.sect == indexPath.section && pos.row == indexPath.row ) {
        self.btn_unRead.hidden = YES;
    }
    [cell fillData:m];
    cell.onPress = ^(NSString* url,NSString *notifyId) {
        NSLog(@"cell on press=======");
        //[SOSDaapManager sendActionInfo:My_massage_detail];
        [SOSDaapManager sendSysBanner:notifyId funcId:My_massage_detail];
        SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:url];
        //vc.isH5Title = 0;     //CR 要求不再传标题
        //vc.titleStr = m.title;
        [(UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
    };

    return cell;

}


- (IBAction)unReadOnPress:(UIButton *)sender {
    NSLog(@"unread on press");
    [SOSDaapManager sendActionInfo:My_massage_activity_showallmessage];
    self.btn_unRead.hidden = YES;
    [self.myCollection scrollToTopAnimated:YES];
    NSInteger num = self.unreadNum - 5;
    if (num <= 5) {   //不到一页不用加载
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isUnreadPress = YES;
        [self.myCollection.mj_header beginRefreshing];
    });
}


- (void)dealloc
{
    NSLog(@"dealloc");
}



@end
