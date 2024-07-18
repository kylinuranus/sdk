//
//  FoldingTableView.h
//  Onstar
//
//  Created by Joshua on 6/9/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoldingTableView : UITableView

@property (nonatomic) NSInteger expandedIndex;
- (void)shrinkAndExpand:(NSInteger)section;
@end
