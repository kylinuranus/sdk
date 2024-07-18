//
//  SOSForumShareView.h
//  Onstar
//
//  Created by TaoLiang on 2019/2/15.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSForumShareView : UIView

@property (strong, nonatomic) NSArray<NSDictionary *> *buttons;

@property(copy, nonatomic) void (^btnClicked)(NSUInteger, NSDictionary *);

@end

NS_ASSUME_NONNULL_END
