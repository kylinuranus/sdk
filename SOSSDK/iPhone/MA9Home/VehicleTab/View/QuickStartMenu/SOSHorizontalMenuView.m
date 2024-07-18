//
//  FMHorizontalMenuView.m
//  YFMHorizontalMenu
//
//  Created by FM on 2018/11/26.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "SOSHorizontalMenuView.h"
#import "UIImageView+WebCache.h"

#define kHorizontalMenuViewInitialPageControlDotSize CGSizeMake(6, 6)

@interface SOSHorizontalMenuViewCell ()

@end

@implementation SOSHorizontalMenuViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.loadingIcon = [UIImageView new];
//        self.loadingIcon.hidden = YES;
//        self.loadingIcon.image = [UIImage imageNamed:@"icon_loading_60x60"];
//        [self.contentView addSubview:self.loadingIcon];
        
//        self.highlightIcon = [UIImageView new];
//        self.highlightIcon.hidden = YES;
//        self.highlightIcon.layer.cornerRadius = 30;
//        self.highlightIcon.clipsToBounds = YES;
//        [self.contentView addSubview:self.highlightIcon];
        
        self.menuIcon = [UIImageView new];
        [self.contentView addSubview:self.menuIcon];
        
        self.menuTile = [UILabel new];
        self.menuTile.textAlignment = 1;
        self.menuTile.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
        self.menuTile.textColor = [SOSUtil onstarBlackColor];
        [self.contentView addSubview:self.menuTile];
        
        self.line = [UIView new];
        self.line.backgroundColor = UIColorHex(DDE8FF);
        [self.contentView addSubview:self.line];
        self.line.hidden = YES;
        [self.menuIcon mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(15);
            make.centerX.mas_equalTo(self.contentView);
            make.centerY.mas_equalTo(self.contentView).mas_offset(-10);
        }];
//        [self.loadingIcon mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.mas_equalTo(self.menuIcon);
//        }];
//        [self.highlightIcon mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.mas_equalTo(self.menuIcon);
//        }];
        
        [self.menuTile mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.contentView);
            if (SOS_BUICK_PRODUCT) {
                make.top.mas_equalTo(self.menuIcon.mas_bottom).offset(0);
            }else{
                make.top.mas_equalTo(self.menuIcon.mas_bottom).offset(-5);

            }
//            make.height.mas_equalTo(18);
        }];
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.mas_equalTo(self.contentView);
            make.top.mas_equalTo(self.contentView).mas_offset(0);
            make.width.mas_equalTo(1/kScreenScale);
        }];
    }
    return self;
}

- (UIImageView *)loadingIcon {
    if (!_loadingIcon) {
        _loadingIcon = UIImageView.new;
        _loadingIcon.hidden = YES;
        _loadingIcon.image = [UIImage imageNamed:@"icon_loading_60x60"];
        [self.contentView addSubview:_loadingIcon];
        [_loadingIcon mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.mas_equalTo(self.menuIcon);
        }];

        [self.contentView sendSubviewToBack:_loadingIcon];
    }
    return _loadingIcon;
}
- (UIImageView *)highlightIcon {
    if (!_highlightIcon) {
        _highlightIcon = [UIImageView new];
        //        self.highlightIcon.hidden = YES;
        _highlightIcon.layer.cornerRadius = 30;
        _highlightIcon.clipsToBounds = YES;
        [self.contentView addSubview:_highlightIcon];
        [_highlightIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.menuIcon);
        }];
        [self.contentView sendSubviewToBack:_highlightIcon];
    }
    return _highlightIcon;
}

- (void)shouldLoading:(BOOL)shouldLoading {
    if (shouldLoading) {
        //用self调用get方法，不存在就创建
        [SOSUtilConfig rotateView:self.loadingIcon];
    }else {
        //直接调用实例，如果不存在也不会创建，导致浪费资源
        [SOSUtilConfig stopRotateAndHideView:_loadingIcon];
    }
}

