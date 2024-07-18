//
//  SOSOnRemoteCollectionLayout.m
//  Onstar
//
//  Created by onstar on 2018/12/21.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSOnRemoteCollectionLayout.h"

@implementation SOSOnRemoteCollectionLayout


-(NSInteger)currentPageCount{
    NSInteger count1 = [self.collectionView numberOfItemsInSection:0];
    NSInteger count2 = [self.collectionView numberOfItemsInSection:1];
    // 计算一共多少页
    NSInteger pageCount = (count1>0?1:0) + (count2>0?1:0);
    return pageCount;
}

/**
 准备layout
 */
-(void)prepareLayout{
    // 清理数据源
    [self.layoutAttributes removeAllObjects];
    self.contentSize = CGSizeZero;
    // 预先计算好所有的 layout 属性
    // 预计算 contentSize
    // 先要拿到 到底有多少个 item
    NSInteger count1 = [self.collectionView numberOfItemsInSection:0];
    NSInteger count2 = [self.collectionView numberOfItemsInSection:1];
//    NSInteger maxCountPerPage = [self maxNumberOfItemsPerPage];
    
    // 计算一共多少页
    NSInteger pageCount = (count1>0?1:0) + (count2>0?1:0);
    
    //预计算了contengSize
    self.contentSize = CGSizeMake(pageCount * self.collectionView.frame.size.width, self.collectionView.frame.size.height);
    
    //计算每个cell的属性大小
    for (NSInteger i = 0; i < count1+count2; i ++) {
        //计算当前page 即section
        NSInteger currentPage = i>=count1?1:0;
        
        NSInteger row = (i-count1)<0?i:(i-count1);
        //创建索引
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:currentPage];
        //通过索引创建cell 布局属性
        // UICollectionViewLayoutAttributes 这个内部应该保存 cell 布局以及一些位置信息等等
        UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        //默认6个的布局
        CGFloat itemWidth = self.collectionView.frame.size.width/3;
        CGFloat itemHeight = self.collectionView.frame.size.height/2;

        
        CGFloat x = currentPage * self.collectionView.frame.size.width + row%3 * itemWidth;
        CGFloat y = row/3%2 * itemHeight;
    
//        if (currentPage + 1 == pageCount) {//最后一页
            //具体计算每个布局属性到底是多少
            //当前页
            //<=2个 w h
            //<=4个 w/2 h/2
            //>4个 w/3 h/2
            
            //最后一页itemNum
            NSInteger currentNum = currentPage==1?count2:count1;
            if (currentNum <= 2) {
                itemWidth = self.collectionView.frame.size.width/2;
                itemHeight = self.collectionView.frame.size.height;
                x = currentPage * self.collectionView.frame.size.width + row%2 * itemWidth;
                y = 0;
            }else if (currentNum <= 4) {
                itemWidth = self.collectionView.frame.size.width/2;
                itemHeight = self.collectionView.frame.size.height/2;
                x = currentPage * self.collectionView.frame.size.width + row%2 * itemWidth;
                 y = row/2%2 * itemHeight;
            }
//        }
        
        layoutAttribute.frame = CGRectMake(x, y, itemWidth, itemHeight);
        
        [self.layoutAttributes addObject:layoutAttribute];
    }
}


@end
