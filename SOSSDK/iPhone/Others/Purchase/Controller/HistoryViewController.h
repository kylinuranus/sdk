//
//  HistoryViewController.h
//  Onstar
//
//  Created by Joshua on 7/14/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PurchaseProxy.h"
#import "FoldingTableView.h"

#define HISTORY_PAGE_SIZE   5

@interface HistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ProxyListener>     {
    IBOutlet FoldingTableView *historyTableView;
    NSMutableArray *historyList;
    NSInteger currentPage;
    BOOL isFresh;
    BOOL hasMore;
    BOOL isFailPage;  // 请求失败页面
    
    CGFloat headerHeight;
    CGFloat descHeight;
}
- (void)loadHistory;
- (void)updateIndex;
- (void)checkMore;
- (void)backButtonClicked:(id)sender;
@end
