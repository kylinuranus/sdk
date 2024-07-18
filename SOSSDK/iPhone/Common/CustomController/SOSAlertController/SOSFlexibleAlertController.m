//
//  SOSFlexibleAlertController.m
//  Onstar
//
//  Created by TaoLiang on 2018/12/24.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSFlexibleAlertController.h"
#import "UIImage+Screenshot.h"
#import <SDWebImage/SDWebImageManager.h>


@interface SOSAlertAnimation : NSObject <UIViewControllerAnimatedTransitioning>
@property (assign, nonatomic) BOOL isPresenting;
@end

@implementation SOSAlertAnimation
static CGFloat const kAnimationDuration = 0.20f;

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return kAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if(self.isPresenting){
        [self executePresentingAnimation:transitionContext];
    }
    else{
        [self executeDismissingAnimation:transitionContext];
    }
}

- (void)executePresentingAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    UIView *containerView = [transitionContext containerView];
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toViewController.view.frame = CGRectMake(0.0f, 0.0f, windowSize.width, windowSize.height);
    toViewController.view.alpha = 0.0f;
    if ([toViewController isKindOfClass:[SOSFlexibleAlertController class]]) {
        SOSFlexibleAlertController *alertController = (SOSFlexibleAlertController *)toViewController;
        if (alertController.preferredStyle == SOSAlertControllerStyleAlert) {
            alertController.alertContainerView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
        }
    }
    [containerView addSubview:toViewController.view];
    
    [UIView animateWithDuration:kAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
        toViewController.view.alpha = 1.0f;
        if ([toViewController isKindOfClass:[SOSFlexibleAlertController class]]) {
            SOSFlexibleAlertController *alertController = (SOSFlexibleAlertController *)toViewController;
            if (alertController.preferredStyle == SOSAlertControllerStyleAlert) {
                alertController.alertContainerView.transform = CGAffineTransformIdentity;
            }
        }
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)executeDismissingAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    UIView *containerView = [transitionContext containerView];
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    toViewController.view.frame = CGRectMake(0.0f, 0.0f, windowSize.width, windowSize.height);
    [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    [UIView animateWithDuration:kAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
        fromViewController.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}
@end


@interface SOSAlertAction ()

@property (copy, nonatomic) void (^handler)(SOSAlertAction *action);
@end

@implementation SOSAlertAction

static NSDictionary *_defaultFonts = nil;
static NSDictionary *_defaultColors = nil;

+ (instancetype)actionWithTitle:(NSString *)title style:(SOSAlertActionStyle)style handler:(void (^)(SOSAlertAction * _Nonnull))handler {
    return [[[self class] alloc] initWithTitle:title style:style handler:handler isOnStarStyle:false];
}

+ (instancetype)actionWithTitleOnStarStyle:(NSString *)title style:(SOSAlertActionStyle)style handler:(void (^)(SOSAlertAction * _Nonnull))handler {
    return [[[self class] alloc] initWithTitle:title style:style handler:handler  isOnStarStyle:true];
}


- (instancetype)initWithTitle:(NSString *)title style:(SOSAlertActionStyle)style handler:(void (^)(SOSAlertAction * _Nonnull))handler isOnStarStyle:(bool)isOnStarStyle {
    self = [super init];
    if (self) {
        static dispatch_once_t token;
        dispatch_once(&token, ^(void) {
            
            if(isOnStarStyle){
                
                _defaultFonts = @{
                                  @(SOSAlertActionStyleDestructive): [UIFont boldSystemFontOfSize:17],
                                  @(SOSAlertActionStyleDefault): [UIFont boldSystemFontOfSize:17],
                                  @(SOSAlertActionStyleGray): [UIFont boldSystemFontOfSize:17],
                                  @(SOSAlertActionStyleCancel): [UIFont boldSystemFontOfSize:17]
                                  };
                
                _defaultColors = @{
                                   @(SOSAlertActionStyleDestructive): [UIColor colorWithRed:1.0f green:59.0f/255.0f blue:48.0f/255.0f alpha:1.0f],
                                   @(SOSAlertActionStyleDefault): [UIColor colorWithHexString:@"#0079FF"],
                                   @(SOSAlertActionStyleCancel): [UIColor colorWithHexString:@"#000000"],
                                   @(SOSAlertActionStyleGray): [UIColor colorWithHexString:@"#A4A4A4"],
                                   @(SOSAlertActionStyleActionSheetDefault): [UIColor colorWithHexString:@"#28292F"]
                                   };
            }else{
                
                _defaultFonts = @{
                                  @(SOSAlertActionStyleDestructive): [UIFont systemFontOfSize:16],
                                  @(SOSAlertActionStyleDefault): [UIFont systemFontOfSize:16],
                                  @(SOSAlertActionStyleGray): [UIFont systemFontOfSize:16],
                                  @(SOSAlertActionStyleCancel): [UIFont systemFontOfSize:16]
                                  };
                
                _defaultColors = @{
                                   @(SOSAlertActionStyleDestructive): [UIColor colorWithRed:1.0f green:59.0f/255.0f blue:48.0f/255.0f alpha:1.0f],
                                   @(SOSAlertActionStyleDefault): [UIColor colorWithHexString:@"#6896ED"],
                                   @(SOSAlertActionStyleCancel): [UIColor colorWithHexString:@"#A4A4A4"],
                                   @(SOSAlertActionStyleGray): [UIColor colorWithHexString:@"#A4A4A4"],
                                   @(SOSAlertActionStyleActionSheetDefault): [UIColor colorWithHexString:@"#28292F"]
                                   };
            }
           
        });

        _title = title;
        _style = style;
        _handler = handler;
        _font = _defaultFonts[@(style)];
        _titleColor = _defaultColors[@(style)];
    }
    return self;
}

 

@end

@interface SOSFlexibleAlertController ()<UIViewControllerTransitioningDelegate>
@property (strong, nonatomic) UIImageView *screenshotImageView;
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIView *funcView;

//action sheet cancel btn
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) SOSAlertAnimation *animation;

