//
//  SOSScanIDCardViewController.m
//  Onstar
//
//  Created by lizhipan on 2017/10/10.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSScanIDCardViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <ISIDReaderPreviewSDK/ISIDReaderPreviewSDK.h>
#import <ISOpenSDKFoundation/ISOpenSDKFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SOSOCRViewController.h"
//#define kMaxRange  120

#define BorderOriginY 60
#define BorderWidth 200 * (SCREEN_HEIGHT/568)
#define BorderHeight 320 * (SCREEN_HEIGHT/568)

//#warning 针对iphone4及以下低配置机型，width和height需设置在1280x720及以下。
#define ImageFrameWidth 1280
#define ImageFrameHeight 720


static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";
@interface SOSScanIDCardViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, assign) int index;
@property (nonatomic, strong) CALayer *cardNumberLayer;
@property (nonatomic, strong) CALayer *cardBorderLayer;
@end

@implementation SOSScanIDCardViewController


- (void)dealloc
{
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[ISIDCardReaderController sharedISOpenSDKController] destructResources];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"扫描身份证";
    self.view.backgroundColor = [SOSUtil onstarLightGray];
    if (_isForMirror) {
        self.navigationController.navigationBar.hidden = YES;
    }
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(orientationDidChange:)
//                                                 name:UIDeviceOrientationDidChangeNotification
//                                               object:nil];
}

- (void)configUIWithNoTitle		{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;

    NSInteger lb_x = 0;
    NSInteger lb_bottom_x = screenSize.width-156+40;
    
    if (screenSize.height >= 812) {
        lb_x = -14;
        lb_bottom_x = screenSize.width-156+60;
    }
    
    self.navigationController.navigationBar.hidden = YES;
    UILabel *lb = [[UILabel alloc] init];
    lb.text = @"扫描身份证";
    lb.font = [UIFont systemFontOfSize:14];
    lb.textColor = [UIColor whiteColor];
    CGRect r = CGRectMake(lb_x, screenSize.height/2, 80, 20);
    lb.frame = r;
    lb.transform = CGAffineTransformMakeRotation(-M_PI*0.5);
    [self.view addSubview:lb];
    [self.view bringSubviewToFront:lb];
    
//    [lb mas_makeConstraints:^(MASConstraintMaker *make) {
//        //make.centerX.equalTo(self.view.mas_centerX);
//        make.left.equalTo(self.view.mas_left).offset(-10);
//        //make.left.equalTo(self.view.mas_left).offset(0);
//        make.centerY.equalTo(self.view.mas_centerY).offset(8);
//        make.width.mas_equalTo(120);
//        make.height.mas_equalTo(20);
//    }];
    
    UILabel *lb_bottom = [[UILabel alloc] init];
    CGRect r1= CGRectMake(lb_bottom_x, screenSize.height/2, 156, 20);
    lb_bottom.frame = r1;
    lb_bottom.text = @"请将扫描框对准身份证";
    lb_bottom.font = [UIFont systemFontOfSize:14];
    lb_bottom.textColor = [UIColor whiteColor];
    lb_bottom.transform = CGAffineTransformMakeRotation(-M_PI*0.5);
    [self.view addSubview:lb_bottom];
    [self.view bringSubviewToFront:lb_bottom];
    
    
//    [lb_bottom mas_makeConstraints:^(MASConstraintMaker *make) {
//        //make.left.equalTo(self.view.mas_left).offset(300);
//        make.left.mas_equalTo(SCREEN_WIDTH-100);
//        make.centerY.equalTo(self.view.mas_centerY).offset(8);
//        make.width.mas_equalTo(148);
//        make.height.mas_equalTo(20);
//
//    }];

    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, screenSize.height-50, 44,44)];
    [btn setImage:[UIImage imageNamed:@"ImageResource.bundle/back_btn"] forState:UIControlStateNormal];
    btn.transform = CGAffineTransformMakeRotation(-M_PI*0.5);

    [self.view addSubview:btn];
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}


