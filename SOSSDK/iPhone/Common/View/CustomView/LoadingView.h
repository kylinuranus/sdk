//
//  LoadingView.h
//  Onstar
//
//  Created by Joshua on 7/2/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface LoadingView : UIViewController

@property (nonatomic, assign) CGFloat offset;



+ (LoadingView *)sharedInstance;
- (void)startIn:(UIView *)view;
- (void)startIn:(UIView *)view withNavigationBar:(BOOL)showNavBar;
- (void)stop;
@end
