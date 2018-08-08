//
//  CommonUtils.m
//  FreeRDP
//
//  Created by conan on 2018/8/4.
//
//

#import "CommonUtils.h"
#import <netdb.h>
#import <arpa/inet.h>


@implementation CommonUtils

/*
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */

//json格式字符串转字典：
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//字典转json格式字符串
+ (NSString*)dictionaryToJson:(NSDictionary *)dic {
    NSError *parseError = nil;
    NSLog(@"开始字典转json格式字符串");
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

//返回当前时间戳的字符串
+ (NSString *)cNowTimestamp {
    NSDate *newDate = [NSDate date];
    long int timeSp = (long)[newDate timeIntervalSince1970];
    NSString *tempTime = [NSString stringWithFormat:@"%ld",timeSp];
    return tempTime;
}

//判断连接的服务器相对于本机为内网还是外网, -1代表错误，1代表外网，0代表内网
+ (int)isInnerIP:(NSString *)hostName
{
    BOOL bValid = false;
    bool _isInnerIp = false;
    //NSString to char*
    const char *webSite = [hostName cStringUsingEncoding:NSASCIIStringEncoding];
    if (webSite == NULL) {
        return -1;
    }
    // Get host entry info for given host
    struct hostent *remoteHostEnt = gethostbyname(webSite);
    if (remoteHostEnt == NULL) {
        return -1;
    }
    // Get address info from host entry
    struct in_addr *remoteInAddr = (struct in_addr *) remoteHostEnt->h_addr_list[0];
    if (remoteInAddr == NULL) {
        return -1;
    }
    // Convert numeric addr to ASCII string
    char *sRemoteInAddr = inet_ntoa(*remoteInAddr);
    if (sRemoteInAddr == NULL) {
        return -1;
    }
    NSLog(@"sRemoteInAddr:%s", sRemoteInAddr);
    unsigned int ipNum = str2intIP(sRemoteInAddr);
    
    unsigned int aBegin = str2intIP("10.0.0.0");
    unsigned int aEnd = str2intIP("10.255.255.255");
    unsigned int bBegin = str2intIP("172.16.0.0");
    unsigned int bEnd = str2intIP("172.31.255.255");
    unsigned int cBegin = str2intIP("192.168.0.0");
    unsigned int cEnd = str2intIP("192.168.255.255");
    NSLog(@"ipNum:%u", ipNum);
    _isInnerIp = IsInner(ipNum, aBegin, aEnd) || IsInner(ipNum, bBegin, bEnd) || IsInner(ipNum, cBegin, cEnd);
    if(_isInnerIp)  //( (a_ip>>24 == 0xa) || (a_ip>>16 == 0xc0a8) || (a_ip>>22 == 0x2b0) )
    {
        bValid = 0;//内网
    }else{
        bValid = 1;//外网
    }
    return bValid;
}
unsigned int str2intIP(char* strip) //return int ip
{
    unsigned int intIP;
    if(!(intIP = inet_addr(strip)))
    {
        perror("inet_addr failed./n");
        return -1;
    }
    return ntohl(intIP);
}

bool IsInner(unsigned int userIp, unsigned int begin, unsigned int end)
{
    return (userIp >= begin) && (userIp <= end);
}

@end
