//
//  LandingViewController.m
//  Onstar
//
//  Created by Joshua on 14-8-26.
//  Copyright (c) 2014年 Shanghai Onstar. All rights reserved.
//

#import "SOSLandingViewController.h"
#import "ServiceURL.h"
#import "ResponseDataObject.h"
#import "RequestDataObject.h"
#import "SOSNetworkOperation.h"
#import "CustomerInfo.h"
#import "SOSWebViewController.h"
#import "CustomNavigationController.h"
#import <SDWebImage/UIImageView+WebCache.h>


#define LANDING_IMAGE_CACHE_PATH    @"LandingImages"
#define LANDING_IMAGE_CACHE_FILE    @"LandingImages.archive"

@implementation LandingImage
- (id)initWithLandingResponse:(NNLandingPage *)response     {
    self = [super init];
    if (response) {
        self.imageId = response.lid;
        self.imageUrl = response.imageURL;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        self.startDate = [formatter dateFromString:response.startTime];
        self.expireDate = [formatter dateFromString:response.expireTime];
        self.duration = response.duration;
        self.language = [SOSLanguage getCurrentLanguage];
        self.canShare = response.canShare;
        self.thumbnailUrl = response.thumbnailUrl;
        self.url = response.url;
    }
    return self;
}

- (NSString *)imageSavePath     {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString *imageSavePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.imageId]];
    return imageSavePath;
}

- (id)initWithCoder:(NSCoder *)aDecoder     {
    _imageId = [aDecoder decodeObjectForKey:@"ImageId"];
    _imageUrl = [aDecoder decodeObjectForKey:@"imageURL"];
    _startDate = [aDecoder decodeObjectForKey:@"startTime"];
    _expireDate = [aDecoder decodeObjectForKey:@"expireTime"];
    _duration = [aDecoder decodeObjectForKey:@"duration"];
    _filePath = [aDecoder decodeObjectForKey:@"FilePath"];
    _language = [aDecoder decodeObjectForKey:@"Language"];
    _isExpired = NO;
    //    _canShare = [[aDecoder decodeObjectForKey:@"canShare"] boolValue];
    _canShare = [aDecoder decodeObjectForKey:@"canShare"];
    _thumbnailUrl = [aDecoder decodeObjectForKey:@"thumbnailUrl"];
    _url = [aDecoder decodeObjectForKey:@"url"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder     {
    [aCoder encodeObject:_imageId forKey:@"ImageId"];
    [aCoder encodeObject:_imageUrl forKey:@"imageURL"];
    [aCoder encodeObject:_startDate forKey:@"startTime"];
    [aCoder encodeObject:_expireDate forKey:@"expireTime"];
    [aCoder encodeObject:_duration forKey:@"duration"];
    [aCoder encodeObject:_filePath forKey:@"FilePath"];
    [aCoder encodeObject:_language forKey:@"Language"];
    //    [aCoder encodeObject:@(_canShare) forKey:@"canShare"];
    [aCoder encodeObject:_canShare forKey:@"canShare"];
    [aCoder encodeObject:_thumbnailUrl forKey:@"thumbnailUrl"];
    [aCoder encodeObject:_url forKey:@"url"];
}
@end

LandingImageCache *sharedCache = nil;
@implementation LandingImageCache

+ (id)sharedInstance     {
    
    static LandingImageCache *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [[self alloc] initWithArchiveFile];
    });
    return sharedOBJ;
}

+ (void)purgeInstance     {
    //    [sharedCache release];
}

- (id)initWithArchiveFile     {
    NSArray *tmpArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cacheFilePath]];
    _imageArray = [[NSMutableArray alloc] initWithArray:tmpArray];
    return self;
}

- (BOOL)checkItemExist:(LandingImage *)image     {
    for (int i = 0; i < [_imageArray count]; i++) {
        LandingImage *eachImage = [_imageArray objectAtIndex:i];
        if ([eachImage.imageId isEqualToString:image.imageId]) {
            eachImage.startDate = image.startDate;
            eachImage.expireDate = image.expireDate;
            eachImage.duration = image.duration;
            //update
            eachImage.canShare = image.canShare;
            eachImage.thumbnailUrl = image.thumbnailUrl;
            if (![image.imageUrl isEqualToString:eachImage.imageUrl]) {
                // If url is not the same, reset url and begin download.
                eachImage.imageUrl = image.imageUrl;
                eachImage.filePath = nil;
            }
            self.downloadImage = eachImage;
            return YES;
        }
    }
    self.downloadImage = image;
    return NO;
}

