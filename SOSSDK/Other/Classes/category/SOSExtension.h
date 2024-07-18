//
//  SOSExtension.h
//  SOSSDK
//
//  Created by onstar on 2018/1/8.
//

#import <Foundation/Foundation.h>

@interface SOSExtension : NSObject

@end


//@interface UIImage (SOSExtension)
//
//@end
//
//@interface UIViewController (SOSExtension)
//
//@end

//@interface UINib (SOSExtension)
//
//@end

@interface UIApplication (SOSWindow)

@property (nonatomic, strong) UIWindow *sosWindow;

@end