@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, assign) BOOL *showRightButton;
@property (nonatomic, assign) BOOL isOnStarStyle;
@end

@implementation SOSFlexibleAlertController

static CGFloat const kLabelMargin = 25;

+ (instancetype)alertControllerWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message customView:(__kindof UIView *)customView preferredStyle:(SOSAlertControllerStyle)preferredStyle {
    return [[[self class] alloc] initWithImage:(UIImage *)image title:title message:message customView:customView preferredStyle:preferredStyle isOnStarStyle:false];
}


+ (instancetype)alertControllerWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message customView:(__kindof UIView *)customView preferredStyle:(SOSAlertControllerStyle)preferredStyle isOnStarStyle:(bool)isOnStarStyleRef {
     
    return [[[self class] alloc] initWithImage:(UIImage *)image title:title message:message customView:customView preferredStyle:preferredStyle isOnStarStyle:isOnStarStyleRef];
}
+ (instancetype)alertControllerWithImageURL:(NSString *)imageURL placeholderImage:(UIImage*)placeholder width:(CGFloat)width height:(CGFloat)height title:(NSString *)title message:(NSString *)message customView:(__kindof UIView *)customView preferredStyle:(SOSAlertControllerStyle)preferredStyle {
    return [[self.class alloc] initWithImageURL:imageURL placeholderImage:placeholder width:width height:height title:title message:message customView:customView preferredStyle:preferredStyle];
}


 
- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message customView:(__kindof UIView*)customView preferredStyle:(SOSAlertControllerStyle)preferredStyle isOnStarStyle:(bool)isOnStarStyleRef{
    if (self = [super init]) {
        
        _titleImage = image;
        _alertTitle = title;
        _message = message;
        _customView = customView;
        _preferredStyle = preferredStyle;
        
        _titleColor = [UIColor colorWithHexString:@"#28292F"];
        _titleFont = [UIFont boldSystemFontOfSize:16];
        _separatorColor = [UIColor colorWithHexString:@"#F3F3F4"];

        _isOnStarStyle = isOnStarStyleRef;
        
    }
    return self;
}
- (instancetype)initWithImageURL:(NSString *)imageURL placeholderImage:(UIImage*)placeholder width:(CGFloat)width height:(CGFloat)height title:(NSString *)title message:(NSString *)message customView:(__kindof UIView*)customView preferredStyle:(SOSAlertControllerStyle)preferredStyle {
    self = [self initWithImage:placeholder title:title message:message customView:customView preferredStyle:preferredStyle isOnStarStyle:false];
    if (self) {
        [[SDWebImageManager sharedManager] loadImageWithURL:imageURL.mj_url options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (!error) {
                _titleImage = image;
                if (width == CGFLOAT_MAX || height == CGFLOAT_MAX) {
                    return;
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_titleImageView mas_updateConstraints:^(MASConstraintMaker *make){
                        make.size.mas_equalTo(CGSizeMake(width, height));
                    }];
                    _titleImageView.image = _titleImage;
                });

            }
        }];
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.transitioningDelegate = self;
    _animation = [SOSAlertAnimation new];
    
    if(self.isOnStarStyle)
        [self configView2];
    else
        [self configView];
    
    [self layoutView];
    [self addObservers];
    
}
- (void)configView2 {
//    背景图
//    _screenshotImageView = [UIImageView new];
//    [self.view addSubview:_screenshotImageView];
    //黑色遮罩层
    _maskView = [UIView new];
    _maskView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_maskView];
    //整个页面的容器层，键盘出现\隐藏时对该层做动画
    _containerView = [UIView new];
    _containerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_containerView];
    //主体内容容器层
    _alertContainerView = [UIView new];
    _alertContainerView.backgroundColor = [UIColor whiteColor];
    _alertContainerView.layer.cornerRadius = 18;
    _alertContainerView.layer.masksToBounds = YES;
    [self.view addSubview:_alertContainerView];
    //图片
    _titleImageView = [UIImageView new];
    _titleImageView.contentMode = UIViewContentModeScaleAspectFill;
    _titleImageView.clipsToBounds = YES;
    [_alertContainerView addSubview:_titleImageView];
    //标题
    _titleLabel = [UILabel new];
    _titleLabel.numberOfLines = 0;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_alertContainerView addSubview:_titleLabel];
    //文本内容
    _messageLabel = [UILabel new];
    _messageLabel.numberOfLines = 0;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.font = [UIFont systemFontOfSize:17];
    _messageLabel.textColor = [UIColor colorWithHexString:@"#0000007F"];
    [_alertContainerView addSubview:_messageLabel];
    //自定义View容器
    _contentView = [UIView new];
    [_alertContainerView addSubview:_contentView];
    
    if (_rightButtonBlock) {
        UIButton * rightB =  _rightButtonBlock();
        [_alertContainerView addSubview:rightB];
        [rightB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(-16);
            make.top.mas_equalTo(16);
            make.width.height.mas_equalTo(34);
        }];
    }
    
}
- (void)configView {
//    背景图
//    _screenshotImageView = [UIImageView new];
//    [self.view addSubview:_screenshotImageView];
    //黑色遮罩层
    _maskView = [UIView new];
    _maskView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_maskView];
    //整个页面的容器层，键盘出现\隐藏时对该层做动画
    _containerView = [UIView new];
    _containerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_containerView];
    //主体内容容器层
    _alertContainerView = [UIView new];
    _alertContainerView.backgroundColor = [UIColor whiteColor];;
    _alertContainerView.layer.cornerRadius = 4;
    _alertContainerView.layer.masksToBounds = YES;
    [self.view addSubview:_alertContainerView];
    //图片
    _titleImageView = [UIImageView new];
    _titleImageView.contentMode = UIViewContentModeScaleAspectFill;
    _titleImageView.clipsToBounds = YES;
    [_alertContainerView addSubview:_titleImageView];
    //标题
    _titleLabel = [UILabel new];
    _titleLabel.numberOfLines = 0;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_alertContainerView addSubview:_titleLabel];
    //文本内容
    _messageLabel = [UILabel new];
    _messageLabel.numberOfLines = 0;
    _messageLabel.textAlignment = NSTextAlignmentLeft;
    _messageLabel.font = [UIFont systemFontOfSize:12];
    _messageLabel.textColor = [UIColor colorWithHexString:@"#828389"];
    [_alertContainerView addSubview:_messageLabel];
    //自定义View容器
    _contentView = [UIView new];
    [_alertContainerView addSubview:_contentView];
    
    if (_rightButtonBlock) {
        UIButton * rightB =  _rightButtonBlock();
        [_alertContainerView addSubview:rightB];
        [rightB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(-16);
            make.top.mas_equalTo(16);
            make.width.height.mas_equalTo(34);
        }];
    }
    
}

