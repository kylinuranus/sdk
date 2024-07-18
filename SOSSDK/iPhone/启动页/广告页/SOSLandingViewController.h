//
//  SOSLandingViewController.h
//  Onstar
//
//  Created by Joshua on 14-8-26.
//  Copyright (c) 2014年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^dismissComplete)(void);

@interface LandingImage : NSObject <NSCoding>
@property (nonatomic, strong) NSString *imageId;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *expireDate;
@property (nonatomic, strong) NSString* duration;
@property (nonatomic, assign) BOOL isExpired;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString  *canShare;
@property (nonatomic, copy) NSString *thumbnailUrl;
@property (nonatomic, copy) NSString *url;
@end


@interface LandingImageCache : NSObject
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) LandingImage *cachedImage;
@property (nonatomic, strong) LandingImage *downloadImage;
+ (id)sharedInstance;
+ (void)purgeInstance;
- (void)save;
- (void)requestLandingImage;
- (void)parseLandingPageResponse:(id)request;
- (BOOL)loadLandingImage;
- (NSString *)cacheImagePath:(NSString *)fileName;
- (void)requestLandingImageNew:(void (^)(LandingImage*))complete;

@end


@interface SOSLandingViewController : UIViewController
@property (nonatomic , copy)dismissComplete completeBlock;
//@property (nonatomic,copy)NSString *imageUrl;  //加载的landingPage地址
//@property (nonatomic ,assign)NSInteger duration;
//- (void)dismissWithComplete:(dismissComplete)complete_
@property (strong, nonatomic) LandingImage *landingImage;
;
@end
