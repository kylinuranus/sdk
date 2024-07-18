//
//  PreferDealerRequestClient.h
//  Onstar
//
//  Created by Joshua on 6/25/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseDataObject.h"

@protocol PreferDealerRequestClientDelegate <NSObject>

- (void)requestDataFinished:(NSString *)responseStr;

@end

///这个类看起来是用于首选经销商请求
@interface PreferDealerRequestClient : NSObject
@property (nonatomic, weak) NNPreferDealerDataResponse *myPreferDealerResponse;
@property (nonatomic ,weak) id <PreferDealerRequestClientDelegate>delegate;

- (void)getPreferredDealer;
- (void)getPreferredDealer:(id)httpDelegate;
- (void)getPreferredDealer:(id)httpDelegate sospoi:(SOSPOI *)poi;


@end
