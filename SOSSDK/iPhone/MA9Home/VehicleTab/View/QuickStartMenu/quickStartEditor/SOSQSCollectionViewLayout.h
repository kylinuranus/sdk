//
//  SOSQSCollectionViewLayout.h
//  Onstar
//
//  Created by Onstar on 2019/1/11.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@protocol SOSQSCollectionViewLayoutDelegate <NSObject>

// 改变编辑状态
- (void)didChangeEditState:(BOOL)inEditState;

@end
@interface SOSQSCollectionViewLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) BOOL inEditState; //检测是否处于编辑状态
@property (nonatomic, weak) id<SOSQSCollectionViewLayoutDelegate> delegate;
@end
NS_ASSUME_NONNULL_END
