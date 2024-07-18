//
//  ContentUtil.h
//  Onstar
//
//  Created by Vicky on 16/7/20.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseDataObject.h"

@interface ContentUtil : NSObject

+ (void)getContentByCategory:(NSString *)category Success:(void (^)(NNContentHeaderCatogry *content))completion Failed:(void (^)(void))failCompletion;


+ (void)getContentDetailByCategory:(NSString *)category num:(NSString *)number Success:(void (^)(NNContentDeatil *contentDetail))completion Failed:(void (^)(void))failCompletion;

@end
