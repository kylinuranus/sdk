//
//  SOSPoiHistoryDataBase.h
//  Onstar
//
//  Created by TaoLiang on 2019/4/16.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, HistoryPoiType) {
    HistoryPoiTypeSearch = 0,
    HistoryPoiTypeDestination,
    HistoryPoiTypeSendToVehicle,
};



@interface SOSPoiHistoryDataBase : NSObject
+ (instancetype)sharedInstance;

- (void)insert:(SOSPOI *)poi;

- (void)updateOldVersionPoi:(SOSPOI *)poi;
//获取数据，拉取前20条
- (void)fetch:(void (^)(NSArray<SOSPOI *> *array))results;

- (BOOL)deleteAll;

- (void)deletePOI:(SOSPOI *)poi;

- (void)transferOldDataIfNeeded;
@end

NS_ASSUME_NONNULL_END
