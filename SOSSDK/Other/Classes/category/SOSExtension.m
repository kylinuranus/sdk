//
//  SOSExtension.m
//  SOSSDK
//
//  Created by onstar on 2018/1/8.
//

#import "SOSExtension.h"

@implementation SOSExtension

@end


@implementation UIImage (SOSExtension)

+ (void)load {
    [self swizzleClassMethod:@selector(imageNamed:) with:@selector(SOS_ImageNamed:)];
}

+ (UIImage *)SOS_ImageNamed:(NSString *)name {
    
    UIImage *image = [UIImage imageNamed:name
                                inBundle:[NSBundle SOSBundle]
           compatibleWithTraitCollection:nil];
    return image?:[self SOS_ImageNamed:name];
}

@end

@implementation UIViewController (SOSExtension)

+ (void)load {
    [self swizzleInstanceMethod:@selector(viewWillAppear:) with:@selector(sos_viewWillAppear:)];
    [self swizzleInstanceMethod:@selector(initWithNibName:bundle:) with:@selector(sos_InitWithNibName:bundle:)];

}

- (void)sos_viewWillAppear:(BOOL)animated {
    NSLog(@"ONSTAR:%@",self.className);
    return [self sos_viewWillAppear:animated];
}

- (instancetype)sos_InitWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    if (nibBundleOrNil == nil) {
//        nibBundleOrNil = [NSBundle SOSBundle];
//    }
    NSBundle *SOSBundle =[NSBundle SOSBundle];
    if ([SOSBundle pathForResource:nibNameOrNil ofType:@"nib"]) {
        nibBundleOrNil = SOSBundle;
    }
    return [self sos_InitWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}


@end

@implementation UIStoryboard (SOSExtension)

+ (void)load {
    [self swizzleClassMethod:@selector(storyboardWithName:bundle:) with:@selector(SOS_StoryboardWithName:bundle:)];
}

+ (UIStoryboard *)SOS_StoryboardWithName:(NSString *)name bundle:(NSBundle *)storyboardBundleOrNil {
//    if (storyboardBundleOrNil == nil) {
//        storyboardBundleOrNil = [NSBundle SOSBundle];
//    }
    
    NSBundle *SOSBundle =[NSBundle SOSBundle];
    if ([SOSBundle pathForResource:name ofType:@"storyboardc"]) {
        storyboardBundleOrNil = SOSBundle;
    }
    return [self SOS_StoryboardWithName:name bundle:storyboardBundleOrNil];
}

@end


@implementation UINib (SOSExtension)

+ (void)load {
    [self swizzleClassMethod:@selector(nibWithNibName:bundle:) with:@selector(SOS_NibWithNibName:bundle:)];
}

+ (UINib *)SOS_NibWithNibName:(NSString *)name bundle:(NSBundle *)bundleOrNil {
//    if (bundleOrNil == nil) {
//        bundleOrNil = [NSBundle SOSBundle];
//    }
    NSBundle *SOSBundle =[NSBundle SOSBundle];
    if ([SOSBundle pathForResource:name ofType:@"nib"]) {
        bundleOrNil = SOSBundle;
    }
    return [self SOS_NibWithNibName:name bundle:bundleOrNil];
}

@end


@implementation UIApplication (SOSWindow)

- (UIWindow *)sosWindow {
    if (![self getAssociatedValueForKey:_cmd]) {
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.windowLevel = UIWindowLevelNormal + 1;
        window.backgroundColor = [UIColor whiteColor];
        SOS_ONSTAR_WINDOW = window;
    }
    return [self getAssociatedValueForKey:_cmd];
}

- (void)setSosWindow:(UIWindow *)sosWindow {
    
    [self setAssociateValue:sosWindow withKey:@selector(sosWindow)];
}



@end

