//
//  SOSDonateProjectView.m
//  Onstar
//
//  Created by Coir on 2018/9/14.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSDonateProjectView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SOSDonateProjectView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *bgButton;

@property (copy, nonatomic) NSString *activityID;

@end

@implementation SOSDonateProjectView

- (void)configViewWithTiele:(NSString *)title ImgURL:(nonnull NSString *)imgUrlStr AndActivityID:(NSString *)activityID	{
    self.activityID = activityID;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.titleLabel.text = title;
        NSURL *imgUrl = [NSURL URLWithString:imgUrlStr];
        [self.bgButton setBackgroundImageWithURL:imgUrl forState:UIControlStateNormal placeholder:nil];
//        [self.bgButton setBackgroundImageWithURL:imgUrl forState:UIControlStateHighlighted placeholder:nil];
    });
}


- (IBAction)jumpToActivityDetailH5Page {
    NSString *webUrl = [Util getStaticConfigureURL:[NSString stringWithFormat:SOSH5DonateDetailURL, self.activityID]];
    SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:webUrl];
    // 为了埋这个智障的点,只能加这么智障的判断
    if ([self.titleLabel.text isEqualToString:@"贫困小学远程教室项目"]) {
        [SOSDaapManager sendActionInfo:MyDonate_DonatedProject_Classroom];
        webVC.backDaapFunctionID = MyDonate_DonatedProject_Classroom_Back;
    }
    [self.viewController.navigationController pushViewController:webVC animated:YES];
}

@end
