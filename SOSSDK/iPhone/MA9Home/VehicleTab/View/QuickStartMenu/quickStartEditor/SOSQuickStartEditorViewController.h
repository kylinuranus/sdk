//
//  SOSQuickStartEditorViewController.h
//  Onstar
//
//  Created by Onstar on 2019/1/10.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSQSModelProtol.h"
NS_ASSUME_NONNULL_BEGIN

@class SOSQuickStartEditorViewController;
@protocol SOSQuickStarteditCompleteDelegate <NSObject>
@optional
- (void)editCompleteWithSelectQS:(NSMutableArray<SOSQSModelProtol> *)selectqsArray andAllqsArray:(NSMutableArray *)allqsArray;

@end

typedef void (^SOSQuickStartCellClickBlock)(id<SOSQSModelProtol> modelItem);

@interface SOSQuickStartEditorViewController : UIViewController

/**
 Caution!!!
 全量表需要包含选择表,但是可以有不同对象,如果对象有ID属性,则根据ID替换成同一个对象,如果没有ID,判断title是否一样替换
 @param selectqsArray 已经选择的qs array
 @param allqsArray 全量qs array
 @param groupName 全量表组名称
 @return check    对象唯一检查替换
 */
- (instancetype)initWithSelectqsArray:(NSMutableArray<id<SOSQSModelProtol>> *)selectqsArray allqsArray:(NSMutableArray<NSMutableArray<id<SOSQSModelProtol>> *> *)allqsArray groupNameArray:(NSArray<NSString *> *)groupName needUniqueCheck:(BOOL)check;
@property (nonatomic, weak) id<SOSQuickStarteditCompleteDelegate> delegate;
@property (nonatomic, assign) NSInteger minKeepNumber;                             //最少保留数
@property (nonatomic, assign) NSInteger maxKeepNumber;                             //最多保留数
@property (nonatomic, copy) NSString * navTitle;    //title
@property (nonatomic, copy) NSString * editNavTitle;//title when edit
@property (nonatomic, copy) SOSQuickStartCellClickBlock cellClickBlock;
//Daap
@property (nonatomic, copy) NSString * backFunctionID;
@property (nonatomic, copy) NSString * editFunctionID;
@property (nonatomic, copy) NSString * saveFunctionID;
@property (nonatomic, copy) NSString * cancelFunctionID;

@end
NS_ASSUME_NONNULL_END
