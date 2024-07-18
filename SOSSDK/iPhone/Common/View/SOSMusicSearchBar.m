//
//  SOSMusicSearchBar.m
//  Onstar
//
//  Created by TaoLiang on 2018/3/15.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSMusicSearchBar.h"

@implementation SOSMusicSearchBar

- (UITextField *)textField {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000

    if (@available(iOS 13, *)) {
        return self.searchTextField;
    }
#endif
    UITextField *textField = [self valueForKey:@"_searchField"];
    return textField;
}

@end
