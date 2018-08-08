//
//  CuWebViewController.m
//  FreeRDP
//
//  Created by conan on 2018/7/27.
//
//

#import "CuWebViewController.h"


@interface CuWebViewController ()
@property(nonatomic,strong)NSTimer * mytimer; //计时器

@end

@implementation CuWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化 http://172.20.156.109/
    //[vminfo share].cuIp=@"http://172.20.100.11/";
    //innerCuUrl=@"http://172.20.100.11/";
    innerNet=@"1"; //默认外网
    _isNotFirstLoad = NO; //解决页面刷新后或者新请求后出现桥断裂的情况
    [super viewDidLoad];
    
    [self loadLocalHTML:@"ipconfig" inDirectory:@"ipconfig"];
    //判断内外网
    //[self isExternalNetwork];
    
    //注册观察者处理事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openRdp) name:@"openRdp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stoppostMessageToservice:) name:@"stoppostMessageToservice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postMessageToService:) name:@"postMessageToservice" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isExternalNetwork) name:@"isExternalNetwork" object:nil];
    _connectInfo = [vminfo share];
}

#pragma mark 网页加载

/******************
 function: 加载cu网页 内外网判断完后会调用此函数加载
 ******************/
-(void)loadMyWebview
{
    NSString *cuurl=[NSString stringWithFormat:@"%@/cu",cuIp];
    NSURLRequest *myrequest=[NSURLRequest requestWithURL:[NSURL URLWithString:cuurl]];
    myWebView=[[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    myWebView.delegate=self;
    [myWebView loadRequest:myrequest];
    [self.view addSubview:myWebView];
}

//加载本地网页
-(void) loadLocalHTML:(NSString*)filename  inDirectory:(NSString*) dirName{
    NSString *htmlString = [[[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"html" inDirectory:dirName]  encoding:NSUTF8StringEncoding error:nil] autorelease];
    myWebView=[[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [myWebView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:dirName]]];
    myWebView.delegate=self;
    [self.view addSubview:myWebView];
}

#pragma mark openrdp
/*********************
    function:用来打开rdp
 ********************/
-(void)openRdp
{
    ComputerBookmark *bookmark = [[[ComputerBookmark alloc] initWithBaseDefaultParameters] autorelease];

    [[bookmark params] setValue:_connectInfo.remoteProgram  forKey:@"remote_program"];
    [[bookmark params] setValue:_connectInfo.vmusername forKey:@"username"];
    [[bookmark params] setValue:_connectInfo.vmpasswd forKey:@"password"];
    [[bookmark params] setValue:_connectInfo.vmip forKey:@"hostname"];
    [[bookmark params] setValue:_connectInfo.vmport forKey:@"port"];
    //根据gatewaycheck来确定是否网关检验
    if([_connectInfo.gatewaycheck isEqualToString:@"YES"])
    {
        [[bookmark params] setValue:@"YES" forKey:@"enable_tsg_settings"];
        [[bookmark params] setValue:_connectInfo.tsip forKey:@"tsg_hostname"];
        [[bookmark params] setValue:_connectInfo.tsport forKey:@"tsg_port"];
        [[bookmark params] setValue:_connectInfo.tsusername forKey:@"tsg_username"];
        [[bookmark params] setValue:_connectInfo.tspwd forKey:@"tsg_password"];
    }
    //打开的时docker类的应用，要想服务器发送消息
    if([_connectInfo.apptype isEqualToString:@"lca"])
    {
        [self sendMessageToDocker];
    }
    

    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    
    int width =(int) size.width;
    int height =(int) size.height;
    if(height < width) {
        int temp = height;
        height = width;
        width = temp;
    }
    [[bookmark params] setInt:height*2 forKey:@"width"];
    [[bookmark params] setInt:width*2 forKey:@"height"];
    
    NSLog(@"%@",[bookmark params]);
    RDPSession* session = [[[RDPSession alloc] initWithBookmark:bookmark] autorelease];
    RDPSessionViewController* ctrl = [[[RDPSessionViewController alloc] initWithNibName:@"RDPSessionView" bundle:nil session:session] autorelease];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:ctrl animated:YES completion:^{}];
    });
    
    NSLog(@"%@:%@:%@:%@", [vminfo share].appid, [vminfo share].vmusername, [vminfo share].vmip, [vminfo share].uid);
   NSDictionary *jsonData = @{
                 @"appid": [vminfo share].appid,
                 @"vmuser": [vminfo share].vmusername,
                 @"userid": [vminfo share].uid,
                 @"vmip": [vminfo share].vmip
                 };
    NSString *key = [NSString stringWithFormat:@"ios%@", [CommonUtils cNowTimestamp]];
   
    //[[vminfo share].multiRdpSession setObject:session forKey:key]; //多个远程应用需要的操作
    //NSLog(@"存入multiRdpSession的信息：%@", [[vminfo share].multiRdpSession objectForKey:key]);
    [vminfo share].multiRdpRecoverInfo = [NSMutableDictionary dictionary];
    [[vminfo share].multiRdpRecoverInfo setObject:jsonData forKey:key];
    NSLog(@"存入multiRdpRecoverInfo的信息：%@", [[vminfo share].multiRdpRecoverInfo objectForKey:key]);
    //如果之前不存在已打开的应用
    //if ([[vminfo share].multiRdpRecoverInfo count] == 1) {
    //     [[NSNotificationCenter defaultCenter] postNotificationName:@"postMessageToservice" object:@"recoverMsg"];
    //}

    //[vminfo filterRecoverRdpinfoDic];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"postMessageToservice" object:@"recoverMsg"];
}