- (BOOL)checkImageFileExist:(NSString *)filePath     {
    if (filePath && [[NSFileManager defaultManager] fileExistsAtPath:[self cacheImagePath:filePath]]) {
        // TOTO check the image file size and file type
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)cacheImagePath:(NSString *)fileName     {
    // iOS 8 the app path is changed for every time.
    // /var/mobile/Containers/Data/Application/45A04143-76D2-4ADD-A2E3-35D9106F59B6/Library/Caches
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return [NSString stringWithFormat:@"%@/%@", cachePath, fileName];;
}

- (void)addImageToCache:(LandingImage *)image     {
    if ([self checkItemExist:image]) {
        // use current image instead
        if ([self checkImageFileExist:self.downloadImage.filePath]) {
            return;
        } else {
            [self downloadImage:self.downloadImage];
        }
    } else {
        [self downloadImage:self.downloadImage];
        [_imageArray addObject:self.downloadImage];
    }
}

- (void)downloadImage:(LandingImage *)image     {
    NSString *savePath = [self cacheImagePath:image.imageId];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:image.imageUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        UIImage *tmpImage = [UIImage imageWithData:imageData];
        // Check if the download file is image.
        if (tmpImage) {
            [imageData writeToFile:savePath atomically:YES];
            image.filePath = image.imageId;
            [[LandingImageCache sharedInstance] save];
        } else {
            image.filePath = nil;
        }
    });
}

- (void)save
{
    @synchronized(self) {
        NSArray *tmpArray = [NSArray arrayWithArray:_imageArray];
        for (LandingImage *image in tmpArray) {
            if ([image isExpired]) {
                [_imageArray removeObject:image];
            }
        }
        [NSKeyedArchiver archiveRootObject:_imageArray toFile:[self cacheFilePath]];
    }
}

- (NSString *)cacheFilePath
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString *imageCacheFilePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", LANDING_IMAGE_CACHE_FILE]];
    return imageCacheFilePath;
}

- (LandingImage *)loadImageFromCache
{
    LandingImage *retImage = nil;
    for (int i = (int)[_imageArray count] - 1; i >= 0; i--) {
        LandingImage *tmpImg = [_imageArray objectAtIndex:i];
        if ([[tmpImg expireDate] compare:[NSDate date]] == NSOrderedDescending) {
            if ([tmpImg filePath].length > 0 &&
                [UIImage imageWithContentsOfFile:[self cacheImagePath:tmpImg.filePath]] &&
                [tmpImg.language isEqualToString:[SOSLanguage getCurrentLanguage]]) {
                retImage = tmpImg;
                break;
            }
        } else {
            tmpImg.isExpired = YES;
        }
    }
    return retImage;
}

- (BOOL)loadLandingImage
{
    // 1. load from cache, which is not expired.
    // 2. If exist, display it; else download from MAG.
    BOOL exist = NO;
    self.cachedImage = [self loadImageFromCache];
    exist = (_cachedImage != nil);
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self requestLandingImage];
    //    });
    return exist;
}

- (void)requestLandingImage
{
    NSString *url = [BASE_URL stringByAppendingString:NEW_GET_LANDING_IMAGE_URL];
    //url = [url stringByAppendingString:[NSString stringWithFormat:@"?OSType=%@",[Util currentDeviceType]]];
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    d[@"OSType"] = [Util currentDeviceType];
    NSString *s = [Util jsonFromDict:d];
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id returnData) {
        [self parseLandingPageResponse:returnData];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NNErrorDetail *detail = [NNErrorDetail mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
        if ([[detail code] isEqualToString:@"E2011"]) {
            [_imageArray removeAllObjects];
            [self save];
        }
    }];
    [sosOperation setHttpMethod:@"POST"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

- (void)parseLandingPageResponse:(id)responseData
{
    NNLandingPage *landingResponse = [NNLandingPage mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseData]];
    LandingImage *landingImgObj = [[LandingImage alloc] initWithLandingResponse:landingResponse];
    [self addImageToCache:landingImgObj];
    [self save];
}


- (void)requestLandingImageNew:(void (^)(LandingImage*))complete
{
    NSString *url = [BASE_URL stringByAppendingString:NEW_GET_LANDING_IMAGE_URL];
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    d[@"osType"] = [Util currentDeviceType];
    NSString *s = [Util jsonFromDict:d];
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id returnData) {
        NNLandingPage *landingResponse = [NNLandingPage mj_objectWithKeyValues:[Util dictionaryWithJsonString:returnData]];
        LandingImage *landingImgObj = [[LandingImage alloc] initWithLandingResponse:landingResponse];
        if (complete) {
            complete(landingImgObj);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (complete) {
            complete(nil);
        }
    }];
    [sosOperation setHttpMethod:@"POST"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}


@end


@interface SOSLandingViewController ()     {
    BOOL isAutoClose;
    BOOL hasDismiss;
//    LandingImage *landingImage;
    dispatch_source_t timer;
    double startTime;
    double endTime;
}
@property (weak, nonatomic) CAShapeLayer *shapeLayer;
@end