- (BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}
- (void)viewDidAppear:(BOOL)animated	{
    [super viewDidAppear:animated];
    if (self.captureSession == nil)	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString *subAppkey = nil;//reserved for future use
            [[ISIDCardReaderController sharedISOpenSDKController] constructResourcesWithAppKey:IDCardAppKey subAppkey:subAppkey finishHandler:^(ISOpenSDKStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(status == ISOpenSDKStatusSuccess)	{
                        [self setupAVCapture];
                        [self setupBorderView];
                        [self setupOtherThings];
                        [self focus];
                        if (![self.captureSession isRunning])	{
//                            if (self.avaudioScanIDCardOnly) {
//                                [self.captureSession startRunning];
//                            }
                            [self.captureSession startRunning];
                        }
                    }	else	 {
                        NSLog(@"Authorize error: %ld", (long)status);
                        [Util showAlertWithTitle:@"Error" message:[NSString stringWithFormat:@"SDK错误：%ld", (long)status] completeBlock:nil];
                    }
                });
            }];
        });
    }	else	{
        [self.captureSession startRunning];
    }
    [SOSDaapManager sendActionInfo:register_scanVIN_ID_ID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)AVCaptureRunning	{
    [self.captureSession startRunning];
}

- (void)AVCaptureStopRunning	{
    [self.captureSession stopRunning];
}

- (void)focus	{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if(device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
    {
        NSError *error =  nil;
        if([device lockForConfiguration:&error]){
            [device setFocusPointOfInterest:CGPointMake(.5f, .5f)];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [device unlockForConfiguration];
        }
    }
}

- (void)setupAVCapture
{
    
    NSError *error = nil;
    AVCaptureSession *session = [AVCaptureSession new];
    self.captureSession = session;
    // Select a video device, make an input
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if ( [session canAddInput:deviceInput] )
        [session addInput:deviceInput];
    
    // Make a video data output
    self.videoDataOutput = [AVCaptureVideoDataOutput new];
    
    // we want YUV, both CoreGraphics and OpenGL work well with 'YUV'
    NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
                                       [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [self.videoDataOutput setVideoSettings:rgbOutputSettings];
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    
    if ([session canAddOutput:self.videoDataOutput])
    {
        [session addOutput:self.videoDataOutput];
    }
    //1920*1080 is the suggested size if it is supported by device.
//#warning 针对iphone4及以下低配置机型，sessionPreset需设置在1280x720及以下，并且建议适用设备在iPhone4S以上。
    [session setSessionPreset:AVCaptureSessionPreset1280x720];
    [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [self.previewLayer setBackgroundColor:[[UIColor grayColor] CGColor]];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    CALayer *rootLayer = [self.view layer];
    [rootLayer setMasksToBounds:YES];
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = ImageFrameWidth * screenWidth / ImageFrameHeight ;
    if ([[UIScreen mainScreen] bounds].size.height>= 812) {
        height = 812;
    }
    [self.previewLayer setFrame:CGRectMake(0,0,screenWidth,height)];
    [rootLayer addSublayer:self.previewLayer];
    [session startRunning];
//    if (self.avaudioScanIDCardOnly) {
//        [self.captureSession startRunning];
//    }
}

- (void)setupBorderView
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;

    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake((screenSize.width - BorderWidth)/2, (screenSize.height - BorderHeight)/2, BorderWidth, BorderHeight)];
    borderView.layer.borderColor = [UIColor colorWithHexString:@"107FE0"].CGColor;
    borderView.layer.borderWidth = 1.0f;
    borderView.layer.masksToBounds = YES;
    self.borderView = borderView;
    [self.previewLayer addSublayer:borderView.layer];
}

- (void)setupOtherThings
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self.view addGestureRecognizer:tapGesture];
    if (_isForMirror) {
        [self configUIWithNoTitle];
    }

}