- (void)layoutView {
//    [_screenshotImageView mas_makeConstraints:^(MASConstraintMaker *make){
//        make.edges.equalTo(self.view);
//    }];

    [_maskView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];
    
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make){
        if (_preferredStyle == SOSAlertControllerStyleActionSheet) {
            make.edges.insets(UIEdgeInsetsMake(0, 0, -SCREEN_HEIGHT, 0));
        }else {
            make.edges.equalTo(self.view);
        }
    }];
    
//    [_alertContainerView mas_makeConstraints:^(MASConstraintMaker *make){
//        if (_preferredStyle == SOSAlertControllerStyleAlert) {
//            make.center.equalTo(_containerView);
//            make.width.equalTo(@260);
//        }else {
//            make.left.equalTo(@12);
//            make.right.equalTo(@-12);
//        }
//    }];
    [_alertContainerView mas_makeConstraints:^(MASConstraintMaker *make){
        if (_preferredStyle == SOSAlertControllerStyleAlert) {
            make.center.equalTo(_containerView);
//            make.width.equalTo(@260);  应测试提bug，增加宽度
            
            if(self.margins==0){
                make.left.equalTo(@27);
                make.right.equalTo(@-27);
            }
            else{
                
                make.left.equalTo( @(self.margins));
                make.right.equalTo(@(-self.margins));
            }
        
            
            
        }else {
            make.left.equalTo(@12);
            make.right.equalTo(@-12);
        }
    }];
    
    if (_preferredStyle == SOSAlertControllerStyleActionSheet) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.layer.cornerRadius = 4;
        [_containerView addSubview:_cancelBtn];
        [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make){
            make.bottom.equalTo(IS_IPHONE_XSeries ? _containerView.sos_bottom : @-12);
            make.height.equalTo(@48);
            make.left.equalTo(@12);
            make.right.equalTo(@-12);
            make.top.equalTo(_alertContainerView.mas_bottom).offset(12);
        }];
        
    }


    [_titleImageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(_alertContainerView);
        make.top.equalTo(_titleImage ? @25 : @0);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(@(kLabelMargin));
        make.right.equalTo(@(-kLabelMargin));
        make.top.equalTo(_titleImageView.mas_bottom).offset(_alertTitle.length > 0 ? (_titleImage ? 25 : (_customView ? 15 : 40)) : 0);
    }];
    

    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make){
//        make.left.equalTo(@(kLabelMargin));
//        make.right.equalTo(@(-kLabelMargin));
        //一行时居中,多行时左对齐
        make.left.greaterThanOrEqualTo(@(kLabelMargin));
        make.right.lessThanOrEqualTo(@(-kLabelMargin));
        make.centerX.equalTo(_alertContainerView);
        make.top.equalTo(_titleLabel.mas_bottom).offset(_message.length > 0 ? (_alertTitle.length > 0 ? 10 : 25) : 0);
    }];


    [_contentView mas_makeConstraints:^(MASConstraintMaker *make){
        if (!_titleImage && _alertTitle.length <= 0 && _message.length <= 0 && !_customView) {
            make.top.equalTo(_messageLabel.mas_bottom);
        }else {        
            make.top.equalTo(_messageLabel.mas_bottom).offset(_customView ? 0 : 30);
        }
        make.left.right.equalTo(_alertContainerView);
    }];
    
    if (_customView) {
        [_contentView addSubview:_customView];
        [_customView mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(_contentView);
            make.height.mas_equalTo(_customView.height).priorityLow();
        }];
    }
    
    _funcView = [UIView new];
    _funcView.backgroundColor = _separatorColor;
    [_alertContainerView addSubview:_funcView];
    [_funcView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(_contentView.mas_bottom).offset(1);
        make.left.right.bottom.equalTo(_alertContainerView);
        make.height.equalTo(@0).priorityLow();
    }];
    
    [self arrangeFuncBtns];
}



- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    UIImage *screenshot = [UIImage screenshot];
//    if (_enabledBlurEffect) {
//        _screenshotImageView.image = screenshot.bluredImage;
//    }else {
//        _screenshotImageView.image = screenshot;
//    }
    _titleLabel.textColor = _titleColor;
    _titleLabel.font = _titleFont;
    _maskView.alpha = 0.45;
    _titleImageView.image = _titleImage;
    _titleLabel.text = _alertTitle;
    _messageLabel.text = _message;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_preferredStyle == SOSAlertControllerStyleActionSheet) {
        [_containerView mas_updateConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(self.view);
        }];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_preferredStyle == SOSAlertControllerStyleActionSheet) {
        [_containerView mas_updateConstraints:^(MASConstraintMaker *make){
            make.edges.insets(UIEdgeInsetsMake(0, 0, -SCREEN_HEIGHT, 0));
        }];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    }

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _alertWindow.hidden = YES;
    _alertWindow = nil;
    [SOS_ONSTAR_WINDOW makeKeyWindow];
}

- (void)addActions:(NSArray<SOSAlertAction *> *)actions {
    NSUInteger cancelBtnTimes = 0;
    NSMutableArray *originActs = [NSMutableArray arrayWithArray:_actions];
    for (SOSAlertAction *action in actions) {
        if (action.style == SOSAlertActionStyleCancel) {
            cancelBtnTimes++;
        }
        if (cancelBtnTimes > 1) {
            [NSException raise:@"NSInternalInconsistencyException" format:@"SOSAlertController can only have one action with a style of MSAlertActionStyleCancel"];
            return;
        }
    }
    NSMutableArray *tempActions = actions.mutableCopy;
    __block NSInteger cancelIndex = -NSIntegerMax;
    [tempActions enumerateObjectsUsingBlock:^(SOSAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.style == SOSAlertActionStyleCancel) {
            cancelIndex = idx;
            *stop = YES;
            return;
        }
    }];
    if (cancelIndex != -NSIntegerMax && cancelIndex != 0) {
        SOSAlertAction *action = tempActions[cancelIndex];
        [tempActions removeObjectAtIndex:cancelIndex];
        [tempActions insertObject:action atIndex:0];
    }
    [originActs addObjectsFromArray:tempActions];
    _actions = originActs.copy;
}

