//
//  PickerViewController.h
//  Onstar
//
//  Created by Joshua on 5/27/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PurchaseCommonDefination.h"

@protocol PickerDelegate <NSObject>

- (void)pickerDidFinished:(BOOL)isDone withSelectedIndex:(NSInteger)index;
@end


@interface PickerViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;
@property (nonatomic, weak) IBOutlet UIToolbar    *finishToolbar;
@property (nonatomic, weak) NSArray *dataList;

@property (nonatomic, assign) SelectionType type;
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, weak) id<PickerDelegate>    pickerDelegate;
@end
