//
//  UITableView+Category.h
//  TCA_iPad
//
//  Created by Creolophus on 7/6/16.
//  Copyright © 2016 Creolophus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Category)
//便捷register cell方法
- (void)registerClass:(Class)cellClass;
- (void)registerClasses:(NSArray<Class> *)classes;
- (void)registerNib:(Class)cellClass;

- (void)registerSectionHeaderClass:(Class)cellClass;

@end
