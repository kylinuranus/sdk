//
//  AssociateTips.m
//  Onstar
//
//  Created by Coir on 16/2/15.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "AssociateTips.h"

@interface AssociateTips ()   <AMapSearchDelegate>      {
    AMapSearchAPI *searchOBJ;
}

@end

@implementation AssociateTips

- (void)searchWithKeyWords:(NSString *)keyWords AndCityName:(NSString *)cityName {
    //初始化检索对象
    searchOBJ = [[AMapSearchAPI alloc] init];
    searchOBJ.delegate = self;
    
    //构造AMapInputTipsSearchRequest对象，设置请求参数
    AMapInputTipsSearchRequest *tipsRequest = [[AMapInputTipsSearchRequest alloc] init];
    tipsRequest.keywords = keyWords;
    tipsRequest.city = cityName.length ? cityName : @"";
    
    //发起输入提示搜索
    [searchOBJ AMapInputTipsSearch: tipsRequest];
}

///实现输入提示的回调函数
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest*)request response:(AMapInputTipsSearchResponse *)response     {
    if(response.count == 0) {
        return;
    }
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:response.tips];
    for (AMapTip *tip in response.tips) {
        if (!(tip.location.longitude && tip.location.latitude)) {
            [tempArray removeObject:tip];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(associateSearchDoneWithKeyWords:Results:)]) {
        [self.delegate associateSearchDoneWithKeyWords:request.keywords Results:tempArray];
    }
}

@end
