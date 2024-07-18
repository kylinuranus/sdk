//
//  SOSMsgActivityView.m
//  Onstar
//
//  Created by WQ on 2018/5/23.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSMsgActivityView.h"
#import "SOSMsgActivityCell.h"
#import "SOSMsgHotActivityHead.h"

@interface SOSMsgActivityView () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation SOSMsgActivityView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self creatData];
        [self initUI];
    }
    return self;
}

-(void)initUI
{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //预估高度
    layout.estimatedItemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 200);
    layout.minimumLineSpacing = 1;
    CGRect r = CGRectMake(0, 0, self.frame.size.width,603);
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self addSubview:self.collectionView];
    [self.collectionView registerClass:[SOSMsgActivityCell class] forCellWithReuseIdentifier:@"LastCell"];
    [self.collectionView registerClass:[SOSMsgHotActivityHead class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"head"];

}


- (void)creatData{
    self.dataArray = @[@"测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试",@"测试",@"测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试",@"测试"];
    
    
}


#pragma mark=========================== UICollectionViewDataSource 代理方法====================================

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{

    return CGSizeMake(0, 45);
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"viewForSupplementaryElementOfKind------");
    static NSString *reuseIdentifier = @"head";

    SOSMsgHotActivityHead *view =  [collectionView dequeueReusableSupplementaryViewOfKind :kind   withReuseIdentifier:reuseIdentifier   forIndexPath:indexPath];
    return view;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SOSMsgActivityCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LastCell" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    [cell fillData:self.dataArray[indexPath.row]];
    cell.onPress = ^(NSInteger tag) {
        NSLog(@"cell on press=======");
    };
    return cell;
}


@end
