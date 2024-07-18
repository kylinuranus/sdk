//
//  SOSQuickStartEditorViewController.m
//  Onstar
//
//  Created by Onstar on 2019/1/10.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//
#import "SOSQuickStartEditorViewController.h"
#import "SOSSelectQuickStartView.h"
#import "SOSQSCollectionReusableHeaderView.h"
#import "SOSQSCollectionReusableFooterView.h"
#import "SOSQSCollectionViewCell.h"
#import "SOSQSCollectionViewLayout.h"
#import "SOSRemoteTool.h"
/**
 界面分上下两部分,上部已选定QS(quickStart)区,下部全量QS区
 */
@interface SOSQuickStartEditorViewController ()<UICollectionViewDelegate,
UICollectionViewDataSource,

SOSSelectQuickStartViewDelegate,
SOSQSCellDelegate,
SOSQSCollectionViewLayoutDelegate>
{
    CGFloat _selectqsAreaHeight;
    CGFloat _allqsAreaHeight;
    NSMutableArray<id<SOSQSModelProtol>> *tempSelectqsArray;//还原使用
    UIButton *editbtn;
    UIBarButtonItem * customBackItem;
}

//已经选择的qs array
@property (nonatomic, strong) NSMutableArray<id<SOSQSModelProtol>> *selectqsArray;

@property (nonatomic, strong) NSMutableArray<NSMutableArray <id<SOSQSModelProtol>> *> *allqsArray;    //全量qs array
@property (nonatomic, strong) UICollectionView *allqsCollectionView;//全量QS区
@property (nonatomic, strong) SOSSelectQuickStartView *selectqsCollectionView;//选定QS区
@property (nonatomic, strong) UIScrollView *basementScrollView; //底基
@property (nonatomic, strong) SOSQSCollectionViewLayout *layout;
@property (nonatomic, assign) BOOL inEditState; //是否处于编辑状态
@property (nonatomic, copy) NSArray * groupName;

@property (nonatomic, assign) SOSRemoteOperationType operationingType;

@property (nonatomic, assign) RemoteControlStatus RemoteControlStatus;

@end

const CGFloat navViewH = 64;
const CGFloat homeAppViewH = 44;
const CGFloat collectionReusableViewH = 40;

static NSString *const cellId = @"CategoryHomeShowAppCell";
static NSString *const headerId = @"CollectionReusableHeaderView";
static NSString *const footerId = @"CollectionReusableFooterView";

@implementation SOSQuickStartEditorViewController
- (instancetype)initWithSelectqsArray:(NSMutableArray *)selectqsArray allqsArray:(NSMutableArray *)allqsArray groupNameArray:(NSArray *)groupName needUniqueCheck:(BOOL)check{
    if (self = [super init]) {
//        NSAssert(selectqsArray.count >= 1 && allqsArray.count >= 1, @"数组不能为空");
//        NSAssert(groupName.count == allqsArray.count, @"数组数量要一致");
        //        NSAssert(![[selectqsArray objectAtIndex:0] conformsToProtocol:@protocol(SOSQSModelProtol)], @"必须实现SOSQSModelProtol协议");
        self.selectqsArray =selectqsArray.mutableCopy;
        self.allqsArray =allqsArray.mutableCopy;
        self.groupName = groupName;
        //唯一对应
        if (check) {
            [self uniqueQSHandle];
        }
        self.minKeepNumber = 3;//Default
        self.maxKeepNumber = 11;
        tempSelectqsArray = self.selectqsArray.mutableCopy;
    }
    return self;
}

