//
//  main.m
//  Onstar
//
//  Created by Alfred Jin on 1/4/11.
//  Copyright 2011 plenware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import <dlfcn.h>
#import "AppPreferences.h"

// 定义一个函数指针用来接收动态加载出来的函数 ptrace
typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);

#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif

void DenyAppAttach() {
    
    // 动态加载并链接指定的库
    // 第一个参数 path 为 0 时, 它会自动查找 $LD_LIBRARY_PATH,$DYLD_LIBRARY_PATH, $DYLD_FALLBACK_LIBRARY_PATH 和 当前工作目录中的动态链接库.
    void * handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    
    // 动态加载 ptrace 函数，ptrace 函数的参数个数和类型，及返回类型跟 ptrace_ptr_t 函数指针定义的是一样的
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    
    // 执行 ptrace_ptr 相当于执行 ptrace 函数
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    
    // 关闭动态库，并且卸载
    dlclose(handle);
}

int main(int argc, char * argv[]) {

#ifndef DEBUG
    DenyAppAttach();
#endif
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate_iPhone class]));
    }
}

//int main(int argc, char *argv[]) {
//    @autoreleasepool {
//        int retVal = UIApplicationMain(argc, argv, nil, nil);
//        return retVal;

//    }
//}
