//
//  SOSOilGanSelectChildVC.m
//  Onstar
//
//  Created by Coir on 2019/9/1.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSOilDataTool.h"
#import "SOSOilGunSelectCell.h"
#import "SOSOilGanSelectChildVC.h"

@interface SOSOilGanSelectChildVC () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) UIImageView *loadingImgView;
@property (nonatomic, strong) NSArray <NSString *> *dataSourceArray;

@end

@implementation SOSOilGanSelectChildVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SOSOilGunSelectCell" bundle:[NSBundle SOSBundle]] forCellWithReuseIdentifier:@"SOSOilGunSelectCell"];
    
}

- (void)viewWillAppear:(BOOL)animated	{
    [super viewWillAppear:animated];
    [self requestOilGanInfo];
    
}

- (void)requestOilGanInfo   {
    if (self.dataSourceArray) 	{
        self.dataSourceArray = @[];
        return;
    }
    [self showLoadingView];
    [SOSOilDataTool requestOilGunNumListWithStationId:self.stationOilInfo.gasId OilName:self.stationOilInfo.oilName Success:^(NSArray<NSString *> * _Nonnull gunNumList) {
        self.dataSourceArray = gunNumList;
        dispatch_async_on_main_queue(^{
            [self.collectionView reloadData];
            [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [self stopLoadingView];
        });
    } Failure:^{
        dispatch_async_on_main_queue(^{
            [self stopLoadingView];
        });
    }];
}

- (void)showLoadingView		{
    if (self.loadingImgView == nil) {
        self.loadingImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Trip_LBS_List_Loading"]];
        [self.view addSubview:self.loadingImgView];
        self.loadingImgView.center = CGPointMake(self.view.width / 2, self.view.height / 2);
    }
    [self.loadingImgView startRotating];
}

- (void)stopLoadingView		{
    [self.loadingImgView endRotating];
    [self.loadingImgView removeFromSuperview];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SOSOilGunSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SOSOilGunSelectCell" forIndexPath:indexPath];
    cell.title = self.dataSourceArray[indexPath.row];
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath	{
    SOSOilGunSelectCell *cell = (SOSOilGunSelectCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectState = YES;
    self.selectedGunNo = cell.title;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath	{
    SOSOilGunSelectCell *cell = (SOSOilGunSelectCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectState = NO;
}

@end