#pragma mark - UIViewControllerTransitioningDelegate Methods
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _animation.isPresenting = YES;
    return _animation;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _animation.isPresenting = NO;
    return _animation;
}

#pragma mark - custom action

- (void)arrangeFuncBtns {
    if (_preferredStyle == SOSAlertControllerStyleActionSheet) {
        [self configActionSheetCancelBtn];
    }
    
    if (_actions.count <= 0) {
        
    }else if (_actions.count == 1) {
        UIButton *funcButton = [self fetchFuncButton:_actions.firstObject];
        [funcButton mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.insets(UIEdgeInsetsMake(1, 0, 0, 0));
        }];
    }else if (_actions.count == 2 && _preferredStyle == SOSAlertControllerStyleAlert) {
        UIButton *btn0 = [self fetchFuncButton:_actions[0]];
        UIButton *btn1 = [self fetchFuncButton:_actions[1]];
        [btn0 mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.bottom.equalTo(_funcView);
            make.top.equalTo(_funcView).offset(1);
            make.width.equalTo(_funcView).multipliedBy(.5).offset(-.5);
        }];
        [btn1 mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.bottom.equalTo(_funcView);
            make.top.equalTo(_funcView).offset(1);
            make.width.equalTo(_funcView).multipliedBy(.5).offset(-.5);
        }];
    }else {
        NSMutableArray *btns = @[].mutableCopy;
        [_actions enumerateObjectsUsingBlock:^(SOSAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *btn = [self fetchFuncButton:obj];
            [btn mas_makeConstraints:^(MASConstraintMaker *make){
                make.left.right.equalTo(_funcView);
            }];
            
            [btns addObject:btn];
        }];
        [btns mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:1 leadSpacing:1 tailSpacing:0];
    }
}