@implementation SOSLandingViewController

- (void)viewDidLoad     {
    [super viewDidLoad];
    __block NSInteger durationNum = 0;
    isAutoClose = NO;
//    landingImage = [[LandingImageCache sharedInstance] cachedImage];
//    UIImage *image = [UIImage imageWithContentsOfFile:[[LandingImageCache sharedInstance] cacheImagePath:landingImage.filePath]];
//
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    imageView.userInteractionEnabled = YES;
//    imageView.clipsToBounds = YES;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(h5Jump)];
//    [imageView addGestureRecognizer:tap];
//    [self.view addSubview:imageView];
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make){
//        make.edges.equalTo(self.view);
//    }];
    
    NSString *imgName = SCREEN_WIDTH == 640 ? @"default640" : @"default750";
    UIImageView *imageView = [UIImageView new];
    NSURL *url = [NSURL URLWithString:_landingImage.imageUrl];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.userInteractionEnabled = YES;
    imageView.clipsToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(h5Jump)];
    [imageView addGestureRecognizer:tap];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];
    //[imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:imgName]];
    startTime = CACurrentMediaTime()*1000;
    [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:imgName] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        self->endTime = CACurrentMediaTime()*1000;
        if (error||!image) {
            [SOSDaapManager sendSysLayout:startTime endTime:endTime loadStatus:NO funcId:Splash_AD_Pic_Loadtime];
        }else{
            [SOSDaapManager sendSysLayout:startTime endTime:endTime loadStatus:YES funcId:Splash_AD_Pic_Loadtime];
        }
    }];
    
    
    UIButton *skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [skipBtn setTitle:@"跳过" forState:UIControlStateNormal];
    [skipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    skipBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    skipBtn.backgroundColor = [UIColor colorWithRed:0.00f green:0.00f blue:0.00f alpha:0.30f];
    skipBtn.layer.cornerRadius = 20;
    [skipBtn addTarget:self action:@selector(dismissWithComplete) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipBtn];
    [skipBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view.mas_top).offset(STATUSBAR_HEIGHT);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];

    if (_landingImage.duration.length > 0) {
//    if (self.duration > 0) {
        CAShapeLayer *shapeLayer = [CAShapeLayer new];
        shapeLayer.frame = CGRectMake(0, 0, 40, 40);
        shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 40, 40) cornerRadius:20].CGPath;
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer.lineWidth = 2;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        [skipBtn.layer addSublayer:shapeLayer];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        animation.duration = _landingImage.duration.integerValue / 1000;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat:1.0f];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [shapeLayer addAnimation:animation forKey:nil];
        _shapeLayer = shapeLayer;
        
    }
    
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        durationNum++;
//        if ((durationNum-1)>=([landingImage.duration integerValue]/1000)) {
        if ((durationNum-1) >= _landingImage.duration.integerValue / 1000) {
            isAutoClose = YES;
            dispatch_source_cancel(timer);
            timer = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"==============闪屏倒计时结束==============");
                [self dismissWithComplete];
            });
        }
    });
    dispatch_resume(timer);
    
}


- (void)dismissWithComplete		{
    if (isAutoClose) {
        [SOSDaapManager sendActionInfo:Splash_AD_Skip_AUTO];
    }	else	{
        [SOSDaapManager sendActionInfo:SPLASH_AD_SKIP];
    }
    if (_completeBlock != NULL && !hasDismiss) {
        hasDismiss = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_shapeLayer removeAllAnimations];
            _completeBlock();
        });
    }
}

- (void)h5Jump		{
    if (_landingImage.imageUrl.length > 0 && _landingImage.url.length) {
        [SOSDaapManager sendActionInfo:SPLASH_AD];
        if (timer) {
            //test Merge Branch
            dispatch_source_cancel(timer);
            timer = nil;
        }
        
        AppDelegate_iPhone *delegate = (AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate];
        
        SOSWebViewController *web = [[SOSWebViewController alloc] initWithUrl:_landingImage.url];
        web.shouldDismiss = YES;
        //判断是否可以分享
        if ([_landingImage.canShare isEqualToString:@"1"])     {
            web.alwaysShareFlg = YES;
            web.shareUrl = _landingImage.url;
            web.shareImg = _landingImage.thumbnailUrl;
        }
        [delegate showHomePageWithComplete:^{
            CustomNavigationController *navi = [[CustomNavigationController alloc] initWithRootViewController:web];
            [SOS_ONSTAR_WINDOW.rootViewController presentViewController:navi animated:YES completion:nil];
        }];
    }
}

- (void)dealloc {
    NSLog(@"SOSLandingViewController has dealloc");
}

@end