- (void)setHighlighted:(BOOL)highlighted{
    if (highlighted) {
//        self.menuIcon.image = [UIImage imageNamed:@"Icon_remoteControllocking"];
        self.highlightIcon.image = [UIImage imageWithColor:UIColorHex(#DDE8FF)];
        
    }else{
//        self.menuIcon.image = [UIImage imageNamed:@"Icon_remoteStartCancel"];
        self.highlightIcon.image = nil;

    }
//    self.highlightIcon.highlighted = highlighted;
}
@end

static NSString *FMHorizontalMenuViewCellID = @"FMHorizontalMenuViewCell";
@interface SOSHorizontalMenuView ()<UICollectionViewDelegate,UICollectionViewDataSource,FMHorizontalMenuViewDelegate,EllipsePageControlDelegate>

@property (nonatomic,strong) UICollectionView *collectionView;

@property (strong,nonatomic) UIControl         *pageControl;

@property (strong,nonatomic) SOSHorizontalMenuCollectionLayout         *layout;

@end

@implementation SOSHorizontalMenuView


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _pageControlDotSize = kHorizontalMenuViewInitialPageControlDotSize;
        _pageControlAliment = SOSHorizontalMenuViewPageControlAlimentCenter;
        _pageControlBottomOffset = 0;
        _pageControlRightOffset = 0;
        _controlSpacing = 6;
        _pageControlStyle = SOSHorizontalMenuViewPageControlStyleAnimated;
        _currentPageDotColor = [UIColor colorWithHexString:@"#6896ED"];
        _pageDotColor =[UIColor colorWithHexString:@"#C3CEEC"];
        _hidesForSinglePage = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _pageControlDotSize = kHorizontalMenuViewInitialPageControlDotSize;
        _pageControlAliment = SOSHorizontalMenuViewPageControlAlimentCenter;
        _pageControlBottomOffset = 0;
        _pageControlRightOffset = 0;
        _controlSpacing = 6;
        _pageControlStyle = SOSHorizontalMenuViewPageControlStyleAnimated;
        _currentPageDotColor = [UIColor colorWithHexString:@"#6896ED"];
        _pageDotColor =[UIColor colorWithHexString:@"#C3CEEC"];
        _hidesForSinglePage = YES;

    }
    return self;
}