#pragma mark initJsContext
/******************
   function: 初始化js的环境变量
   ********: webview改变的时候会context会失效,context只能获取到当前webview的环境变量
 ******************/
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self initJSContext:webView];
}

-(void) initJSContext:(UIWebView *)webView{
    context=[webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSCallOc *app=[[JSCallOc alloc] init];
    context[@"app"]=app;
}

#pragma mark 设置第一次启动标志
//判断程序是否是第一次安装启动
//生成唯一的uuid
-(void)isFirstLoad
{
    BOOL tmp=[[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"];
    if(!tmp)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];

        NSString *str = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setValue:str forKey:@"oneloginuuid"];
        NSLog(@"生成uuid");
    }
    else{
    
        NSLog(@"不是第一次启动");
    }
}


#pragma mark heartbeat
-(void)postMessageToService: (NSNotification*) notification
{
    NSString* obj = (NSString*)[notification object];//获取到传递的对象
    
    if ([obj isEqualToString:@"loginMsg"]) {
        [self sendMessage: @"loginMsg"];
        //每个120s发送一次
        if (!_mytimer) {
            _mytimer = [NSTimer scheduledTimerWithTimeInterval:120.0 target:self selector:@selector(sendTimerMessage:) userInfo:@{@"smsType":@"loginMsg"} repeats:YES];
        }
    }
    if ([obj isEqualToString:@"recoverMsg"]) {
        [self sendMessage: @"recoverMsg"];
        //每个300s发送一次
        if (![vminfo share].recoverTimer) {
            [vminfo share].recoverTimer = [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(sendTimerMessage:) userInfo:@{@"smsType":@"recoverMsg"} repeats:YES];
        }
    }
}

//停止发送消息,单点登录的信息在用户注销的时候执行
-(void)stoppostMessageToservice:(NSNotification*) notification
{
    NSString* smsType = (NSString*)[notification object];//获取到传递的对象
    if ([smsType  isEqual: @"recoverMsg"]) {
        [[vminfo share].recoverTimer invalidate];
        [vminfo share].recoverTimer  = nil;
    }
    if ([smsType  isEqual: @"recoverMsg"]) {
        [_mytimer invalidate];
        _mytimer = nil;
    }
    NSLog(@"停止发送%@信息!", smsType);
}

//NStimer的回调方法只能是不带参数的方法或者是带参数但是参数本身只能是NStimer的方法,有多个rdp应用时才适用
-(void)sendTimerMessage:(NSTimer*) timer{
    NSString *smsType = [timer.userInfo objectForKey:@"smsType"];
    [self sendMessage:smsType];
}

