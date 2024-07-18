//
//  SOSQSCollectionViewCell.h
//  Onstar
//
//  Created by Onstar on 2019/1/11.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSQSModelProtol.h"
NS_ASSUME_NONNULL_BEGIN
@class SOSQSCollectionViewCell;
@protocol SOSQSCellDelegate <NSObject>
@optional
//selectqs删除操作
- (void)deleteFromSelectQSWithCell:(SOSQSCollectionViewCell *)deleteApp event:(id)event;
//全量qs添加操作
- (void)addFromAllQSWithCell:(SOSQSCollectionViewCell *)deleteApp event:(id)event;
//全量qs删除操作
- (void)deleteFromAllQSWithCell:(SOSQSCollectionViewCell *)deleteApp event:(id)event;
@end

@interface SOSQSCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) id<SOSQSCellDelegate>delegate;
@property (weak, nonatomic) IBOutlet UILabel *appTitle;
@property (weak, nonatomic) IBOutlet UIImageView *appIcon;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIButton *delegateApp;// 删除Btn
@property (nonatomic, strong) id<SOSQSModelProtol> model;
@property (nonatomic, assign) BOOL inEditState; //是否处于编辑状态
@property (nonatomic, assign) BOOL canDelete;  //是否是删除操作
@property (nonatomic,strong) UIImageView *loadingIcon;

- (void)setSelectqsArray:(NSMutableArray *)selectArray allqsArray:(NSMutableArray *)allArray indexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) UILabel *messageLabel;

- (void)shouldLoading:(BOOL)shouldLoading;

@end
NS_ASSUME_NONNULL_END