-(void)setUpPageControl
{
    if (_pageControl) {
        [_pageControl removeFromSuperview];//重新加载数据时调整
    }
    if (([self.layout currentPageCount] == 1) && self.hidesForSinglePage) {//一页并且单页隐藏pageControl
        return;
    }
    switch (self.pageControlStyle) {
        case SOSHorizontalMenuViewPageControlStyleAnimated:
        {
            SOSEllipsePageControl *pageControl = [[SOSEllipsePageControl alloc]init];
            pageControl.numberOfPages = [self.layout currentPageCount];
            pageControl.currentPage = 0;
            pageControl.controlWidth = self.pageControlDotSize.width;
            pageControl.controlSpacing = self.controlSpacing;
            pageControl.currentColor = self.currentPageDotColor;
            pageControl.otherColor = self.pageDotColor;
            pageControl.delegate = self;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
        case SOSHorizontalMenuViewPageControlStyleClassic:
        {
            UIPageControl *pageControl = [[UIPageControl alloc]init];
            pageControl.numberOfPages = [self.layout currentPageCount];
            pageControl.currentPageIndicatorTintColor = self.currentPageDotColor;
            pageControl.pageIndicatorTintColor = self.pageDotColor;
            pageControl.userInteractionEnabled = NO;
            pageControl.currentPage = 0;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
        default:
            break;
    }
    
    //重设pageControlDot图片
    if (self.currentPageDotImage) {
        self.currentPageDotImage = self.currentPageDotImage;
    }
    if (self.pageDotImage) {
        self.pageDotImage = self.pageDotImage;
    }
    
    NSInteger count = self.numOfPage;
    CGFloat pageWidth = (count - 1)*self.pageControlDotSize.width + self.pageControlDotSize.width * 2 + (count - 1) *self.controlSpacing;
    CGSize size = CGSizeMake(pageWidth, self.pageControlDotSize.height);
    CGFloat x = (self.frame.size.width - size.width) * 0.5;
    CGFloat y = self.frame.size.height - size.height;
    if (self.pageControlAliment == SOSHorizontalMenuViewPageControlAlimentRight) {
        x = self.frame.size.width - size.width - 15;
        y = 0;
    }
    if ([self.pageControl isKindOfClass:[SOSEllipsePageControl class]]) {
        SOSEllipsePageControl *pageControl = (SOSEllipsePageControl *)_pageControl;
        [pageControl sizeToFit];
    }
    CGRect pageControlFrame = CGRectMake(x, y, size.width, size.height);
    pageControlFrame.origin.y -= self.pageControlBottomOffset;
    pageControlFrame.origin.x -= self.pageControlRightOffset;
    self.pageControl.frame = pageControlFrame;
    [self addSubview:_pageControl];
    //只写了center的布局
    if (self.pageControlAliment == SOSHorizontalMenuViewPageControlAlimentCenter) {
        [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.bottom.mas_equalTo(self).mas_offset(-2);
            make.width.mas_equalTo(pageWidth);
            make.height.mas_equalTo(self.pageControlDotSize.height);
        }];
    }
    
}

-(UICollectionView *)collectionView{
    
    if (_collectionView == nil) {
        
        //设置layout
        if (self.delegate && [self.delegate respondsToSelector:@selector(layoutInHorizontalMenuView:)]) {
            self.layout = [self.delegate layoutInHorizontalMenuView:self];
        }else{
            self.layout = [SOSHorizontalMenuCollectionLayout new];
        }
        
        //设置行数
        if (self.delegate && [self.delegate respondsToSelector:@selector(numOfRowsPerPageInHorizontalMenuView:)]) {
            self.layout.rowCount = [self.delegate numOfRowsPerPageInHorizontalMenuView:self];
        }else{
            self.layout.rowCount = 2;
        }
        // 设置列数
        if(self.delegate && [self.delegate respondsToSelector:@selector(numOfColumnsPerPageInHorizontalMenuView:)]) {
            self.layout.columCount = [self.delegate numOfColumnsPerPageInHorizontalMenuView:self];
        } else {
            self.layout.columCount = 4;
        }
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        //        _collectionView.scrollEnabled
        [_collectionView registerClass:[SOSHorizontalMenuViewCell class] forCellWithReuseIdentifier:FMHorizontalMenuViewCellID];

        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.bottom.mas_equalTo(-15);
        }];
    }
    return _collectionView;
}

/**
 刷新
 */
-(void)reloadData{
    [self reloadDataSingle];
    [self.collectionView scrollToLeft];
}

-(void)reloadDataSingle{
    //    self.pageControl.numberOfPages = [self.layout pageCount];
    //    self.pageControl.currentPage = 0;
    //设置行数
    if (self.delegate && [self.delegate respondsToSelector:@selector(numOfRowsPerPageInHorizontalMenuView:)]) {
        self.layout.rowCount = [self.delegate numOfRowsPerPageInHorizontalMenuView:self];
    }else{
        self.layout.rowCount = 2;
    }
    dispatch_async_on_main_queue(^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(numOfColumnsPerPageInHorizontalMenuView:)]) {
            self.layout.columCount = [self.delegate numOfColumnsPerPageInHorizontalMenuView:self];
        }
        [self.collectionView reloadData];
        
        [self setUpPageControl];
    });

    
    
}


#pragma mark - properties

