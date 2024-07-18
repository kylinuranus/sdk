//
//  ViewController.m
//  ISVINReaderPreViewSDKDemo
//
//  Created by Simon Liu on 2017/8/3.
//  Copyright © 2017年 xzliu. All rights reserved.
//

#import "SOSVinViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <AudioToolbox/AudioToolbox.h>

#import <ISVINReaderPreviewSDK/ISVINReaderPreviewSDK.h>

#define MOVING_COORDINATES_Y  0


//设置预览区域最终根据像素获取成像比例
#define GoldenSectionRation 0.13

typedef NS_ENUM(NSInteger, ISPreviewExpandOrientation)
{
    ISPreviewExpandOrientationPortait,
    ISPreviewExpandOrientationLandscape
};


@interface SOSVinViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, UIAlertViewDelegate>
{
    
}
//自定义相机
@property (nonatomic, strong) AVCaptureSession *captureSession;
//预览成像区域
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
//预览成像输出
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, assign) NSInteger frameInterval;//识别帧数间隔，默认为系统每秒最小帧数／6，即30帧下为5
@property (nonatomic, assign) NSInteger frameCount;



// get image frame
@property (nonatomic, assign) NSInteger imageFrameWidth;
@property (nonatomic, assign) NSInteger imageFrameHeight;
@property (nonatomic, assign) ISPreviewExpandOrientation expandOrientation;


// custom border frame
@property (nonatomic, strong) CALayer *backGroundLayer;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) NSNumber *isLandScaped;
@property (nonatomic, assign) NSInteger borderWidth;
@property (nonatomic, assign) NSInteger borderHeight;
//预览成像后对取景区域坐标进行设置成像
@property (nonatomic, assign) CGRect borderRectInImage;
@property (nonatomic, assign) CGFloat angle;

//识别结果后显示信息
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UILabel *promptLable;

@property (nonatomic, strong) UIView *statusBarView;
@property (nonatomic, strong) UIButton *startRunBtn;

//vertical screen ；横竖屏切换；switchVertical=YES为横屏Home键在右方； switchVertical=NO为竖屏Home键在下方
@property (nonatomic, assign) BOOL switchVertical;

@end

@implementation SOSVinViewController
{
    
    NSString * _authorizationCode;  //公司名 / 授权码

}
- (void) dealloc
{
    [[ISVINReaderPreViewViewController sharedISOpenSDKController] destructResources];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (instancetype)initWithAuthorizationCode:(NSString *)authorizationCode {
    if (self = [super init]) {
        _authorizationCode = authorizationCode;
//        _authorizationCode = @"26d73c76660b546439492c1960-vagfvt";
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.frameInterval = 3;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.switchVertical = YES;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if (self.captureSession == nil)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString *appKey = _authorizationCode;
            NSString *subAppkey = nil;//reserved for future use
            [[ISVINReaderPreViewViewController sharedISOpenSDKController] constructResourcesWithAppKey:appKey subAppkey:subAppkey finishHandler:^(ISOpenSDKStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(status == ISOpenSDKStatusSuccess)
                    {
                        [self setupAVCapture];
                        [self setupBorderView];
                        [self setupOtherThings];
                        [self focus];
                        if (![self.captureSession isRunning])
                        {
                            self.frameCount = 0;
                            [self.captureSession startRunning];
                        }
                    }
                    else
                    {
                        NSLog(@"Authorize error: %ld", (long)status);
                        [Util showAlertWithTitle:@"Error" message:[NSString stringWithFormat:@"SDK错误：%ld", (long)status] completeBlock:nil];
                    }
                });
            }];
        });
    }
    else
    {
        [self.captureSession startRunning];
    }
}

