//
//  JSCallOc.h
//  FreeRDP
//
//  Created by conan on 2018/7/27.
//
//

#import <Foundation/Foundation.h>
#import "JSCallOcProtocol.h"
#import "vminfo.h"

@interface JSCallOc : NSObject<JSCallOcProtocol>
@property(nonatomic,strong)NSMutableDictionary *dic; //私有变量

-(void)AcceptTheDataFromJs:(NSString *)data; //接收json数据解析并且保存到vminfo中
-(void)AcceptUidAndKeepHeartBeat:(NSString *)data;
-(void)StopHeartBeat:(id)num;



@end