- (void)didTap:(UITapGestureRecognizer *) tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateBegan)
    {
        [self focus];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    SOSWeakSelf(weakSelf);
    CFRetain(sampleBuffer);
    CGFloat scale = ImageFrameHeight /[UIScreen mainScreen].bounds.size.width;
    dispatch_async_on_main_queue(^{
        CGRect rect = CGRectMake(weakSelf.borderView.frame.origin.y * scale, (weakSelf.previewLayer.frame.size.width - CGRectGetMaxX(weakSelf.borderView.frame)) * scale, weakSelf.borderView.frame.size.height * scale, weakSelf.borderView.frame.size.width * scale);
        [[ISIDCardReaderController sharedISOpenSDKController] detectCardWithOutputSampleBuffer:sampleBuffer cardRect:rect detectCardFinishHandler:^(int result, NSArray *borderPointsArray) {
            if (result > 0)
            {
                dispatch_async_on_main_queue(^{
                    [weakSelf.cardBorderLayer removeFromSuperlayer];
                    weakSelf.cardBorderLayer = nil;
                });
            }
            else
            {
                dispatch_async_on_main_queue(^{
                    [weakSelf.cardBorderLayer removeFromSuperlayer];
                    weakSelf.cardBorderLayer = nil;
                });
            }
        } recognizeCardFinishHandler:^(NSDictionary *cardInfo) {
            [weakSelf.captureSession stopRunning];
            dispatch_async_on_main_queue(^{
                SOSScanResult * result = [[SOSScanResult alloc] init];
                result.resultImg = [cardInfo valueForKey:kOpenSDKCardResultTypeOriginImage];
                if (weakSelf.avaudioScanIDCardFront) {
                    result.resultText = [[cardInfo valueForKey:kOpenSDKCardResultTypeCardItemInfo] valueForKey:kCardItemIDNumber];
                    result.fullNameText = [[cardInfo valueForKey:kOpenSDKCardResultTypeCardItemInfo] valueForKey:kCardItemName];
                    result.genderText = [[cardInfo valueForKey:kOpenSDKCardResultTypeCardItemInfo] valueForKey:kCardItemGender];
                    result.addressText = [[cardInfo valueForKey:kOpenSDKCardResultTypeCardItemInfo] valueForKey:kCardItemAddress];
                    
                }
                else
                {
                    result.resultText = [[cardInfo valueForKey:kOpenSDKCardResultTypeCardItemInfo] valueForKey:kCardItemValidity];
                }
                if (weakSelf.scanIDCardBlock) {
                    weakSelf.scanIDCardBlock(result);
                    weakSelf.scanIDCardBlock = nil;
                }
            });
        }];
    
    CFRelease(sampleBuffer);
    });
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.captureSession startRunning];
    [self.cardNumberLayer removeFromSuperlayer];
    self.cardNumberLayer = nil;
}

//- (void)drawBorderRectWithBorderPoints:(NSArray *)borderPoints onCardBorderLayer:(BOOL)flag
//{
//    if ([borderPoints count] >= 4)
//    {
//        CGPoint point1 = [self convertBorderPointsInImageToPreviewLayer:[[borderPoints objectAtIndex:0] CGPointValue]];
//        CGPoint point2 = [self convertBorderPointsInImageToPreviewLayer:[[borderPoints objectAtIndex:1] CGPointValue]];
//        CGPoint point3 = [self convertBorderPointsInImageToPreviewLayer:[[borderPoints objectAtIndex:2] CGPointValue]];
//        CGPoint point4 = [self convertBorderPointsInImageToPreviewLayer:[[borderPoints objectAtIndex:3] CGPointValue]];
//        
//        CAShapeLayer *line = [CAShapeLayer layer];
//        UIBezierPath *linePath = [UIBezierPath bezierPath];
//        [linePath moveToPoint:point1];
//        [linePath addLineToPoint:point2];
//        [linePath addLineToPoint:point3];
//        [linePath addLineToPoint:point4];
//        [linePath addLineToPoint:point1];
//        line.path = linePath.CGPath;
//        line.fillColor = nil;
//        line.opacity = 1.0;
//        line.strokeColor = [UIColor blueColor].CGColor;
//        if (flag)
//        {
//            self.cardBorderLayer = line;
//        }
//        else
//        {
//            self.cardNumberLayer = line;
//        }
//        [self.previewLayer addSublayer:line];
//    }
//}