- (void) focus
{
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

#pragma mark - setupAVCapture
- (void)setupAVCapture
{
    
    AVCaptureSession *session = [AVCaptureSession new];
    //1920*1080 is the suggested size if it is supported by device.
    if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080])
    {
        NSLog(@"AVCaptureSessionPreset1920x1080");
        [session setSessionPreset:AVCaptureSessionPreset1920x1080];
        self.imageFrameWidth = 1920;
        self.imageFrameHeight = 1080;
    }
    else if ([session canSetSessionPreset:AVCaptureSessionPreset640x480])
    {
        NSLog(@"AVCaptureSessionPreset640x480");
        [session setSessionPreset:AVCaptureSessionPreset640x480];
        self.imageFrameWidth = 640;
        self.imageFrameHeight = 480;
    }
    else if ([session canSetSessionPreset:AVCaptureSessionPreset352x288])
    {
        NSLog(@"AVCaptureSessionPreset352x288");
        [session setSessionPreset:AVCaptureSessionPreset352x288];
        self.imageFrameWidth = 352;
        self.imageFrameHeight = 288;
    }
    else
    {
        NSLog(@"failed  setSessionPreset");
        return;
    }
    self.captureSession = session;
    // Select a video device, make an input
    [self selectVideoDeviceMakeInput];
    
}
- (void)selectVideoDeviceMakeInput
{
    NSError *error = nil;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    CMTime minFrame = device.activeVideoMinFrameDuration;
    if (self.frameInterval == 0)
    {
        if (minFrame.value != 0)
        {
            NSInteger result = (NSInteger)(minFrame.timescale / minFrame.value / 6);
            if (result > 0 && result < 50)
            {
                self.frameInterval = result;
            }
        }
    }
    
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if ( [self.captureSession canAddInput:deviceInput] )
        [self.captureSession addInput:deviceInput];
    
    // Make a video data output
    [self customMakeVideoDataOutput];
}

- (void)customMakeVideoDataOutput
{
    self.videoDataOutput = [AVCaptureVideoDataOutput new];
    
    
#warning 请设置当前视频流参数为 kCVPixelFormatType_32BGRA
    NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
                                       [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [self.videoDataOutput setVideoSettings:rgbOutputSettings];
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    
    if ([self.captureSession canAddOutput:self.videoDataOutput])
    {
        [self.captureSession addOutput:self.videoDataOutput];
    }
    [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    
    // Custom camera preview
    [self customCameraPreview];
}

- (void)customCameraPreview
{
    if (self.previewLayer != nil)
    {
        [self.previewLayer removeFromSuperlayer];
    }
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    
    CALayer *rootLayer = [self.view layer];
    [rootLayer setMasksToBounds:YES];
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat scrrenHeight = [[UIScreen mainScreen] bounds].size.height;
    if (screenWidth / self.imageFrameHeight > scrrenHeight / self.imageFrameWidth)
    {
        CGFloat height = self.imageFrameWidth * screenWidth / self.imageFrameHeight ;
        CGRect frameRect = CGRectMake(0, (scrrenHeight - height) / 2 , screenWidth, height);
        
        [self.previewLayer setFrame:frameRect];
        self.expandOrientation = ISPreviewExpandOrientationPortait;
    }
    else
    {
        CGFloat width = self.imageFrameHeight * scrrenHeight / self.imageFrameWidth;
        CGRect frameRect = CGRectMake((screenWidth - width) / 2 , 0, width, scrrenHeight);
        [self.previewLayer setFrame:frameRect];
        self.expandOrientation = ISPreviewExpandOrientationLandscape;
    }
    [rootLayer addSublayer:self.previewLayer];
    [self.captureSession startRunning];
    
    //    [self setUpStatusBarViewType];
}

- (void)setUpStatusBarViewType
{
    if (self.statusBarView != nil)
    {
        [self.statusBarView removeFromSuperview];
    }
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    self.statusBarView = [[UIView alloc] init];
    self.statusBarView.frame = CGRectMake(0, 20, screenWidth, 44);
    self.statusBarView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    [self.previewLayer addSublayer:self.statusBarView.layer];
}

#pragma mark - setupBorderView
- (void)setupBorderView
{
    if (self.previewLayer == nil)
    {
        return;
    }
    self.angle = 0;
    
    [self customScreenConversionHorizontal:self.switchVertical];
    
}

// Custom screen conversion is vertical
- (void)customScreenConversionHorizontal:(BOOL)verticalBool
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;
    BOOL isLandScaped = verticalBool;
    
    if (self.isLandScaped != nil && [self.isLandScaped boolValue] == isLandScaped)
    {
        return;
    }
    if (self.backGroundLayer != nil)
    {
        [self.backGroundLayer removeFromSuperlayer];
        self.backGroundLayer = nil;
    }
    self.isLandScaped = @(isLandScaped);
    self.borderRectInImage = CGRectZero;
    CGFloat scale = self.imageFrameWidth / self.previewLayer.frame.size.height;
    
    if (isLandScaped)
    {
        if (screenWidth / screenHeight < GoldenSectionRation)
        {
            self.borderWidth = (int)(screenWidth * 2 / 3);
            self.borderHeight = self.borderWidth / GoldenSectionRation;
        }
        else
        {
            self.borderHeight = (int)(screenHeight * 2 / 3);
            self.borderWidth = self.borderHeight * (GoldenSectionRation);
        }
        self.angle = M_PI_2 ;

    }
    else
    {
        if (screenHeight / screenWidth < GoldenSectionRation)
        {
            self.borderHeight = (int)(screenHeight * 7 / 8);
            self.borderWidth = self.borderHeight / GoldenSectionRation;
        }
        else
        {
            self.borderWidth = (int)(screenWidth * 7 / 8);
            self.borderHeight = self.borderWidth * GoldenSectionRation;
        }
    }
    
    //根据图片像素width、height，然后在根据显示区域的尺寸大小(borderWidth、borderHeight) * 对应的缩放比例(scale)，计算出在像素上面需要取景的区域大小
    /*
     MOVING_COORDINATES_Y 设置当前预览区域Y轴上下移动，虽然在肉眼看来是上下移动，但是实际在像素中是X轴，所以也需要在像素中减去相对应的成像X坐标scale*MOVING_COORDINATES_Y
     */

    CGFloat originX = (self.imageFrameWidth - self.borderHeight * scale ) / 2 - scale*MOVING_COORDINATES_Y;
    CGFloat originY = (self.imageFrameHeight - self.borderWidth * scale) / 2;
    self.borderRectInImage = CGRectMake(originX , originY , self.borderHeight * scale, self.borderWidth * scale);

    
    CGRect borderRect = CGRectMake((screenSize.width - self.borderWidth)/2, (screenSize.height - self.borderHeight)/2 - MOVING_COORDINATES_Y, self.borderWidth, self.borderHeight);
    
    UIBezierPath *superPath = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds cornerRadius:0];
    [superPath setUsesEvenOddFillRule:YES];
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:borderRect cornerRadius:10];
    [borderPath setUsesEvenOddFillRule:YES];
    
    [superPath appendPath:borderPath];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = superPath.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
    fillLayer.opacity = 0.3;
    [self.view.layer addSublayer:fillLayer];
    self.backGroundLayer = fillLayer;
    
