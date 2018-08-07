//
//  JSCallOc.m
//  FreeRDP
//
//  Created by conan on 2018/7/27.
//
//

#import "JSCallOc.h"

@implementation JSCallOc
/*****************************
 
 **parameter：json数据
 **function：解析并且保存json数据
 
 *****************************/


-(void)AcceptTheDataFromJs:(NSString *)data
{
   NSData *str=[data dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err=nil;
    _dic = [NSJSONSerialization JSONObjectWithData:str options:NSJSONReadingMutableLeaves error:&err];
    NSAssert( _dic!= nil, @"接收到的json数据不能为空！");
    
    NSLog(@"%@",_dic);
   
    //解析json数据保存到vminfo中
    vminfo * myinfo = [vminfo share];
    myinfo.tsip=[_dic objectForKey:@"tsip"];
    myinfo.tsport=[_dic objectForKey:@"tsport"];
    myinfo.tspwd=[_dic objectForKey:@"tspwd"];
    myinfo.tsusername=[_dic objectForKey:@"tsusername"];
    myinfo.vmip=[_dic objectForKey:@"vmip"];
    myinfo.vmport=[_dic objectForKey:@"vmport"];
    myinfo.vmpasswd=[_dic objectForKey:@"vmpsswd"];
    myinfo.vmusername=[_dic objectForKey:@"vmusername"];
    NSString* remoteProgram=[_dic objectForKey:@"remoteProgram"];
    myinfo.appid = [_dic objectForKey:@"id"];
    myinfo.uid = [_dic objectForKey:@"username"];

     //docker应用处理
    NSString *apptype=[_dic objectForKey:@"appType"];
    if([apptype isEqualToString:@"lca"])
    {
        myinfo.dockerId=[_dic objectForKey:@"docker_id"];
        myinfo.dockerIp=[_dic objectForKey:@"docker_ip"];
        myinfo.dockerVncPwd=[_dic objectForKey:@"docker_vncpwd"];
        myinfo.dockerPort=[_dic objectForKey:@"docker_port"];
        myinfo.appid=[_dic objectForKey:@"id"];
        NSString *str1=@"/password";
        remoteProgram=[NSString stringWithFormat:@"%@ %@ %@ %@:%@",remoteProgram,str1,myinfo.dockerVncPwd,myinfo.dockerIp,myinfo.dockerPort];
    }
    
    myinfo.remoteProgram=[NSString  stringWithFormat:@"opener.exe %@", remoteProgram];
    
    
    
    //接收的数据不为空则可以调用来打开RDP
    [self openRdp];
    
}
/*****************************
 
 **parameter：无
 **function：向消息中心发送“openRdp”的消息，cuWebVC中用于处理该事件
 
 *****************************/


-(void)openRdp
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openRdp" object:nil];
}

/*******
 **parameter：json数据
 **function：解析json数据中的uid，向服务器发送心跳
*******/

-(void)AcceptUidAndKeepHeartBeat:(NSString *)data
{
    //解析保存uid
    NSData *str=[data dataUsingEncoding:NSUTF8StringEncoding];
    NSError * err;
    NSDictionary *mydic=[NSJSONSerialization JSONObjectWithData:str options:NSJSONReadingMutableLeaves error:&err];
    NSAssert(mydic!=nil, @"数据为空，解析uid失败!");
    NSString *uid=[mydic objectForKey:@"userid"];
    
    //解析出了uid，通过vminfo共享数据
    [vminfo share].uid=uid;
    //发送通知，向服务器发送消息
    [[NSNotificationCenter defaultCenter] postNotificationName:@"postMessageToservice" object:@"loginMsg"];

}
//注销的时候，停止发送心跳
-(void)StopHeartBeat:(id)num
{
    
     [[NSNotificationCenter defaultCenter] postNotificationName:@"stoppostMessageToservice" object:@"loginMsg"];
}






@end