-(void)sendMessage:(NSString*) smsType
{
    NSString *ip=[vminfo share].cuIp;
    NSString *handleUrl = [NSString stringWithFormat:@"%@", ip];
    NSMutableDictionary *jsonData = [NSMutableDictionary dictionary];
    NSURL *url=[NSURL URLWithString:handleUrl];
    NSMutableURLRequest *myrequest=[NSMutableURLRequest requestWithURL:url];
    myrequest.HTTPMethod=@"POST";
    [myrequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *mytimestr = [[NSUserDefaults standardUserDefaults] objectForKey:@"oneloginuuid"];
    //NSLog(@"oneloginuuid:%@", mytimestr);
    
    if ([smsType  isEqual: @"loginMsg"]) {
        handleUrl = [handleUrl stringByAppendingString:@"cu/index.php/Home/Client/updateLoginStatus"];
        [jsonData setObject:mytimestr forKey:@"key"];
        [jsonData setObject:@"IOS" forKey:@"type"];
        [jsonData setObject:[vminfo share].uid forKey:@"userid"];
        NSLog(@"准备发送loginMsg信息");
    }
    
    if([smsType  isEqual: @"recoverMsg"]) {
        handleUrl = [handleUrl stringByAppendingString:@"cu/index.php/Home/Client/UpdateAppUseStatus"];
        jsonData = [vminfo share].multiRdpRecoverInfo;
        NSLog(@"准备发送recoverMsg信息");
    }
    
    NSData *sendData = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONWritingPrettyPrinted error:nil];
    myrequest.HTTPBody = sendData;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSURLSessionDataTask *data = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data,NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"发送%@信息成功！", smsType);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"发送信息的请求返回状态码：%ld", (long)httpResponse.statusCode);
        if(data !=nil) {
            if ([smsType  isEqual: @"loginMsg"]) {
                NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:nil];
                NSNumber *mycode=[dic objectForKey:@"code"];
                //如果返回值是800(成功)
                if ([mycode isEqualToNumber:[NSNumber numberWithLong:800]]) {
                    NSLog(@"登陆信息正确");
                }
                else if([mycode isEqualToNumber:[NSNumber numberWithLong:814]])
                {
                    [self callJsLogoff];
                }
            } else if([smsType  isEqual: @"recoverMsg"]) {
                NSLog(@"收到的恢复rdp的返回信息：%@", str);
            }
        }
    }];
    [data resume]; //如果request任务暂停了，则恢复
    //NSData *recvData = [NSURLConnection sendSynchronousRequest:myrequest returningResponse:nil error:nil];
}


//登陆超时处理的函数
-(void)callJsLogoff
{
    NSString *textJS=@"window.client.exit(true);";
    [context evaluateScript:textJS];
    [_mytimer invalidate];
    _mytimer = nil;
}