//    [self customScanDefaultBackGroundImage];
//    [self customStartRuningVideoButton];
    
    if (self.switchVertical == YES)
    {
        self.resultLabel.transform = CGAffineTransformMakeRotation(self.angle);
        self.resultLabel.frame = CGRectMake(borderRect.origin.x+100, borderRect.origin.y, borderRect.size.width,borderRect.size.height);
        
        self.promptLable.transform = CGAffineTransformMakeRotation(self.angle);
        self.promptLable.frame = CGRectMake(borderRect.origin.x+borderRect.size.width/2, borderRect.origin.y, 1,borderRect.size.height);
        
        self.startRunBtn.transform = CGAffineTransformMakeRotation(self.angle);
        self.startRunBtn.frame = CGRectMake(borderRect.origin.x-100, borderRect.origin.y, borderRect.size.width,borderRect.size.width+70);


    }else
        {
            self.resultLabel.transform = CGAffineTransformMakeRotation(self.angle);
            self.resultLabel.frame = CGRectMake(borderRect.origin.x, borderRect.size.height+50, borderRect.size.width,40);
            
            self.promptLable.transform = CGAffineTransformMakeRotation(self.angle);
            self.promptLable.frame = CGRectMake(borderRect.origin.x, borderRect.origin.y+ (borderRect.size.height-1)/2, borderRect.size.width, 1);
        }

}

