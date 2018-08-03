//
//  vminfo.m
//  FreeRDP
//
//  Created by conan on 16/1/8.
//
//

#import "vminfo.h"

static vminfo *myvminfo;
@implementation vminfo

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized (self) {
        if(myvminfo == nil)
        {
            myvminfo=[super allocWithZone:zone];
        }
    }
    
    return myvminfo;
}

+(instancetype) share{
    return [[self alloc] init];
}




@end
