//
//  SOSShareView.h
//  Onstar
//
//  Created by Onstar on 2020/1/19.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSShareView : UIView<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) NSArray *shareSource;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) void(^shareTapCallback)(NSDictionary *clickItem);

- (instancetype)initWithFrame:(CGRect)frame andSource:(NSArray *)source;
@end

NS_ASSUME_NONNULL_END