- (void)customStartRuningVideoButton
{
    self.startRunBtn = [[UIButton alloc] init];
    self.startRunBtn.selected = YES;
    self.startRunBtn.frame = CGRectMake((self.view.frame.size.width - 100 ) / 2, self.view.frame.size.height - 200, 100, 100);
    self.startRunBtn.layer.borderWidth = 1;
    self.startRunBtn.layer.borderColor = [UIColor greenColor].CGColor;
    [self.startRunBtn setTitle:@"暂 停" forState:UIControlStateNormal];
    [self.startRunBtn addTarget:self action:@selector(clickStartRuningButtonMethod:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startRunBtn];

}



- (void)clickStartRuningButtonMethod:(UIButton *)senderBtn
{
    if (senderBtn.selected == YES)
    {
        [self.captureSession stopRunning];
        [self.startRunBtn setTitle:@"开始" forState:UIControlStateNormal];
        self.startRunBtn.selected = NO;
    }else
        {
            self.resultLabel.text = @"  识别结果显示";

            [self.captureSession startRunning];
            [self.startRunBtn setTitle:@"暂停" forState:UIControlStateNormal];
            self.startRunBtn.selected = YES;
        }
    
}
//Custom scan default background image
- (void)customScanDefaultBackGroundImage
{
    if (self.imageView == nil)
    {
        UILabel *retLabel = [[UILabel alloc] init];
        retLabel.backgroundColor = [UIColor clearColor];
        retLabel.layer.borderColor = [UIColor greenColor].CGColor;
        retLabel.layer.borderWidth=1.0f;
        retLabel.textColor = [UIColor whiteColor];
        retLabel.text = @"  识别结果显示";
        retLabel.font = [UIFont systemFontOfSize:13.0f];
        [self.view addSubview:retLabel];
        self.resultLabel = retLabel;
        [self customScanAxleWire];
    }
}

- (void)customScanAxleWire
{
    if (self.imageView == nil)
    {
        UILabel *retLabel = [[UILabel alloc] init];
        retLabel.backgroundColor = [UIColor greenColor];
        [self.view addSubview:retLabel];
        self.promptLable = retLabel;
    }
}


- (void)setupOtherThings
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self.view addGestureRecognizer:tapGesture];
}


- (void) didTap:(UITapGestureRecognizer *) tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateBegan)
    {
        [self focus];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection	{
    
    CFRetain(sampleBuffer);
    @autoreleasepool {
        
        {
            
            ISHomeOrientationType homeOrientationType ;
            if (self.switchVertical)
            {
                homeOrientationType = ISHomeOrientationTypeRight;
            }else
                {
                    homeOrientationType = ISHomeOrientationTypeDown;
                }
            
            @weakify(self);
            [[ISVINReaderPreViewViewController sharedISOpenSDKController] detectCardWithOutputSampleBuffer:sampleBuffer homeOrientationType:homeOrientationType cardRect:self.borderRectInImage detectCardFinishHandler:^(int result, NSArray *borderPointsArray) {
            
             } recognizeCardFinishHandler:^(NSDictionary *cardInfo)
             {
                 if ([cardInfo count] > 0)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         NSString *keyStr = [[cardInfo allKeys] objectAtIndex:0];
                         NSString *valueStr = cardInfo[keyStr];
                         NSString *resultString;
                         if ([keyStr isEqualToString:@"VIN"])
                         {
                             @strongify(self);
                             if (self.scanVinBlock) {
                                 SOSScanResult *scanValue = [[SOSScanResult alloc] init];
                                 scanValue.resultImg = nil;
                                 scanValue.resultText = valueStr;
                                 self.scanVinBlock(scanValue);
                             }
                             
                             resultString = [NSString stringWithFormat:@"   VIN：%@",valueStr];
                             [self.captureSession stopRunning];
                             [self.startRunBtn setTitle:@"开始" forState:UIControlStateNormal];
                             self.startRunBtn.selected = NO;
                         }
                         self.resultLabel.text = resultString;
                         [self playSound];
                     });
                     
                 }
             }];
        }
        
    }
    
    CFRelease(sampleBuffer);
}

- (UIImage *) imageFromSampleBufferNoCopy:(CMSampleBufferRef) sampleBuffer	{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // Lock the base address of the pixel buffer.
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer.
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height.
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space.
    static CGColorSpaceRef colorSpace = NULL;
    if (colorSpace == NULL)
    {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace == NULL)
        {
            // Handle the error appropriately.
            return nil;
        }
    }
    // Get the base address of the pixel buffer.
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    
    // Create a Quartz direct-access data provider that uses data we supply.
    CGDataProviderRef dataProvider =
    CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    // Create a bitmap image from data supplied by the data provider.
    CGImageRef cgImage =
    CGImageCreate(width,
                  height,
                  8,
                  32,
                  bytesPerRow,
                  colorSpace,
                  kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
                  dataProvider,
                  NULL,
                  true,
                  kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    
    // Create and return an image object to represent the Quartz image.
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}


- (void)saveImageToAblumFinished:(UIImage *)image	{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo	{
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

- (void)playSound{
    //系统声音
    //    AudioServicesPlaySystemSound(1007);
    //震动
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


@end
