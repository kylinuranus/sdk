//
//  TrackManager.m
//  Onstar
//
//  Created by 梁元 on 2022/12/14.
//  Copyright © 2022 Shanghai Onstar. All rights reserved.
//

#import "SOSTrackManager.h"
#import "SOSNetRepository.h"
#import "SOSDbRepository.h"
#import "SOSTrackEvent.h"
#import "SOSTrackConfig.h"
#import "SOSDbRepository.h"


#define weakself __weak typeof(self) weakself = self;

@interface SOSTrackManager(){

    NSTimer *_timeRef;
}

@property(nonatomic,strong)   SOSNetRepository *netRepository;
@property(nonatomic,strong)   SOSTrackConfig *configRef;
@property(nonatomic,strong)   SOSDbRepository *dbRepository;
 
@end




@implementation SOSTrackManager

+ (SOSTrackManager *)sharedInstance
{
    static SOSTrackManager *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [[self alloc] init];
    });
    return sharedOBJ;
}



-(void) initConfig:(SOSTrackConfig*) config{
 
    self.configRef=config;
        
       //初始化网络库
    self.netRepository =[SOSNetRepository sharedInstance];
    [self.netRepository  setConfig:self.configRef];
         
        
        //初始化数据库
        self.dbRepository = [SOSDbRepository sharedInstance];
        
        
        //初始化定时器
        [self timeStart];
}



-(void) timeStart{
     
    _timeRef = [NSTimer scheduledTimerWithTimeInterval:self.configRef.timePeriod
                                    target:self
                                  selector:@selector(timeHandle)
                                  userInfo:nil
                                   repeats:YES];
    
    
    
    [[NSRunLoop currentRunLoop] addTimer:_timeRef forMode:NSDefaultRunLoopMode];
    
}

-(void) timeHandle{
    
    __weak typeof(self) weakSelf = self;
    
     //从数据库读取数据 ,并且是非实时的
    NSArray *array= [ weakSelf.dbRepository query:weakSelf.configRef.countLimit==0?200:weakSelf.configRef.countLimit];
      
    if(array.count>0){

        //开始上传数据到接口
        [weakSelf.netRepository upload:array success:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.dbRepository deleteData:array]; //成功,从本地数据库删除数据,不成功会走下次上报

        } failure:^(NSInteger statusCode, NSString * _Nonnull responseStr) {
            //等待下次上报
        }];
    }
    
}


-(void) track:(SOSTrackEvent*)model{
    
    __weak typeof(self) weakSelf = self;
    //先写入数据 ,然后在写入接口
    [weakSelf.dbRepository add:model];
 
    if(model.isImmediately){//实时
    
        NSMutableArray *array=[NSMutableArray new];
        [array addObject:model];
        
        //上传接口
        [weakSelf.netRepository upload:array
                      success:^{
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            //成功 ,删除数据库
           [strongSelf.dbRepository deleteData:array.copy];
            
        } failure:^(NSInteger statusCode, NSString * _Nonnull responseStr) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            //将实时参数清除,等待下次上报
            model.isImmediately=false;
            [strongSelf.dbRepository updateImmediately:model];
            
        }];
        
      
    }else{//非实时
        
       //检查定时器是否有效
        
        if(!_timeRef.isValid){//无效,则重新开启
            
            [weakSelf timeStart];
        }
         
    }
    
   
    
}
 

 



@end
