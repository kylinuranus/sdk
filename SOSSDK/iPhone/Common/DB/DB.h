//
//  OpenDB.h
//  HNMeeting
//
//  Created by 毛 炜 on 12-5-22.
//  Copyright (c) 2012年 派吉事. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DB : NSObject{

    
}

+ (sqlite3 *)openDB;//打开数据库
+ (void)closeDB;//关闭数据库


@end
