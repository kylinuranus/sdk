//
//  SOSIMCollectionViewFlowLayout.h
//  Onstar
//
//  Created by TaoLiang on 2018/8/17.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSIMTagsDecorationView : UICollectionReusableView

@end

@interface SOSIMTagsCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, strong) UIColor *backgroundColor;

@end


@interface SOSIMCollectionViewFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *decorationViewAttrs;

@end

