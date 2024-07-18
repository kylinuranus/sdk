//
//  BaseTableViewCell.h
//  RegisterCellTest
//
//  Created by jieke on 2019/6/9.
//  Copyright © 2019 jieke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BaseTableViewCellProtocol <NSObject>

@required
- (void)configModel:(id)model;
@optional
//- (void)configModel:(id)model indexPath:(NSIndexPath *)indexPath;
- (void)didAction;

@end
