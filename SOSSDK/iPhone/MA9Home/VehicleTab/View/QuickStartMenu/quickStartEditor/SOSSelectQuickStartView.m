//
//  SOSSelectQuickStartView.m
//  Onstar
//
//  Created by Onstar on 2019/1/11.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSSelectQuickStartView.h"
#import "SOSQSCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "SOSRemoteTool.h"
@interface SOSSelectQuickStartView ()<UICollectionViewDelegate,
                                    UICollectionViewDataSource,
SOSQSCellDelegate,UIGestureRecognizerDelegate,SOSQSCollectionViewLayoutDelegate>{
    UILongPressGestureRecognizer *longPressGesture;
}
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@property (weak, nonatomic) IBOutlet UIView *homeAppView;
@property (nonatomic, assign) BOOL inEditState; //是否处于编辑状态
@property (nonatomic, assign) SOSRemoteOperationType operationingType;

@property (nonatomic, assign) RemoteControlStatus RemoteControlStatus;

@end

static NSString *const cellId = @"ShowHomeAppView";

@implementation SOSSelectQuickStartView

- (void)awakeFromNib {
    [super awakeFromNib];
    UIView *bottomLine = [UIView new];
    bottomLine.backgroundColor = [UIColor colorWithHexString:@"#F3F3F4"];
    [self addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.right.equalTo(self);
        make.height.equalTo(@1);
        make.bottom.equalTo(_homeAppView.mas_top);
    }];

//    /*作用：当本页面还未初始化，在其他页面下发车辆操作后，进入本页面时下述两个值未能获取到实时操作下发状态。
//    所以在本页面初始化时，同步下操作状态*/
//    _operationingType = SOSRemoteTool.sharedInstance.lastOperationType;
//    _RemoteControlStatus = SOSRemoteTool.sharedInstance.operationStastus;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];

}

- (SOSQSCollectionViewLayout *)layout{
    if (_layout == nil) {
        self.layout = [[SOSQSCollectionViewLayout alloc]init];
        self.layout.delegate = self;
        self.inEditState = NO;
        CGFloat width = (SCREEN_WIDTH - 20) / 4;
        self.layout.itemSize = CGSizeMake(width, width);
        self.layout.minimumLineSpacing = 10;
        self.layout.minimumInteritemSpacing = 0;
        //设置collectionView整体的上下左右之间的间距
        self.layout.sectionInset = UIEdgeInsetsMake(5, 10, 10, 10);
        self.layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _layout;
}

- (UICollectionView *)collectionView{
    if (_collectionView == nil) {
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, (self.selectqsArray.count/4)*(self.layout.itemSize.width)+ 44) collectionViewLayout:self.layout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.scrollEnabled = NO;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        [self.homeAppView addSubview:self.collectionView];
        [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([SOSQSCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:cellId];

        
    }
    return _collectionView;
}
-(void)setInEditState:(BOOL)inEditState
{
    _inEditState = inEditState;
    if (inEditState) {
        if (!longPressGesture) {
            longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
            longPressGesture.minimumPressDuration = 0.2f;
            longPressGesture.delegate = self;
        }
        [_collectionView addGestureRecognizer:longPressGesture];

    }else{
        if (longPressGesture) {
            [_collectionView removeGestureRecognizer:longPressGesture];
        }
    }
    
}

//- (void)reloadData:(SOSRemoteOperationType)opeType opeStatus:(RemoteControlStatus)controlStatus {
//    _operationingType = opeType;
//    _RemoteControlStatus = controlStatus;
//    [self.collectionView reloadData];
//}
#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.selectqsArray.count;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.inEditState) { //如果不在编辑状态
        NSLog(@"点击了第%@个分区的第%@个cell", @(indexPath.section), @(indexPath.row));
        if ([self.delegate respondsToSelector:@selector(didClickSelectQSItem:)]) {
                [self.delegate performSelector:@selector(didClickSelectQSItem:) withObject:self.selectqsArray[indexPath.row]];
        }
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SOSQSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.delegate = self;
    cell.indexPath = indexPath;
     id<SOSQSModelProtol> model = self.selectqsArray[indexPath.row];
    cell.appTitle.text = [model modelTitle];
    NSString *imageName = model.modelImage;
    if ([imageName hasPrefix:@"http"]) {
        [cell.appIcon sd_setImageWithURL:imageName.mj_url placeholderImage:[UIImage imageNamed:@"icon_警示类别"]];
    }else {    
        cell.appIcon.image = [UIImage imageNamed:[model modelImage]];
    }
//    [cell.delegateApp setBackgroundImage:[UIImage imageNamed:@"vehicle_qs_delete"] forState:UIControlStateNormal];
    cell.inEditState = self.inEditState;
//    cell.inEditState = NO;
    
//    if (model.remoteOpeType == self.operationingType && self.RemoteControlStatus == RemoteControlStatus_InitSuccess) {
//        //refreshing
//        [cell shouldLoading:YES];
//    }else {
//        //normal
//        [cell shouldLoading:NO];
//    }

    return cell;
}
//selectqs删除操作
- (void)deleteFromSelectQSWithCell:(SOSQSCollectionViewCell *)deleteApp event:(id)event{
    if ([_delegate respondsToSelector:@selector(deleteFromSelectQSWithDeleteApp: event:)]) {
        [_delegate deleteFromSelectQSWithDeleteApp:self event:event];
    }
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    //获取此次点击的坐标，根据坐标获取cell对应的indexPath
    CGPoint point = [longPress locationInView:_collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    //根据长按手势的状态进行处理。
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
            //当没有点击到cell的时候不进行处理
            if (!indexPath) break;
            //开始移动
            [_collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            break;
        case UIGestureRecognizerStateChanged:
            //移动过程中更新位置坐标
            [_collectionView updateInteractiveMovementTargetPosition:point];
            break;
        case UIGestureRecognizerStateEnded:
            //停止移动调用此方法
            [_collectionView endInteractiveMovement];
            break;
        default:
            //取消移动
            [_collectionView cancelInteractiveMovement];
            break;
    }
}


// 在开始移动时会调用此代理方法，
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据indexpath判断单元格是否可以移动，如果都可以移动，直接就返回YES ,不能移动的返回NO
    return YES;
}

// 在移动结束的时候调用此代理方法
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    /**
     *sourceIndexPath 原始数据 indexpath
     * destinationIndexPath 移动到目标数据的 indexPath
     */
    
    if ([_delegate respondsToSelector:@selector(exchangeSelectQSWithDragChangeItem: index: toIndexPath:)]) {
        [_delegate exchangeSelectQSWithDragChangeItem:self index:sourceIndexPath toIndexPath:destinationIndexPath];
    }

}
#pragma mark - delegate
- (void)didChangeEditState:(BOOL)inEditState{
    self.inEditState = inEditState;
    for (SOSQSCollectionViewCell *cell in self.collectionView.visibleCells) {
        cell.inEditState = inEditState;
    }
}
-(void)showTips{
    if (_tipsLabel.hidden) {
        _tipsLabel.hidden = NO;
    }
}
-(void)hideTips{
    if (!_tipsLabel.hidden) {
        _tipsLabel.hidden = YES;
    }
}
@end