-(void)uniqueQSHandle{
    [self.selectqsArray enumerateObjectsUsingBlock:^(id<SOSQSModelProtol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.allqsArray enumerateObjectsUsingBlock:^(NSMutableArray<id<SOSQSModelProtol>> * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop) {
            [obj1 enumerateObjectsUsingBlock:^(id<SOSQSModelProtol>  _Nonnull obj2, NSUInteger idx2, BOOL * _Nonnull stop) {
                if ([obj2 respondsToSelector:@selector(modelID)]) {
                    if ([obj2.modelID isEqualToString:obj.modelID]) {
                        [self.selectqsArray replaceObjectAtIndex:idx withObject:obj2];
                        *stop = YES;
                    }
                }else{
                    if ([obj2.modelTitle isEqualToString:obj.modelTitle]) {
                        [self.selectqsArray replaceObjectAtIndex:idx withObject:obj2];
                        *stop = YES;
                    }
                }
            }];
        }];
    }];
}
- (NSMutableArray *)allqsArray{
    if (_allqsArray == nil) {
        _allqsArray = [NSMutableArray array];
    }
    return _allqsArray;
}

- (NSMutableArray *)selectqsArray{
    if (_selectqsArray == nil) {
        _selectqsArray = [NSMutableArray array];
    }
    return _selectqsArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor colorWithHexString:@"F5F7FE"];
    customBackItem = self.navigationItem.leftBarButtonItem;
    
    [self subView];
    [self normalState];
    if (self.navTitle) {
        self.title = self.navTitle;
    }
    editbtn = [UIButton buttonWithType:0];
    [editbtn setTitle:@"编辑" forState:0];
    [editbtn setTitle:@"保存" forState:UIControlStateSelected];
    editbtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15.f];
    [editbtn setTitleColor:[UIColor colorWithHexString:@"#6896ED"] forState:0];
    [editbtn addTarget:self action:@selector(clickEditBut:) forControlEvents:UIControlEventTouchUpInside];
    [editbtn sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editbtn];
    
    if (self.backFunctionID) {
        self.backDaapFunctionID = self.backFunctionID;
    }
    
//    /*作用：当本页面还未初始化，在其他页面下发车辆操作后，进入本页面时下述两个值未能获取到实时操作下发状态。
//    所以在本页面初始化时，同步下操作状态*/
//    _operationingType = SOSRemoteTool.sharedInstance.lastOperationType;
//    _RemoteControlStatus = SOSRemoteTool.sharedInstance.operationStastus;
//
//    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_VEHICLE_OPERATE_NOTIFICATION object:nil] subscribeNext:^(NSNotification *noti) {
//        //        @{@"state":@(RemoteControlStatus_OperateFail), @"OperationType" : @(type)}
//        NSDictionary *notiDic = noti.userInfo;
//        RemoteControlStatus resultState = [notiDic[@"state"] intValue];
//        SOSRemoteOperationType operationType = [notiDic[@"OperationType"] intValue];
//        BOOL havc = [notiDic[@"HVAC"] boolValue];
//        if (notiDic[@"OperationType"]) {
//            if (operationType == SOSRemoteOperationType_RemoteStart && havc) {
//                self.operationingType = SOSRemoteOperationType_OpenHVAC;
//            }else if(operationType == SOSRemoteOperationType_CloseHVAC) {
//                self.operationingType = SOSRemoteOperationType_OpenHVAC;
//            }else if (operationType == SOSRemoteOperationType_Light || operationType == SOSRemoteOperationType_Horn) {
//                self.operationingType = SOSRemoteOperationType_LightAndHorn;
//            }else {
//                self.operationingType = operationType;
//            }
//            self.RemoteControlStatus = resultState;
//            if (!_inEditState) {
//                [self.selectqsCollectionView reloadData:_operationingType opeStatus:_RemoteControlStatus];
//                [self.allqsCollectionView reloadData];
//            }
//        }
//    }];
    
}
-(void)leftBarButtonItemBack{
   self.navigationItem.leftBarButtonItem = customBackItem;
}
-(void)leftBarButtonItemCancel{
    UIButton *cancelbtn = [UIButton buttonWithType:0];
    [cancelbtn setTitle:@"取消" forState:0];
    cancelbtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15.f];
    [cancelbtn setTitleColor:[UIColor colorWithHexString:@"#A4A4A4"] forState:0];
    [cancelbtn addTarget:self action:@selector(cancelEditAction) forControlEvents:UIControlEventTouchUpInside];
    [cancelbtn sizeToFit];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelbtn];
}
//取消编辑
- (void)cancelEditAction    {
    if (!self.inEditState) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        //        [Util showAlertWithTitle:nil message:NSLocalizedString(@"Are_you_sure", nil) completeBlock:^(NSInteger buttonIndex) {
        //            if (buttonIndex == 1) {
        //                [self editComplete];
        //            }else{
        self.selectqsCollectionView.selectqsArray = [tempSelectqsArray mutableCopy];
        self.selectqsArray = self.selectqsCollectionView.selectqsArray;
        [self.selectqsCollectionView.collectionView reloadData];
        [self editCancel];
       
        //                //取消编辑
        //                self.sq
        //            }
        //        } cancleButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"保存", nil), nil];
    }
}
- (void)cellClickBlock:(void (^)(id<SOSQSModelProtol> modelItem))block {
    self.cellClickBlock = block;
}
- (UIScrollView *)basementScrollView{
    if (_basementScrollView == nil) {
        _basementScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _basementScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        //        self.basementScrollView.backgroundColor = [UIColor blueColor];
        _basementScrollView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_basementScrollView];
        [_basementScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(10, 0, 0, 0));
        }];
    }
    return _basementScrollView;
}

