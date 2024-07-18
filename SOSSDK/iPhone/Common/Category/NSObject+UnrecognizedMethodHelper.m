//
//  NSObject+UnrecognizedMethodHelper.m
//  Onstar
//
//  Created by TaoLiang on 2019/4/11.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "NSObject+UnrecognizedMethodHelper.h"

@implementation NSObject (UnrecognizedMethodHelper)

+ (void)load {
    [self swizzleInstanceMethod:@selector(forwardingTargetForSelector:) with:@selector(sos_forwardingTargetForSelector:)];
}

- (id)sos_forwardingTargetForSelector:(SEL)aSelector {
    //非Onstar类名不管;
    if (![self.className hasPrefix:@"SOS"]) {
        return [self sos_forwardingTargetForSelector:aSelector];
    }
    NSString *selStr = NSStringFromSelector(aSelector);
    NSLog(@"GUARDIAN -[%@ %@]", self.className, selStr);
    NSLog(@"GUARDIAN: unrecognized selector \"%@\" sent to instance: %p", selStr, self);
    
    NSLog(@"GUARDIAN: call stack: %@", [NSThread callStackSymbols]);
    Class SOSSelForwardGuardian = NSClassFromString(@"SOSSelForwadingGuardian");
    if (!SOSSelForwardGuardian) {
        SOSSelForwardGuardian = objc_allocateClassPair(NSObject.class, "SOSSelForwadingGuardian", 0);
        objc_registerClassPair(SOSSelForwardGuardian);
    }
    class_addMethod(SOSSelForwardGuardian, aSelector, [self safeImplementation:aSelector], [selStr UTF8String]);
    id instance = [[SOSSelForwardGuardian alloc] init];
    
    return instance;
}

- (IMP)safeImplementation:(SEL)aSelector {
    IMP imp = imp_implementationWithBlock(^() {
        NSLog(@"GUARDIAN: %@ 已被SOSSelForwadingGuardian拦截", NSStringFromSelector(aSelector));
    });
    return imp;
}




@end