- (void)setDelegate:(id<FMHorizontalMenuViewDelegate>)delegate
{
    _delegate = delegate;
    
    if ([self.delegate respondsToSelector:@selector(customCollectionViewCellClassForHorizontalMenuView:)] && [self.delegate customCollectionViewCellClassForHorizontalMenuView:self]) {
        [self.collectionView registerClass:[self.delegate customCollectionViewCellClassForHorizontalMenuView:self] forCellWithReuseIdentifier:FMHorizontalMenuViewCellID];
    }else if ([self.delegate respondsToSelector:@selector(customCollectionViewCellNibForHorizontalMenuView:)] && [self.delegate customCollectionViewCellNibForHorizontalMenuView:self]) {
        [self.collectionView registerNib:[self.delegate customCollectionViewCellNibForHorizontalMenuView:self] forCellWithReuseIdentifier:FMHorizontalMenuViewCellID];
    }
}
#pragma mark - UIScrollViewDelegate -
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.pageControl isKindOfClass:[SOSEllipsePageControl class]]) {
    } else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSInteger currentPage = targetContentOffset->x / self.frame.size.width;
    if ([self.pageControl isKindOfClass:[SOSEllipsePageControl class]]) {
        SOSEllipsePageControl *pageControl = (SOSEllipsePageControl *)_pageControl;
        pageControl.currentPage = currentPage;
    }
    if ([self.delegate respondsToSelector:@selector(horizontalMenuView:WillEndDraggingWithVelocity:targetContentOffset:)]) {
        [self.delegate horizontalMenuView:self WillEndDraggingWithVelocity:velocity targetContentOffset:targetContentOffset];
    }
}
#pragma mark - UICollectionViewDataSource -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger count = 1;
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfSectionsInHorizontalMenuView:)]) {
        count = [self.dataSource numberOfSectionsInHorizontalMenuView:self];
    }
    return count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = 0;
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInHorizontalMenuView:section:)]) {
        count = [self.dataSource numberOfItemsInHorizontalMenuView:self section:section];
    }
    return count;
}

- (SOSHorizontalMenuViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SOSHorizontalMenuViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FMHorizontalMenuViewCellID forIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(setupCustomCell:forIndex:horizontalMenuView:)] &&
        [self.delegate respondsToSelector:@selector(customCollectionViewCellClassForHorizontalMenuView:)] && [self.delegate customCollectionViewCellClassForHorizontalMenuView:self]) {
        [self.delegate setupCustomCell:cell forIndex:indexPath.item horizontalMenuView:self];
        return cell;
        
    }else if ([self.delegate respondsToSelector:@selector(setupCustomCell:forIndex:horizontalMenuView:)] &&
              [self.delegate respondsToSelector:@selector(customCollectionViewCellNibForHorizontalMenuView:)] && [self.delegate customCollectionViewCellNibForHorizontalMenuView:self]) {
        [self.delegate setupCustomCell:cell forIndex:indexPath.item horizontalMenuView:self];
        return cell;
    }
    NSString *title = @"";
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(horizontalMenuView:titleForItemAtIndex:)]) {
        title = [self.dataSource horizontalMenuView:self titleForItemAtIndex:indexPath];
    }
    cell.menuTile.text = title;
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(horizontalMenuView:congfigItem:atIndex:)]) {
        [self.dataSource horizontalMenuView:self congfigItem:cell atIndex:indexPath];
    }
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(horizontalMenuView:iconURLForItemAtIndex:)]) {
        NSURL *url = [self.dataSource horizontalMenuView:self iconURLForItemAtIndex:indexPath];
        if(self.defaultImage) {
            [cell.menuIcon sd_setImageWithURL:url placeholderImage:self.defaultImage];
        } else {
            [cell.menuIcon sd_setImageWithURL:url];
        }
    }else if (self.dataSource && [self.dataSource respondsToSelector:@selector(horizontalMenuView:localIconStringForItemAtIndex:)]){
        NSString *imageName = [self.dataSource horizontalMenuView:self localIconStringForItemAtIndex:indexPath];
        cell.menuIcon.image = [UIImage imageNamed:imageName];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(iconSizeForHorizontalMenuView:index:)]) {
        CGSize imageSize = [self.delegate iconSizeForHorizontalMenuView:self index:indexPath];
        [cell.menuIcon mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(imageSize);
        }];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFontForHorizontalMenuView:index:)]) {
        UIFont *textFont = [self.delegate textFontForHorizontalMenuView:self index:indexPath];
        cell.menuTile.font = textFont;
    }
