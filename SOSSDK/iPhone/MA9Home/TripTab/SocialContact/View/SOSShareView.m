//
//  SOSShareView.m
//  Onstar
//
//  Created by Onstar on 2020/1/19.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import "SOSShareView.h"
#import "SOSShareCollectionViewCell.h"

@implementation SOSShareView

- (instancetype)initWithFrame:(CGRect)frame andSource:(NSArray *)source
{
    self = [super initWithFrame:frame];
    if (self) {
        self.shareSource = source;
        [self initView];
        
    }
    return self;
}
-(void)initView{
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).mas_offset(10);
    }];
}
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat layoutWidth = 70.0f;
        layout.itemSize = CGSizeMake(layoutWidth, layoutWidth);
        // 行间距
        layout.minimumLineSpacing = 14;
        // 列间距
//        layout.minimumInteritemSpacing = 3;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
//        _collectionView.alwaysBounceVertical = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[SOSShareCollectionViewCell class] forCellWithReuseIdentifier:@"SOSShareCollectionViewCell"];
//        if (@available(iOS 11.0, *)) {
//            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        } else {
//            self.automaticallyAdjustsScrollViewInsets = NO;
//        }
//        __weak typeof(self) _self = self;
    }
    return _collectionView;
}

#pragma mark - Delegate
#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.shareSource.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SOSShareCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SOSShareCollectionViewCell" forIndexPath:indexPath];
    [cell setShareIconWithDic:[self.shareSource objectAtIndex:indexPath.row]];
    return cell;
}
#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (_shareTapCallback) {
        _shareTapCallback([self.shareSource objectAtIndex:indexPath.row]);
    }
}

///////////////

@end
