//
//  OCRResultDelegate.h
//  Onstar
//
//  Created by shoujun xue on 4/4/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OCRResultDelegate <NSObject>
-(void)recognitionResultString:(NSString *)resultString;
@end
