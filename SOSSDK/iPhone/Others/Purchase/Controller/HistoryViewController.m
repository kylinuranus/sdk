//
//  HistoryViewController.m
//  Onstar
//
//  Created by Joshua on 7/14/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import "HistoryViewController.h"
#import "LoadingView.h"
#import "OrderRecordHeader.h"
#import "Util.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil     {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad     {
    [super viewDidLoad];
    historyTableView.delegate = self;
    historyTableView.dataSource = self;
    
    historyList = [[NSMutableArray alloc] init];
    isFresh = YES;
    [self loadHistory];
    
    if (ISIPAD) {
        [[LoadingView sharedInstance] setOffset:101.0f];
    }else{
       [[LoadingView sharedInstance] setOffset:61.0f];
    }
    
    historyTableView.backgroundColor = [UIColor clearColor];
}

- (void)viewDidDisappear:(BOOL)animated     {
    [super viewDidDisappear:animated];
    [[PurchaseProxy sharedInstance] removeListener:self];
}

- (void)loadHistory     {
    [self updateIndex];
    
    [[LoadingView sharedInstance] startIn:self.view];
    [[PurchaseProxy sharedInstance] addListener:self];
    [self doLoadHistory];
}

- (void)updateIndex     {
    return;
}

- (void)checkMore     {
    return;
}

- (void)doLoadHistory     {
    return;
}

#pragma mark - proxy delegate
- (void)proxyDidFinishRequest:(BOOL)success withObject:(id)object     {
    [[PurchaseProxy sharedInstance] removeListener:self];
    if (success && [self error] == nil && [self responseList]) {
        [[LoadingView sharedInstance] stop];
        
        if (isFresh) {
            [historyList removeAllObjects];
        }
        [historyList addObjectsFromArray:[self responseList]];
        [self checkMore];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [historyTableView reloadData];

        });
        
    }  else {
         dispatch_async(dispatch_get_main_queue(), ^{
             isFailPage = YES;
             [historyTableView reloadData];
         });
//        [Util showAlertMessage:object withDelegate:self];
    }
}

- (void)backButtonClicked:(id)sender     {
    
}



- (NSArray *)responseList     {
    return nil;
}

- (ErrorInfo *)error     {
    return nil;
}

- (void)didReceiveMemoryWarning     {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView datasource/delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor = [UIColor clearColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView     {
    if ([historyList count] > 0) {
        return [historyList count] + (hasMore ? 1 : 0);
    } else return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section     {
    if (section == historyTableView.expandedIndex) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath     {
    return 132;
//    if (indexPath.section == [historyList count]) {
//        return 72;
//    } else {
//        return indexPath.row == 0 ? headerHeight : descHeight;
//    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath     {
    return;
//    if ([historyList count] == 0) {
//        return;
//    }
//    
//    if (indexPath.section == [historyList count]) {
//        isFresh = NO;
//        [self loadHistory];
//        return;
//    }
//    
//    if (indexPath.row == 0) {
//        
//        if (indexPath.section != historyTableView.expandedIndex) {
//            NSIndexPath *expandedIndex = [NSIndexPath indexPathForRow:0 inSection:historyTableView.expandedIndex];
//            [(OrderRecordHeader *)[tableView cellForRowAtIndexPath:expandedIndex] updateIndicator:NO];
//        }
//        
//        [historyTableView shrinkAndExpand:indexPath.section];
//        [(OrderRecordHeader *)[tableView cellForRowAtIndexPath:indexPath] updateIndicator:(indexPath.section == historyTableView.expandedIndex)];
//    }
}

- (void)dealloc     {
    [historyList removeAllObjects];
}
@end
