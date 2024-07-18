//
//  NSBundle+SOSBundle.m
//  Onstar
//
//  Created by onstar on 2018/1/10.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//
//
#import "NSBundle+SOSBundle.h"

@implementation NSBundle (SOSBundle)

+ (NSBundle *)SOSBundle {
    if(SOS_ONSTAR_PRODUCT) {
//        NSLog(@"bundle = %@",[NSBundle mainBundle]);
        return [NSBundle mainBundle];
    }
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"SOSSDK")];
//    NSLog(@"bundle = %@",bundle);
    NSString *path =  [bundle pathForResource:@"SOSSDK" ofType:@"bundle"];
//    NSLog(@"bundle = %@",path);
    bundle = [NSBundle bundleWithPath:path];
//    NSLog(@"bundle = %@",bundle);
    return bundle;
}

@end
