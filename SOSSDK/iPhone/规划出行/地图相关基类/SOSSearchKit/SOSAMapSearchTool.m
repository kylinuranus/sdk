//
//  SOSAMapSearchTool.m
//  Onstar
//
//  Created by Coir on 2019/4/24.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "CollectionToolsOBJ.h"
#import "SOSAMapSearchTool.h"
#import "BaseSearchOBJ.h"

typedef void(^GetAMapIDSuccessBlock)(NSString * aMapID);
typedef void(^GetCollectionStateSuccessBlock)(SOSPOICollectionState state, NSString *destinationID);
typedef void(^POISearchSuccessBlock)(NSArray <SOSPOI *>* poiArray);
typedef void(^FailureBlock)(void);

@interface SOSAMapSearchTool () <PoiDelegate, GeoDelegate, ErrorDelegate>

// 获取 AmapID
@property (copy, nonatomic, nullable) GetAMapIDSuccessBlock getIDSuccessBlock;
@property (copy, nonatomic, nullable) GetCollectionStateSuccessBlock getStatesSuccessBlock;
// 逆地理编码搜索
@property (copy, nonatomic, nullable) POISearchSuccessBlock reGeoSuccessBlock;
// POI 搜索
@property (copy, nonatomic, nullable) POISearchSuccessBlock poiSearchSuccessBlock;
@property (copy, nonatomic, nullable) FailureBlock failureBlock;


@property (strong, nonatomic) BaseSearchOBJ *searchOBJ;

@end

@implementation SOSAMapSearchTool

+ (id)sharedInstance     {
    static id sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [self new];
    });
    return sharedOBJ;
}

- (void)aroungSearchWithKeyWords:(NSString *)keyWords CenterPOI:(SOSPOI *)centerPOI PageNum:(int)pageNum Success:(void (^)(NSArray <SOSPOI *> * poiArray))success Failure:(void (^)(void))failure 		{
    AMapGeoPoint *location = [AMapGeoPoint locationWithLatitude:centerPOI.latitude.floatValue longitude:centerPOI.longitude.floatValue];
    BasePoiSearchConfiguration *poiSearchConfig = [BasePoiSearchConfiguration new];
    //确定搜索类别
    poiSearchConfig.requireExtension = YES;
    poiSearchConfig.page = pageNum;
    poiSearchConfig.offset = 20;
    self.searchOBJ.poiSearchConfig = poiSearchConfig;
    [self.searchOBJ aroundSearchWithKeyWords:keyWords Location:location Radius:50000];
    self.poiSearchSuccessBlock = success;
    self.failureBlock = failure;
    self.searchOBJ.poiSearchConfig = nil;
}

- (void)getAMapIDWithPOI:(SOSPOI *)poi Success:(void (^)(NSString * aMapID))success Failure:(void (^)(void))failure	{
    if (poi.pguid.length) {
        success(poi.pguid);
    }	else	{
        [self.searchOBJ reGeoCodeSearchWithPOI:poi];
        self.getIDSuccessBlock = success;
        self.failureBlock = failure;
    }
}

- (void)getCollectionStateWithPOI:(SOSPOI *)poi Success:(void (^)(SOSPOICollectionState state, NSString *destinationID))success Failure:(void (^)(void))failure	{
    if (poi.collectionState != SOSPOICollectionState_Non) {
        success(poi.collectionState, poi.destinationID);
        return;
    }
    if (poi.pguid.length == 0) {
        // 若无 POI 的 uid 信息,先进行逆地理编码获取,然后获取收藏状态
        [self.searchOBJ reGeoCodeSearchWithPOI:poi];
        self.getStatesSuccessBlock = success;
        self.failureBlock = failure;
    }    else    {
        [CollectionToolsOBJ getCollectionStateWithAmapID:poi.pguid Success:^(bool isCollected, NSString *destinationID) {
            if (success) success(isCollected ? SOSPOICollectionState_Collected : SOSPOICollectionState_Not_Collected, destinationID);
        } Failure:^{
            if (failure) failure();
        }];
    }
}

- (void)reGeoSearchWithLon:(double)lon lat:(double)lat Success:(void (^)(NSArray<SOSPOI *> * _Nonnull))success Failure:(void (^)(void))failure	{
    [self.searchOBJ reGeoCodeSearchWithLocation:[AMapGeoPoint locationWithLatitude:lat longitude:lon]];
    self.reGeoSuccessBlock = success;
    self.failureBlock = failure;
}

- (BaseSearchOBJ *)searchOBJ    {
    if (_searchOBJ == nil) {
        _searchOBJ = [BaseSearchOBJ new];
        _searchOBJ.poiDelegate = self;
        _searchOBJ.geoDelegate = self;
        _searchOBJ.errorDelegate = self;
    }
    return _searchOBJ;
}

#pragma mark - Search Delegate

- (void)poiSearchResult:(SOSPoiSearchResult *)results	{
    if (self.poiSearchSuccessBlock) {
        self.poiSearchSuccessBlock(results.pois);
        self.poiSearchSuccessBlock = nil;
    }
}

- (void)reverseGeocodingResults:(NSArray *)results    {
    if (results.count) {
        SOSPOI *poi = results[0];
        if (self.getIDSuccessBlock)		{
            self.getIDSuccessBlock(poi.pguid);
            self.getIDSuccessBlock = nil;
            return;
        }
        if (self.reGeoSuccessBlock) {
            self.reGeoSuccessBlock(results);
            self.reGeoSuccessBlock = nil;
        }	else if (self.getStatesSuccessBlock) {
            [CollectionToolsOBJ getCollectionStateWithAmapID:poi.pguid Success:^(bool isCollected, NSString *destinationID) {
                self.getStatesSuccessBlock(isCollected ? SOSPOICollectionState_Collected : SOSPOICollectionState_Not_Collected, destinationID);
                self.getStatesSuccessBlock = nil;
            } Failure:^{
                self.failureBlock();
                self.failureBlock = nil;
            }];
        }
    }    else    {
        if (self.failureBlock) {
            self.failureBlock();
            self.failureBlock = nil;
        }
    }
}

// Search Erorr Delegate
- (void)baseSearch:(id)searchOption Error:(NSString*)errCode    {
    if (self.failureBlock) {
        self.failureBlock();
        self.failureBlock = nil;
    }
}


@end
