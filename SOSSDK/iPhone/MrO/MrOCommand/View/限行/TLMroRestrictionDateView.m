//
//  TLMroRestrictionDateView.m
//  Onstar
//
//  Created by TaoLiang on 2017/11/22.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "TLMroRestrictionDateView.h"
#import "TLMroDateCollectionViewCell.h"
#import "SOSDateFormatter.h"

@interface TLMroRestrictionDateView ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
//@property (strong, nonatomic) NSArray <NSDate *>*totalDateArray;


@end

@implementation TLMroRestrictionDateView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self configureUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configureUI];
    }
    return self;
}

- (void)setShowDateArray:(NSArray<NSDate *> *)showDateArray {
    _showDateArray = showDateArray;
    [_collectionView reloadData];
}

- (void)setSelectIndex:(NSUInteger)selectIndex {
    _selectIndex = selectIndex;
    [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:_selectIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)configureUI {
    _showDateArray = @[].mutableCopy;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGFloat width = ( SCREEN_WIDTH - 40 ) / 7;
    layout.itemSize = CGSizeMake(MAX(width, 40), 50);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([TLMroDateCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([TLMroDateCollectionViewCell class])];
    [self addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self);
    }];
    
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
}

#pragma mark - collection data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _showDateArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TLMroDateCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TLMroDateCollectionViewCell class]) forIndexPath:indexPath];
    cell.dateString = [[SOSDateFormatter sharedInstance] style2_stringFromDate:_showDateArray[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectIndex = indexPath.row;
    if (_selectedBlock) {
        _selectedBlock(_selectIndex, _showDateArray[indexPath.row]);
    }
}


@end
