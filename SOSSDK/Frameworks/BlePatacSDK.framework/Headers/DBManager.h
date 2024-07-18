//
//  DBManager.h
//  LeftSlide
//
//  Created by shudingcai on 3/23/17.
//
//  数据库管理

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Keyinfo.h"
#import "Userinfo.h"
typedef void (^KeyDBOperateResult)(BOOL b , NSError *error);  // 操作数据库结果的Block
@interface DBManager : NSObject


@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, strong) NSString *currentDBName;
@property (nonatomic, strong) NSString *filePath; //


/**
 *  单例
 *
 *  @return
 */
+(instancetype)sharedInstance;
-(BOOL )GetHasUsedKeyInDB;


- (NSManagedObjectContext *)managedObjectContext:(NSString *)dbName;
-(NSArray *)GetSomeKeyInDB:(int)keyNumber;
-(void)UseThisKeyellData:(NSString * )VkNo  Result:(KeyDBOperateResult)block;

-(void)AddOneCarKeyIntoDB:(Keyinfo  *)cakkey Result:(KeyDBOperateResult)block;
-(void)DeleteOneCarKeyInDB:(NSString * )VkNo  Result:(KeyDBOperateResult)block;
-(NSFetchedResultsController *)fetchedResultsController:(NSString *)username;
-(void)UpdateOneCarKeyIntoDB:(Keyinfo  *)cakkey  Result:(KeyDBOperateResult)block;








@end

