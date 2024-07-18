//
//  SOSAMapSearchTool.h
//  Onstar
//
//  Created by Coir on 2019/4/24.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSAMapSearchTool : NSObject

+ (instancetype)sharedInstance;

/// 获取 AMapID
- (void)getAMapIDWithPOI:(SOSPOI *)poi Success:(void (^)(NSString * aMapID))success Failure:(void (^)(void))failure;

/// 获取 收藏状态, 已收藏时, 收藏ID不为空,否则为 nil
- (void)getCollectionStateWithPOI:(SOSPOI *)poi Success:(void (^)(SOSPOICollectionState state, NSString *destinationID))success Failure:(void (^)(void))failure;

/// 周边检索
- (void)aroungSearchWithKeyWords:(NSString *)keyWords CenterPOI:(SOSPOI *)centerPOI PageNum:(int)pageNum Success:(void (^)(NSArray <SOSPOI *> * poiArray))success Failure:(void (^)(void))failure;

- (void)reGeoSearchWithLon:(double)lon lat:(double)lat Success:(void (^)(NSArray <SOSPOI *> * poiArray))success Failure:(void (^)(void))failure;

@end

NS_ASSUME_NONNULL_END
