//
//  PackageDescription.h
//  Onstar
//
//  Created by Joshua on 5/28/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PackageDescription : UITableViewCell     {
    IBOutlet UIImageView *bottomLine;
    IBOutlet UILabel *header;
    CGFloat contentX;
    __weak IBOutlet UIView *lineV;
}

- (void)setContent:(NSArray *)description;
- (void)setHiddenBottomLine;
- (void)setHeaderX:(CGFloat)x1 contentX:(CGFloat)x2;
@end