- (SOSQSCollectionViewLayout *)layout{
    if (_layout == nil) {
        _layout = [[SOSQSCollectionViewLayout alloc]init];
        CGFloat width = (SCREEN_WIDTH - 20) / 4;
        _layout.delegate = self;
        _layout.itemSize = CGSizeMake(width, width);
        _layout.minimumLineSpacing = 10;
        _layout.minimumInteritemSpacing = 0;
        //设置collectionView整体的上下左右之间的间距
        _layout.sectionInset = UIEdgeInsetsMake(5, 10, 10, 10);
        _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _layout;
}

- (void)subView{
    
    self.selectqsCollectionView = [SOSSelectQuickStartView viewFromXib];
    self.selectqsCollectionView.selectqsArray = self.selectqsArray;
    [self.basementScrollView addSubview:self.selectqsCollectionView];
    self.selectqsCollectionView.delegate = self;
    
    self.allqsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _allqsAreaHeight) collectionViewLayout:self.layout];;
    self.allqsCollectionView.showsVerticalScrollIndicator = NO;
    [self.basementScrollView addSubview:self.allqsCollectionView];
    self.allqsCollectionView.backgroundColor = [UIColor colorWithHexString:@"#F5F7FE"];
    self.allqsCollectionView.delegate = self;
    self.allqsCollectionView.dataSource = self;
    CGFloat appCollectionH = self.allqsCollectionView.collectionViewLayout.collectionViewContentSize.height;
    _allqsAreaHeight = appCollectionH + homeAppViewH + 20;
    //    self.allqsCollectionView.frame = CGRectMake(0, homeAppViewH, SCREEN_WIDTH, _allqsAreaHeight);
    self.basementScrollView.contentSize = CGSizeMake(0, _allqsAreaHeight);
    
    [self.allqsCollectionView  registerNib:[UINib nibWithNibName:NSStringFromClass([SOSQSCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:cellId];
    [self.allqsCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([SOSQSCollectionReusableHeaderView class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId];
    [self.allqsCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([SOSQSCollectionReusableFooterView class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerId];
    
}
- (void)clickEditBut:(UIButton *)sender{
    if (sender.isSelected) {
        [self editComplete];
    }else{
        [self beginEdit];
    }
    sender.selected = !sender.selected;
    
}
#pragma mark - edit
// 编辑
- (void)beginEdit{
    [self showSubView:NO];
    [self leftBarButtonItemCancel];
    self.inEditState = YES;
    self.allqsCollectionView.allowsSelection = NO;
    self.selectqsCollectionView.collectionView.allowsSelection = NO;
    [self.layout setInEditState:self.inEditState];
    [self.selectqsCollectionView.layout setInEditState:self.inEditState];
    [self.selectqsCollectionView showTips];
    self.title = self.editNavTitle;
    
    if (self.editFunctionID) {
        [SOSDaapManager sendActionInfo:self.editFunctionID];
    }
}
- (void)normalState{
    [self showSubView:YES];
    [self leftBarButtonItemBack];
    if (editbtn.selected) {
        editbtn.selected = !editbtn.selected;
    }
    self.inEditState = NO;
    self.allqsCollectionView.allowsSelection = YES;
    self.selectqsCollectionView.collectionView.allowsSelection = YES;
    [self.layout setInEditState:self.inEditState];
    [self.selectqsCollectionView hideTips];
    self.title = self.navTitle;
    [self.selectqsCollectionView.layout setInEditState:self.inEditState];
    
}
// 取消
- (void)editCancel{
    [self normalState];
    if (self.cancelFunctionID) {
        [SOSDaapManager sendActionInfo:self.cancelFunctionID];
    }
}
// 保存
- (void)editComplete{
    [self showSubView:YES];
    [self leftBarButtonItemBack];
    self.inEditState = NO;
    [self.layout setInEditState:self.inEditState];
    [self.selectqsCollectionView.layout setInEditState:self.inEditState];
    self.allqsCollectionView.allowsSelection = YES;
    self.selectqsCollectionView.collectionView.allowsSelection = YES;
    [self.selectqsCollectionView hideTips];
    self.title = self.navTitle;
    tempSelectqsArray = self.selectqsArray.mutableCopy;
    if ([_delegate respondsToSelector:@selector(editCompleteWithSelectQS:andAllqsArray:)]) {
        [_delegate editCompleteWithSelectQS:self.selectqsArray andAllqsArray:self.allqsArray];
    }
    if (self.saveFunctionID) {
        [SOSDaapManager sendActionInfo:self.saveFunctionID];
    }
    NSLog(@"点击了完成按钮");
//    [self.navigationController popViewControllerAnimated:YES];
    
}
#pragma mark ---
- (void)showSubView:(BOOL)show{
    if (show) {
        [self setUpInteractivePopGestureRecognizerEnabled:YES scrollEnabled:YES];
        [self updateAllAreaFrame];
    }else{
        [self setUpInteractivePopGestureRecognizerEnabled:NO scrollEnabled:YES];
        [UIView animateWithDuration:0.3 animations:^{
            [self updateAllAreaFrame];
        }];
    }
}

- (void)setUpInteractivePopGestureRecognizerEnabled:(BOOL)enabled scrollEnabled:(BOOL)scrollEnabled{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = enabled;
        self.fd_interactivePopDisabled = !enabled;
    }
    
    if (scrollEnabled) {
        self.basementScrollView.scrollEnabled = NO;
        self.allqsCollectionView.scrollEnabled = YES;
        self.allqsCollectionView.showsVerticalScrollIndicator = NO;
    }else{
        self.basementScrollView.scrollEnabled = YES;
        self.allqsCollectionView.scrollEnabled = NO;
    }
}

- (void)updateAllAreaFrame{
    
    _selectqsAreaHeight = self.selectqsCollectionView.collectionView.collectionViewLayout.collectionViewContentSize.height+40;
    CGFloat selectqsAreaHeight = _selectqsAreaHeight+44;
    self.selectqsCollectionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, ceil(selectqsAreaHeight));
    self.selectqsCollectionView.collectionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, _selectqsAreaHeight);
    
    CGRect newFrame = self.allqsCollectionView.frame;
    newFrame.origin.y = _selectqsAreaHeight + 44;
    newFrame.size.height = SCREEN_HEIGHT - (navViewH) - newFrame.origin.y;
    self.allqsCollectionView.frame = newFrame;
    
}

#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.allqsArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [[self.allqsArray objectAtIndex:section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SOSQSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    NSLog(@"indexPath--:%@,%@",indexPath,cell);
    [cell setSelectqsArray:self.selectqsArray allqsArray:self.allqsArray indexPath:indexPath];
    //是否处于编辑状态
    cell.inEditState = self.inEditState;
    cell.delegate = self;
    
//    id<SOSQSModelProtol> model = self.allqsArray[indexPath.section][indexPath.row];
//    if (model.remoteOpeType == self.operationingType && self.RemoteControlStatus == RemoteControlStatus_InitSuccess) {
//        //refreshing
//        [cell shouldLoading:YES];
//    }else {
//        //normal
//        [cell shouldLoading:NO];
//    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.inEditState) { //如果不在编辑状态
        NSLog(@"点击了第%@个分区的第%@个cell", @(indexPath.section), @(indexPath.row));
        if (self.cellClickBlock) {
            SOSWeakSelf(weakSelf);
            weakSelf.cellClickBlock([weakSelf.allqsArray[indexPath.section] objectAtIndex:indexPath.row]);
        }
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        SOSQSCollectionReusableHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerId forIndexPath:indexPath];
       
        if (self.groupName) {
            headerView.titleLabel.text = [self.groupName objectAtIndex:indexPath.section];
        }else{
            headerView.titleLabel.text = @"组名称";
        }
        
        return headerView;
    }else{
        return nil;
//        SOSQSCollectionReusableFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footerId forIndexPath:indexPath];
//        return footerView;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGFloat height = 40;
    if (0 == [[self.allqsArray objectAtIndex:section] count]) {
        height = 0;
    }
   
    return CGSizeMake(SCREEN_WIDTH, height);
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
//    return CGSizeMake(SCREEN_WIDTH, 0.5);
//}

//已选择qs点击删除
- (void)deleteFromSelectQSWithDeleteApp:(SOSQSCollectionViewCell *)deleteApp event:(id)event{
    // 获取点击button的位置
    if (self.selectqsCollectionView.selectqsArray.count <= self.minKeepNumber){
        [Util showInfoHUDWithStatus:[NSString stringWithFormat:@"最少添加%ld个应用",self.minKeepNumber]];
        
    }else{
        NSSet *touches = [event allTouches];
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self.selectqsCollectionView.collectionView];
        NSIndexPath *indexPath = [self.selectqsCollectionView.collectionView indexPathForItemAtPoint:currentPoint];
        if (indexPath == nil) return;
        [self.selectqsCollectionView.collectionView performBatchUpdates:^{
            [self.selectqsCollectionView.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            [self.selectqsCollectionView.selectqsArray removeObjectAtIndex:indexPath.row];
        } completion:^(BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.selectqsCollectionView.collectionView reloadData];
                [self.allqsCollectionView reloadData];
                [UIView animateWithDuration:0.3 animations:^{
                    [self updateAllAreaFrame];
                }];
            });
        }];
    }
}

