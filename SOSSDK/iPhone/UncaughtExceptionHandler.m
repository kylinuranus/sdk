//
//  UncaughtExceptionHandler.m
//  SOSSDKDemo_Example
//
//  Created by 梁元 on 2022/3/30.
//  Copyright © 2022 com.onstar. All rights reserved.
//

#import "UncaughtExceptionHandler.h"
#import <UIKit/UIKit.h>
 

 
#include <libkern/OSAtomic.h>
#include <execinfo.h>

//NSException错误名称
NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
//signal错误堆栈的条数
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
//错误堆栈信息
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";
//初始化的错误条数
volatile int32_t UncaughtExceptionCount = 0;
//错误最大的条数
const int32_t UncaughtExceptionMaximum = 10;
///是否弹窗提示
static BOOL showAlertView = nil;

//异常处理
void HandleException(NSException *exception);
//Signal类型错误信号处理
void SignalHandler(int signal);
//获取app信息
NSString* getAppInfo(void);

@interface UncaughtExceptionHandler()
///判断程序是否继续执行
@property (assign, nonatomic) BOOL dismissed;

@end

@implementation UncaughtExceptionHandler

/*!
 *  1、异常的处理方法
 *
 *  @param install   是否开启捕获异常
 *  @param showAlert 是否在发生异常时弹出alertView
 */
+ (void)installUncaughtExceptionHandler:(BOOL)install showAlert:(BOOL)showAlert {

    if (install && showAlert) {
        [[self alloc] alertView:showAlert];
    }
    NSSetUncaughtExceptionHandler(install ? HandleException : NULL);
    signal(SIGABRT, install ? SignalHandler : SIG_DFL);
    signal(SIGILL, install ? SignalHandler : SIG_DFL);
    signal(SIGSEGV, install ? SignalHandler : SIG_DFL);
    signal(SIGFPE, install ? SignalHandler : SIG_DFL);
    signal(SIGBUS, install ? SignalHandler : SIG_DFL);
    signal(SIGPIPE, install ? SignalHandler : SIG_DFL);
}

///设置是否弹窗提示
- (void)alertView:(BOOL)show {
    showAlertView = show;
}



#pragma mark - methond

//med 1、专门针对Signal类型的错误获取堆栈信息
+ (NSArray *)backtrace {

    //指针列表
    void* callstack[128];
    //backtrace用来获取当前线程的调用堆栈，获取的信息存放在这里的callstack中
    //128用来指定当前的buffer中可以保存多少个void*元素
    //返回值是实际获取的指针个数
    int frames = backtrace(callstack, 128);
    //backtrace_symbols将从backtrace函数获取的信息转化为一个字符串数组
    //返回一个指向字符串数组的指针
    //每个字符串包含了一个相对于callstack中对应元素的可打印信息，包括函数名、偏移地址、实际返回地址
    char **strs = backtrace_symbols(callstack, frames);

    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = 0; i < frames; i++) {

        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);

    return backtrace;
}

//med 2、所有错误异常处理
- (void)handleException:(NSException *)exception {
    //验证和保存错误数据
    [self validateAndSaveCriticalApplicationData:exception];

    ///错误弹窗提示设置
    if (!showAlertView) {
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIAlertView *alert =
    [[UIAlertView alloc]
     initWithTitle:@"出错啦"
     message:[NSString stringWithFormat:@"你可以尝试继续操作，但是应用可能无法正常运行.\n"]
     delegate:self
     cancelButtonTitle:@"退出"
     otherButtonTitles:@"继续", nil];
    [alert show];
#pragma clang diagnostic pop

    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);

    while (!self.dismissed) {
        //点击继续
        for (NSString *mode in (__bridge NSArray *)allModes) {
            //快速切换Mode
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }

    //点击退出
    CFRelease(allModes);

    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);

    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]) {
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    } else {
        [exception raise];
    }
}

//点击退出
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex {
#pragma clang diagnostic pop

    if (anIndex == 0) {
        self.dismissed = YES;
    }
}


//验证和保存错误数据
- (void)validateAndSaveCriticalApplicationData:(NSException *)exception {

    NSString *exceptionInfo = [NSString stringWithFormat:@"\n--------Log Exception---------\nappInfo             :\n%@\n\nexception name      :%@\nexception reason    :%@\nexception userInfo  :%@\ncallStackSymbols    :%@\n\n--------End Log Exception-----", getAppInfo(),exception.name, exception.reason, exception.userInfo ? : @"no user info", [exception callStackSymbols]];

    NSLog(@"%@", exceptionInfo);
    ///写入文件
//    [exceptionInfo writeToFile:[NSString stringWithFormat:@"%@/Documents/error.log",NSHomeDirectory()]  atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end


///2.1、奔溃异常处理
void HandleException(NSException *exception) {

    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    // 如果太多不用处理
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }

    //获取调用堆栈
    NSArray *callStack = [exception callStackSymbols];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];

    //在主线程中，执行制定的方法, withObject是执行方法传入的参数
    [[[UncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException exceptionWithName:[exception name]
                             reason:[exception reason]
                           userInfo:userInfo]
     waitUntilDone:YES];
}

//2.2、signal报错处理
void SignalHandler(int signal) {

    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    // 如果太多不用处理
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }

    NSString* description = nil;
    switch (signal) {
        case SIGABRT:
            description = [NSString stringWithFormat:@"Signal SIGABRT was raised!\n"];
            break;
        case SIGILL:
            description = [NSString stringWithFormat:@"Signal SIGILL was raised!\n"];
            break;
        case SIGSEGV:
            description = [NSString stringWithFormat:@"Signal SIGSEGV was raised!\n"];
            break;
        case SIGFPE:
            description = [NSString stringWithFormat:@"Signal SIGFPE was raised!\n"];
            break;
        case SIGBUS:
            description = [NSString stringWithFormat:@"Signal SIGBUS was raised!\n"];
            break;
        case SIGPIPE:
            description = [NSString stringWithFormat:@"Signal SIGPIPE was raised!\n"];
            break;
        default:
            description = [NSString stringWithFormat:@"Signal %d was raised!",signal];
    }

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSArray *callStack = [UncaughtExceptionHandler backtrace];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    [userInfo setObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];

    //在主线程中，执行指定的方法, withObject是执行方法传入的参数
    [[[UncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                             reason: description
                           userInfo: userInfo]
     waitUntilDone:YES];
}


///获取app信息
NSString* getAppInfo() {

    NSString *appInfo = [NSString stringWithFormat:@"App : %@ %@(%@)\nDevice : %@\nOS Version : %@ %@\n",
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                         [UIDevice currentDevice].model,
                         [UIDevice currentDevice].systemName,
                         [UIDevice currentDevice].systemVersion];
    return appInfo;
}

