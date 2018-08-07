//
//  CuWebViewController.h
//  FreeRDP
//
//  Created by conan on 2018/7/27.
//
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "JSCallOc.h"
#import "vminfo.h"
#import "RDPSessionViewController.h"
#import "CommonUtils.h"


@interface CuWebViewController : UIViewController
{
@private
    JSContext * context;     //js的环境
    NSString * cuIp;       //CU的地址
    NSString * innerCuUrl;  //内网地址
    UIWebView * myWebView;  //加载网页的view
    NSString * innerNet;    //内外网的标志位 1：外网， 0：内网
}
@property(nonatomic,strong) vminfo *connectInfo;

@end