- (CGPoint)convertBorderPointsInImageToPreviewLayer:(CGPoint )borderPoint
{
    //video orientation is landscape
    CGFloat y = borderPoint.x * self.previewLayer.bounds.size.height / ImageFrameWidth;
    CGFloat x = self.previewLayer.bounds.size.width - borderPoint.y * self.previewLayer.bounds.size.width / ImageFrameHeight;
    return CGPointMake(x, y);
}

#define clamp(a) (a>255?255:(a<0?0:a));

- (UIImage *) imageRefrenceFromSampleBuffer:(CMSampleBufferRef) sampleBuffer // Create a CGImageRef from sample buffer data
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    uint8_t *yBuffer = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t yPitch = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    uint8_t *cbCrBuffer = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
    size_t cbCrPitch = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
    
    int bytesPerPixel = 4;
    uint8_t *rgbBuffer = (uint8_t *)malloc(width * height * bytesPerPixel);
    
    for(int y = 0; y < height; y++)
    {
        uint8_t *rgbBufferLine = &rgbBuffer[y * width * bytesPerPixel];
        uint8_t *yBufferLine = &yBuffer[y * yPitch];
        uint8_t *cbCrBufferLine = &cbCrBuffer[(y >> 1) * cbCrPitch];
        
        for(int x = 0; x < width; x++)
        {
            int16_t y = yBufferLine[x];
            int16_t cb = cbCrBufferLine[x & ~1] - 128;
            int16_t cr = cbCrBufferLine[x | 1] - 128;
            
            uint8_t *rgbOutput = &rgbBufferLine[x*bytesPerPixel];
            
            int16_t r = (int16_t)roundf( y + cr *  1.4 );
            int16_t g = (int16_t)roundf( y + cb * -0.343 + cr * -0.711 );
            int16_t b = (int16_t)roundf( y + cb *  1.765);
            
            rgbOutput[0] = 0xff;
            rgbOutput[1] = clamp(b);
            rgbOutput[2] = clamp(g);
            rgbOutput[3] = clamp(r);
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbBuffer, width, height, 8, width * bytesPerPixel, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(quartzImage);
    free(rgbBuffer);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}

- (NSUInteger)stringLengthForUnsignedShortArray:(unsigned short *)target maxLength:(NSUInteger)maxLength
{
    NSUInteger length = 0;
    for (NSUInteger i = 0; i < maxLength; i++)
    {
        if (target[i] == 0)
        {
            break;
        }
        length++;
    }
    
    return length;
}

//- (void)orientationDidChange:(NSNotification *)noti
//{
//    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
//    switch ([[UIDevice currentDevice] orientation])
//    {
//        case UIDeviceOrientationPortrait :
//        {
//            CGFloat width = screenSize.width - 30;
//            CGFloat height = (width * 2) / 3;
//            self.borderView.frame = CGRectMake((screenSize.width - width)/2, (screenSize.height - height)/2, width, height);
//        }
//            break;
//            
//        case UIDeviceOrientationPortraitUpsideDown :
//        {
//            CGFloat width = screenSize.width - 30;
//            CGFloat height = (width * 2) / 3;
//            self.borderView.frame = CGRectMake((screenSize.width - width)/2, (screenSize.height - height)/2, width, height);
//        }
//            break;
//            
//        case UIDeviceOrientationLandscapeLeft :
//        {
//            self.borderView.frame = CGRectMake((screenSize.width - BorderWidth)/2, (screenSize.height - BorderHeight)/2, BorderWidth, BorderHeight);
//        }
//            break;
//            
//        case UIDeviceOrientationLandscapeRight :
//        {
//            self.borderView.frame = CGRectMake((screenSize.width - BorderWidth)/2, (screenSize.height - BorderHeight)/2, BorderWidth, BorderHeight);
//        }
//            break;
//            
//        default:
//            break;
//    }
//}

@end
