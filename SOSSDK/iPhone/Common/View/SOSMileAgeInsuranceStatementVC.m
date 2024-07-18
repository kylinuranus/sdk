//
//  SOSMileAgeInsuranceStatementVC.m
//  Onstar
//
//  Created by Coir on 2019/9/4.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSMileAgeInsuranceStatementVC.h"

@interface SOSMileAgeInsuranceStatementVC ()

@end

@implementation SOSMileAgeInsuranceStatementVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setFailureBlock:(completedBlock)failureBlock	{
    self.backClickBlock = [failureBlock copy];
}

- (IBAction)agreeButtonTapped {
    if (self.successBlock) {
        self.successBlock();
    }
}

@end