// 全量qs点击+添加
- (void)addFromAllQSWithCell:(SOSQSCollectionViewCell *)deleteApp event:(id)event{
    if (self.selectqsCollectionView.selectqsArray.count >= self.maxKeepNumber){
        [Util showInfoHUDWithStatus:[NSString stringWithFormat:@"最多添加%ld个应用",self.maxKeepNumber]];
    }else{
        NSSet *touches = [event allTouches];
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self.allqsCollectionView];
        NSIndexPath *indexPath = [self.allqsCollectionView indexPathForItemAtPoint:currentPoint];
        [self.selectqsCollectionView.selectqsArray addObject:[self.allqsArray[indexPath.section] objectAtIndex:indexPath.row]];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.selectqsCollectionView.selectqsArray.count - 1 inSection:0];
        [self.selectqsCollectionView.collectionView performBatchUpdates:^{
            [self.selectqsCollectionView.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
        } completion:^(BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.selectqsCollectionView.collectionView reloadData];
                [self.allqsCollectionView reloadData];
                [UIView animateWithDuration:0.3 animations:^{
                    [self updateAllAreaFrame];
                }];
            });
        }];
    }
}
// 全量qs点击-删除
- (void)deleteFromAllQSWithCell:(SOSQSCollectionViewCell *)deleteApp event:(id)event{
    // 获取点击button的位置
    if (self.selectqsCollectionView.selectqsArray.count <= self.minKeepNumber){
        [Util showInfoHUDWithStatus:[NSString stringWithFormat:@"最少添加%ld个应用",self.minKeepNumber]];
        
    }else{
        NSSet *touches = [event allTouches];
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self.allqsCollectionView];
        NSIndexPath *indexPath = [self.allqsCollectionView indexPathForItemAtPoint:currentPoint];
        if (indexPath == nil) return;
        NSInteger locationInSelect = [self.selectqsCollectionView.selectqsArray indexOfObject:[self.allqsArray[indexPath.section] objectAtIndex:indexPath.row]];
        NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:locationInSelect inSection:0];
        
        [self.selectqsCollectionView.collectionView performBatchUpdates:^{
            [self.selectqsCollectionView.collectionView deleteItemsAtIndexPaths:@[deleteIndexPath]];
            [self.selectqsCollectionView.selectqsArray removeObjectAtIndex:deleteIndexPath.row];
        } completion:^(BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.selectqsCollectionView.collectionView reloadData];
                [self.allqsCollectionView reloadData];
                [UIView animateWithDuration:0.3 animations:^{
                    [self updateAllAreaFrame];
                }];
            });
        }];
    }
}

