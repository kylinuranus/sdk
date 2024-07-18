//
//  SOSAgreementEntranceBaseView.m
//  Onstar
//
//  Created by TaoLiang on 14/05/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSAgreementEntranceBaseView.h"

@implementation SOSAgreementEntranceBaseView

- (NSArray<NSValue *> *)getRangesForAgreement:(NSString *)agreement {
    
    NSString *temp;
    NSMutableArray<NSNumber *> *leftBrackets = @[].mutableCopy;
    NSMutableArray<NSNumber *> *rightBrackets = @[].mutableCopy;
    for (int i=0; i<agreement.length; i++) {
        temp = [agreement substringWithRange:NSMakeRange(i, 1)];
        if ([temp isEqualToString:@"《"]) {
            [leftBrackets addObject:@(i)];
        }else if ([temp isEqualToString:@"》"]) {
            [rightBrackets addObject:@(i)];
        }
    }
    
    NSAssert(leftBrackets.count == rightBrackets.count, @"格式错误,左右书名号数量应该相等");
    
    NSMutableArray<NSValue *> *ranges = @[].mutableCopy;
    
    [leftBrackets enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger leftBracketIndex = obj.integerValue;
        NSInteger rightBracketIndex = rightBrackets[idx].integerValue;
        NSRange range = NSMakeRange(leftBracketIndex, rightBracketIndex - obj.integerValue + 1);
        [ranges addObject:[NSValue valueWithRange:range]];
    }];
    return ranges;
}

@end
