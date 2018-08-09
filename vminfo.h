//
//  vminfo.h
//  FreeRDP
//  用来存储解析xml的数据
//  Created by conan on 16/1/8.
//
//

#import <Foundation/Foundation.h>
#import "client/iOS/Models/RDPSession.h"

@interface vminfo : NSObject

@property (nonatomic, copy) NSString *commonAppId;
//用户信息
@property (nonatomic, copy) NSString *vm;
@property (nonatomic, copy) NSString *vmip;
@property (nonatomic, copy) NSNumber *vmport;
@property (nonatomic, copy) NSString *vmusername;
@property (nonatomic, copy) NSString *vmpasswd;
@property (nonatomic, copy) NSString *remoteProgram;

//网关信息
@property (nonatomic, copy) NSString *gate;
@property (nonatomic, copy) NSString *gatehost;
@property (nonatomic, copy) NSNumber *gateport;
@property (nonatomic, copy) NSString *gateusername;
@property (nonatomic, copy) NSString *gatepasswd;
@property (nonatomic,copy)  NSString *gatewaycheck;


@property (nonatomic, copy) NSString *tsport;
@property (nonatomic, copy) NSString *tsusername;
@property (nonatomic, copy) NSString *tsip;
@property (nonatomic,copy)  NSString *tspwd;

//ct用户的id
@property (nonatomic,copy)  NSString *uid;

//应用类型
@property (nonatomic,copy) NSString * apptype;
//docker类应用的信息
@property (nonatomic,copy) NSString * dockerIp;
@property (nonatomic,copy) NSString * dockerId;
@property (nonatomic,copy) NSString * dockerVncPwd;
@property (nonatomic,copy) NSString * dockerPort;
@property (nonatomic,copy) NSString * appid;


@property (nonatomic,copy) NSString *cuIp;

@property (nonatomic,assign) CGPoint mypoint;


@property(atomic, strong) NSMutableDictionary *multiRdpRecoverInfo; //保存多个远程应用的恢复信息
@property(atomic, strong) NSMutableDictionary *multiRdpSession; //保存多个远程应用session

+(instancetype) share;
+(void) filterRecoverRdpinfoDic;
@end