#pragma mark 判断是否是外网
-(void) isExternalNetwork
{
    NSString * urlStr=[NSString stringWithFormat:@"%@cu/index.php/Home/Client/checkNet",innerCuUrl];
    NSURL *myurl=[NSURL URLWithString:urlStr];
    NSMutableURLRequest *myrequest=[NSMutableURLRequest requestWithURL:myurl];
    myrequest.HTTPMethod=@"GET";
    NSHTTPURLResponse *response;
    NSError *err=nil;
    myrequest.timeoutInterval=3.0;
    
    [NSURLConnection sendSynchronousRequest:myrequest returningResponse:&response error:&err];
    if(!err)
    {
        NSInteger mycode=[response statusCode];
        if(mycode == 200)
        {
            innerNet=@"1";  //是内网
        }else
        {
            innerNet=@"0";   //外网
        }
        
    }else
    {
        innerNet=@"0";   //外网
    }
    //服务器是否让访问
    NSString *urlstr2=[NSString stringWithFormat:@"%@cu/index.php/Home/Client/getServerIp",cuIp];
    NSURL *url2=[NSURL URLWithString:urlstr2];
    NSMutableURLRequest *myrequest2=[NSMutableURLRequest requestWithURL:url2];
    myrequest2.HTTPMethod=@"POST";
    myrequest2.timeoutInterval=3.0;
    
    [myrequest2 setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *json=@{
                         @"innerNet":innerNet
                         };
    
    NSData *data=[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    myrequest2.HTTPBody=data;
    
    NSData *recvData=[NSURLConnection sendSynchronousRequest:myrequest2 returningResponse:nil error:nil];
    
    NSNumber *codenum=nil;
    if (recvData != nil) {
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:recvData options:NSJSONWritingPrettyPrinted error:nil];
        codenum=[dic objectForKey:@"code"];
    }
    
    if([codenum isEqualToNumber:[NSNumber numberWithInteger:800]])
    {
        if([innerNet isEqualToString:@"1"])
        {
            [vminfo share].gatewaycheck=@"NO";
        }else
        {
            [vminfo share].gatewaycheck=@"YES";
        }
        //加载网页
        //[self loadMyWebview];
    }
    
    NSString *msg = [innerNet isEqualToString:@"1"] ? @"内网" : @"外网";
    NSLog(@"当前连接的cu是:%@环境", msg);
}

#pragma mark sendMessageToDocker
/*******************
 
 **function:将docker的信息封装，发送给服务器。
 
 *******************/

-(void)sendMessageToDocker
{
    NSString *Reset_vm_User=[NSString stringWithFormat:@"%@cu/index.php/Home/Client/sendMessageToDockerManager",_connectInfo.cuIp];
    NSURL *url=[NSURL URLWithString:Reset_vm_User];
    NSMutableURLRequest *myrequest=[NSMutableURLRequest requestWithURL:url];
    myrequest.HTTPMethod=@"POST";
    
    [myrequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *json=@{
                         @"action":@"update",
                         @"dockerid":_connectInfo.dockerId,
                         @"ip":_connectInfo.dockerIp,
                         @"userid":_connectInfo.uid,
                         @"appid":_connectInfo.appid
                         };
    
    NSData *data=[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    myrequest.HTTPBody=data;
    
    [NSURLConnection sendSynchronousRequest:myrequest returningResponse:nil error:nil];
    
}


#pragma mark -
#pragma mark 支付宝相关方法

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *reqUrl = request.URL;
    NSString* urlStr =[reqUrl.absoluteString stringByRemovingPercentEncoding];
    //支付宝进入支付环节经历的网址跳转的8个步骤
    //1. https://openapi.alipay.com/gateway.do?charset=UTF-8
    //2. https://unitradeprod.alipay.com/appAssign.htm?alipay_exterface_invoke_assign_target=invoke_f92939685a8a14b982d324a9bc1f6e1e&alipay_exterface_invoke_assign_sign=e_al9k8_jk4r7_pxonth_t0_be_j_m_hvjci_o_gcq_i7_s_e_npm_a_v6er_s47h_vd_t7_iw%3D%3D
    //3. https://unitradeprod.alipay.com/appAssign.htm?alipay_exterface_invoke_assign_target=invoke_f92939685a8a14b982d324a9bc1f6e1e&alipay_exterface_invoke_assign_sign=e_al9k8_jk4r7_pxonth_t0_be_j_m_hvjci_o_gcq_i7_s_e_npm_a_v6er_s47h_vd_t7_iw%3D%3D
    //4. https://excashier.alipay.com/standard/auth.htm?payOrderId=c9d7941465ae41509c643f532e64bfb5.60
    //5. about:blank
    //6. about:blank
    //7. alipays://platformapi/startApp?appId=10000007&sourceId=excashierQrcodePay&actionType=route&qrcode=https%3A%2F%2Fqr.alipay.com%2Fupx00279er7br22tzsny6051
    //8. about:blank
    
    //判断是否是阿里支付的url
    if ([urlStr hasPrefix:@"alipays://"] || [urlStr hasPrefix:@"alipay://"]) {
        //支付宝是否已经安装
        BOOL isExist = [[UIApplication sharedApplication] canOpenURL:reqUrl];
        if (!isExist) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"未检测到支付宝客户端，请安装后重试!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //跳转itune下载支付宝App
                NSString* urlStr = @"https://itunes.apple.com/cn/app/zhi-fu-bao-qian-bao-yu-e-bao/id333206289?mt=8";
                NSURL *downloadUrl = [NSURL URLWithString:urlStr];
                [[UIApplication sharedApplication] openURL:downloadUrl options:[NSDictionary dictionary] completionHandler:^(BOOL success) {
                    NSLog(@"成功打开打开app store!");
                }];
            }]; // end of UIAlertController
            [alert addAction:action];
            //放到主线程中
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:YES completion:^{
                }];
            }); //end of dispatch_async
            _isNotFirstLoad = YES;
        }//end of if
    } else if(![urlStr containsString:@"alipay"] && ![urlStr isEqualToString:@"about:blank"]) {
        if (_isNotFirstLoad) {
            [myWebView removeFromSuperview];
            myWebView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];;
            [self.view addSubview:myWebView];
            myWebView.delegate = self;
            [myWebView loadRequest:request];
            //reset the firstload flag to load the new request
            _isNotFirstLoad = NO;
            return NO;
        }
        _isNotFirstLoad = YES;
    }
    
    return YES;
}

//暂时未使用
- (void)loadWithUrlStr:(NSString*)urlStr
{
    if (urlStr.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURLRequest *webRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]
                                                        cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                    timeoutInterval:30];
            [myWebView loadRequest:webRequest];
        });
    }
}


@end
