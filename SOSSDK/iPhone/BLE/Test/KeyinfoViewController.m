//
//  KeyinfoViewController.m
//  BlueTools
//
//  Created by onstar on 2018/6/13.
//  Copyright © 2018年 onstar. All rights reserved.
//

#import "KeyinfoViewController.h"
#import "NSObject+MJKeyValue.h"
#import <BlePatacSDK/DBManager.h>
#import "UIView+Toast.h"

@interface KeyinfoViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation KeyinfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"详情";
    if (self.info) {
         self.textView.text = self.info.mj_JSONString;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"删除此钥匙" style:UIBarButtonItemStylePlain target:self action:@selector(del)];
    }
   
  
}
- (void)del {
    [[DBManager sharedInstance] managedObjectContext:bledbkey];
    
    [[DBManager sharedInstance] DeleteOneCarKeyInDB:_info.vkno Result:^(BOOL b, NSError *error) {
        if (b) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:@"delete ok"];
                [self.navigationController popViewControllerAnimated:YES];
            });
            
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
