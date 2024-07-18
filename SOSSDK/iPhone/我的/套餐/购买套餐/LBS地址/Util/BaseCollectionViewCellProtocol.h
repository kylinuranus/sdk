//
//  BaseCollectionViewCellProtocol.h
//  Onstar
//
//  Created by jieke on 2019/7/23.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BaseCollectionViewCellProtocol <NSObject>

@required
- (void)configModel:(id)model;
@optional
//- (void)configModel:(id)model indexPath:(NSIndexPath *)indexPath;
- (void)didAction;

@end
