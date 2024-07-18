//
//  CarNumInputView.h
//  Onstar
//
//  Created by Coir on 16/5/12.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CarNumInputViewDelegate <NSObject>

@required
- (void)outputStrChanged:(NSString *)output;
- (void)finishInput;

@end

@interface CarNumInputView : UIView

@property (nonatomic, weak) id <CarNumInputViewDelegate> delegate;
-(void)setSelect:(NSString *)str;
@end