- (UIButton *)fetchFuncButton:(SOSAlertAction *)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:action.title forState:UIControlStateNormal];
    [button setTitleColor:action.titleColor forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    [button setBackgroundColor:[UIColor colorWithHexString:@"#eeeeee"] forState:UIControlStateHighlighted];
    button.titleLabel.font = action.font;
    [_funcView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make){
        make.height.equalTo(@47);
    }];
    
    __weak __typeof(self)weakSelf = self;
    [button addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            action.handler ? action.handler(action) : nil;
        }];
        
    }];
    return button;
}

- (void)configActionSheetCancelBtn {
    //ActionSheet的取消按钮需单独处理
    if (_actions.firstObject.style == SOSAlertActionStyleCancel) {
        
        SOSAlertAction *cancelAction = _actions.firstObject;
        [_cancelBtn setTitle:cancelAction.title forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:cancelAction.titleColor forState:UIControlStateNormal];
        _cancelBtn.backgroundColor = [UIColor whiteColor];
        [_cancelBtn setBackgroundColor:[UIColor colorWithHexString:@"#eeeeee"] forState:UIControlStateHighlighted];
        _cancelBtn.titleLabel.font = cancelAction.font;
        _cancelBtn.layer.cornerRadius = 4;
        _cancelBtn.layer.masksToBounds = YES;
        __weak __typeof(self)weakSelf = self;
        [_cancelBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                cancelAction.handler ? cancelAction.handler(cancelAction) : nil;
            }];
        }];

        [_cancelBtn mas_updateConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(_alertContainerView.mas_bottom).offset(12);
            make.height.equalTo(@48);
        }];
        NSMutableArray <SOSAlertAction *>*tempActions = _actions.mutableCopy;
        [tempActions removeFirstObject];
        _actions = tempActions.copy;
    }else {
        [_cancelBtn mas_updateConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(_alertContainerView.mas_bottom).offset(0);
            make.height.equalTo(@0);
        }];
    }

}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [_containerView mas_remakeConstraints:^(MASConstraintMaker *make){
        make.edges.insets(UIEdgeInsetsMake(0, 0, kbSize.height, 0));
    }];
    [UIView animateWithDuration:0.3 animations:^(void) {
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [_containerView mas_remakeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];
    [UIView animateWithDuration:0.3 animations:^(void) {
        [self.view layoutIfNeeded];
    }];
}

- (void)show {
    [self show:YES];
}

- (void)show:(BOOL)animated {
    [self show:animated completion:nil];
}

- (void)show:(BOOL)animated completion:(void (^ __nullable)(void))completion {
    dispatch_async_on_main_queue(^{
        self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.alertWindow.rootViewController = [[UIViewController alloc] init];
        
        id<UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;
        // Applications that does not load with UIMainStoryboardFile might not have a window property:
        if ([delegate respondsToSelector:@selector(window)]) {
            // we inherit the main window's tintColor
            self.alertWindow.tintColor = delegate.window.tintColor;
        }
        
        // window level is above the top window (this makes the alert, if it's a sheet, show over the keyboard)
        UIWindow *topWindow = [UIApplication sharedApplication].windows.lastObject;
        self.alertWindow.windowLevel = topWindow.windowLevel + 1;
        
        [self.alertWindow makeKeyAndVisible];
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        //延迟0.1秒,避免balanced call xxxxxxxx
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.alertWindow.rootViewController presentViewController:self animated:animated completion:completion];
        });
    });

    
    
    
}

- (void)dealloc {
//    _alertWindow.hidden = YES;
//    _alertWindow = nil;
    NSLog(@"%@ has delloced", self);
    
}

@end