//    if (indexPath.row ==3) {
//        cell.backgroundColor = [UIColor redColor];
//
//    }
    return cell;
}


#pragma mark - UICollectionViewDelegate -
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.delegate && [self.delegate respondsToSelector:@selector(horizontalMenuView:didSelectItemAtIndex:)]) {
        [self.delegate horizontalMenuView:self didSelectItemAtIndex:indexPath];
    }
}

- (void)setPageControlDotSize:(CGSize)pageControlDotSize
{
    _pageControlDotSize = pageControlDotSize;
    [self setUpPageControl];
}
- (void)setCurrentPageDotColor:(UIColor *)currentPageDotColor
{
    _currentPageDotColor = currentPageDotColor;
    if ([self.pageControl isKindOfClass:[SOSEllipsePageControl class]]) {
        SOSEllipsePageControl *pageControl = (SOSEllipsePageControl *)_pageControl;
        pageControl.currentColor = currentPageDotColor;
    } else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPageIndicatorTintColor = currentPageDotColor;
    }
    
}

- (void)setPageDotColor:(UIColor *)pageDotColor
{
    _pageDotColor = pageDotColor;
    if ([self.pageControl isKindOfClass:[UIPageControl class]]) {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.pageIndicatorTintColor = pageDotColor;
    }else{
        SOSEllipsePageControl *pageControl = (SOSEllipsePageControl *)_pageControl;
        pageControl.otherColor = pageDotColor;
    }
}

- (void)setCurrentPageDotImage:(UIImage *)currentPageDotImage
{
    _currentPageDotImage = currentPageDotImage;
    
    if (self.pageControlStyle != SOSHorizontalMenuViewPageControlStyleAnimated) {
        self.pageControlStyle = SOSHorizontalMenuViewPageControlStyleAnimated;
    }
    
    [self setCustomPageControlDotImage:currentPageDotImage isCurrentPageDot:YES];
}

- (void)setPageDotImage:(UIImage *)pageDotImage
{
    _pageDotImage = pageDotImage;
    
    if (self.pageControlStyle != SOSHorizontalMenuViewPageControlStyleAnimated) {
        self.pageControlStyle = SOSHorizontalMenuViewPageControlStyleAnimated;
    }
    
    [self setCustomPageControlDotImage:pageDotImage isCurrentPageDot:NO];
}

- (void)setCustomPageControlDotImage:(UIImage *)image isCurrentPageDot:(BOOL)isCurrentPageDot
{
    if (!image || !self.pageControl) return;
    
    if ([self.pageControl isKindOfClass:[SOSEllipsePageControl class]]) {
        SOSEllipsePageControl *pageControl = (SOSEllipsePageControl *)_pageControl;
        pageControl.currentBkImg = image;
    }
}

-(NSInteger)numOfPage
{
    return [self.layout currentPageCount];
}

#pragma  mark EllipsePageControlDelegate。监听用户点击 (如果需要点击切换,如果将EllipsePageControl 中的userInteractionEnabled切换成YES或者注掉)
-(void)ellipsePageControlClick:(SOSEllipsePageControl *)pageControl index:(NSInteger)clickIndex{
    CGPoint position = CGPointMake(self.frame.size.width * clickIndex, 0);
    [self.collectionView setContentOffset:position animated:YES];
}

@end