-(void)didClickSelectQSItem:(id<SOSQSModelProtol>)modelItem{
    if (self.cellClickBlock) {
        SOSWeakSelf(weakSelf);
        weakSelf.cellClickBlock(modelItem);
    }
}
//已选择qs交互位置
- (void)exchangeSelectQSWithDragChangeItem:(SOSSelectQuickStartView *)Item index:(NSIndexPath *)index toIndexPath:(NSIndexPath *)toIndexPath{
    BOOL canChange = self.selectqsCollectionView.selectqsArray.count > index.item && self.selectqsCollectionView.selectqsArray.count > toIndexPath.item;
    if (canChange) {
        [self handleDatasourceExchangeWithSourceIndexPath:index destinationIndexPath:toIndexPath];
    }
}

- (void)handleDatasourceExchangeWithSourceIndexPath:(NSIndexPath *)sourceIndexPath destinationIndexPath:(NSIndexPath *)destinationIndexPath{
    
    NSMutableArray *tempArr = [self.selectqsCollectionView.selectqsArray mutableCopy];
    
    NSInteger activeRange = destinationIndexPath.item - sourceIndexPath.item;
    BOOL moveForward = activeRange > 0;
    NSInteger originIndex = 0;
    NSInteger targetIndex = 0;
    
    for (NSInteger i = 1; i <= labs(activeRange); i ++) {
        
        NSInteger moveDirection = moveForward?1:-1;
        originIndex = sourceIndexPath.item + i*moveDirection;
        targetIndex = originIndex  - 1*moveDirection;
        
        [tempArr exchangeObjectAtIndex:originIndex withObjectAtIndex:targetIndex];
    }
    self.selectqsCollectionView.selectqsArray = [tempArr mutableCopy];
    self.selectqsArray = self.selectqsCollectionView.selectqsArray;
}

#pragma mark - layoutDelegate

- (void)didChangeEditState:(BOOL)inEditState{
    self.inEditState = inEditState;
    [self.allqsCollectionView reloadData];
    //    for (SOSQSCollectionViewCell *cell in self.allqsCollectionView.visibleCells) {
    //        cell.inEditState = inEditState;
    //    }
}

- (void)dealloc {
    NSLog(@"%@ has dealloc", self.className);
}

@end
