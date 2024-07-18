//
//  CollectionToolsOBJ.h
//  Onstar
//
//  Created by Coir on 16/3/17.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KCollectionDataChangedNotification  	@"KCollectionDataChangedNotification"

@interface CollectionToolsOBJ : NSObject

+ (UIView *_Nonnull)getNoDataView;

+ (void)getCollectionStateWithAmapID:(NSString *)amapID Success:(void(^)(bool isCollected, NSString *destinationID))successBlock Failure:(void(^)(void))failureBlock;

+ (void)getCollectionListFromVC:(UIViewController *)vc Success:(void (^)(NSArray *resultArray))completion;

+ (void)addCollectionFromVC:(UIViewController *)vc WithPoi:(SOSPOI *)poi NickName:(NSString *)nickName  Success:(void(^)(NSString *destinationID))successBlock Failure:(void(^)(void))failureBlock;

+ (void)deleteCollectionWithDestinationID:(NSString *)destinationID;

+ (void)deleteCollectionWithDestinationID:(NSString *)destinationID Success:(void(^)(void))successBlock Failure:(void(^)(void))failureBlock;

+ (void)deleteCollectionWithDestinationID:(NSString *)destinationID NeedToast:(BOOL)needToast Success:(void(^)(void))successBlock Failure:(void(^)(void))failureBlock ;

+ (void)deleteAllColectionsSuccess:(void(^)(void))successBlock Failure:(void(^)(void))failureBlock;

+ (SOSPOI *)handleCollectionResultDic:(NSDictionary *)collectionDic;

+ (void)getHomeAndCompanyMessage;

@end
