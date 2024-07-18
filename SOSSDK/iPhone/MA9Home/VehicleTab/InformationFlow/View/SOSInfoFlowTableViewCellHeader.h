//
//  SOSInfoFlowTableViewCellHeader.h
//  Onstar
//
//  Created by TaoLiang on 2018/12/12.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#ifndef SOSInfoFlowTableViewCellHeader_h
#define SOSInfoFlowTableViewCellHeader_h
#import "SOSInfoFlowTableViewTailCell.h"
#import "SOSInfoFlowTableViewIMCell.h"
#import "SOSInfoFlowTableViewEmptyCell.h"

static NSArray<Class> *infoFlowCellClasses() {
    return @[SOSInfoFlowTableViewBaseCell.class,
             SOSInfoFlowTableViewTailCell.class,
             SOSInfoFlowTableViewIMCell.class,
             SOSInfoFlowTableViewEmptyCell.class];
}

#endif /* SOSInfoFlowTableViewCellHeader_h */
