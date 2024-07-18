//
//  UITableView+Category.m
//  TCA_iPad
//
//  Created by Creolophus on 7/6/16.
//  Copyright © 2016 Creolophus. All rights reserved.
//

#import "UITableView+Category.h"

@implementation UITableView (Category)
- (void)registerClass:(Class)cellClass{
    [self registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
}

- (void)registerClasses:(NSArray<Class> *)classes {
    [classes enumerateObjectsUsingBlock:^(Class  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self registerClass:obj];
    }];
}

- (void)registerNib:(Class)cellClass{
    [self registerNib:[UINib nibWithNibName:NSStringFromClass(cellClass) bundle:nil] forCellReuseIdentifier:NSStringFromClass(cellClass)];
}
- (void)registerSectionHeaderClass:(Class)cellClass{
    [self registerClass:cellClass forHeaderFooterViewReuseIdentifier:NSStringFromClass(cellClass)];
}

@end
