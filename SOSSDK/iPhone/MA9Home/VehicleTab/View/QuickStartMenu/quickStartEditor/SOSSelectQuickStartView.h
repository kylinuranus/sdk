//
//  SOSSelectQuickStartView.h
//  Onstar
//
//  Created by Onstar on 2019/1/11.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSQSCollectionViewLayout.h"
NS_ASSUME_NONNULL_BEGIN
@class SOSSelectQuickStartView;
@protocol SOSSelectQuickStartViewDelegate <NSObject>
@optional
//删除
- (void)deleteFromSelectQSWithDeleteApp:(SOSSelectQuickStartView *)deleteApp event:(id)event;
//交互位置
- (void)exchangeSelectQSWithDragChangeItem:(SOSSelectQuickStartView *)Item index:(NSIndexPath *)index toIndexPath:(NSIndexPath *)toIndexPath;

-(void)didClickSelectQSItem:(id<SOSQSModelProtol>)modelItem;
@end
@interface SOSSelectQuickStartView : UIView
@property (weak, nonatomic) id<SOSSelectQuickStartViewDelegate>delegate;
@property (strong, nonatomic) NSMutableArray *selectqsArray;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) SOSQSCollectionViewLayout *layout;
//@property (weak, nonatomic) IBOutlet UIView *coverViews;
-(void)showTips;
-(void)hideTips;

//- (void)reloadData:(SOSRemoteOperationType)opeType opeStatus:(RemoteControlStatus)controlStatus;

@end
NS_ASSUME_NONNULL_END
