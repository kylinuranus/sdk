
//  LoadingView.m
//  Onstar
//
//  Created by Joshua on 7/2/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import "LoadingView.h"
#import "UIImage+GIF.h"
#import <SDWebImage/UIImage+MultiFormat.h>


@interface LoadingView ()
@property (nonatomic, strong) UIImageView *imageView_gif;
@end

@implementation LoadingView

static LoadingView *instance = nil;
+ (LoadingView *)sharedInstance {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [self new];
    });
    return instance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil     {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _offset = 0.0f;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSString *path = [[NSBundle SOSBundle] pathForResource:@"loading_gif" ofType:@"gif"];
    
    [self.view addSubview:self.imageView_gif];
    [self.imageView_gif mas_makeConstraints:^(MASConstraintMaker *make){
        make.center.equalTo(self.view);
        make.height.width.equalTo(self.view.mas_width);
//        make.width.mas_equalTo(340);
//        make.height.mas_equalTo(280);
    }];
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *image = [UIImage sd_imageWithData:data];
    self.imageView_gif.image = image;
    
}
- (WKWebViewConfiguration *)getWebViewConfignation    {
    WKWebViewConfiguration *configuretion = [[WKWebViewConfiguration alloc] init];
    configuretion.preferences.javaScriptEnabled = true;
    configuretion.userContentController = [[WKUserContentController alloc] init];

    return configuretion;
}

- (void)startIn:(UIView *)view {
    [self startIn:view withNavigationBar:YES];
}

- (void)startIn:(UIView *)view withNavigationBar:(BOOL)showNavBar {
    [self resetLoadingView:view];
}

- (void)resetLoadingView:(UIView *)view {
    dispatch_async_on_main_queue(^{
        //    [self updateFrameWithOffset:_offset];
        [view addSubview:self.view];
        [self.view setCenterX:view.centerX];
        [self.view setCenterY:view.centerY];
        [self.view setBounds:view.bounds];
        self.view.frame = view.bounds;
        [self updateFrameWithOffset:_offset];
        
        [view bringSubviewToFront:self.view];
        [self.view setNeedsDisplay];
    });
}


- (void)updateFrameWithOffset:(CGFloat)delta {
    CGRect frame = [self.view frame];
    frame.origin.y = delta;
    self.view.frame = frame;
}

- (void)stop {
    dispatch_async_on_main_queue(^{
        _offset = 0;
        [self.view removeFromSuperview];
    });
}



-(UIImageView *)imageView_gif{
    if (!_imageView_gif) {
        _imageView_gif = [UIImageView new];
        _imageView_gif.backgroundColor = [UIColor clearColor];
    }
    return _imageView_gif;
}

@end
