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
    
    // Do any additional setup after loading the view.
    //初始化
    cuIp=@"http://172.20.156.168/";
    innerCuUrl=@"http://172.20.156.168/";
    innerNet=@"1"; //默认外网
    
    [vminfo share].cuIp=cuIp;
    
    
    //判断内外网
    [self is_External_network];
//    [self isFirstLoad];
    
    
    //注册观察者处理事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openRdp) name:@"openRdp" object:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stoppostMessageToservice) name:@"stoppostMessageToservice" object:nil];
    
    _connectInfo = [vminfo share];
}

#pragma mark loadwebview


/******************
 function: 加载cu网页 内外网判断完后会调用此函数加载
 
 ******************/


-(void)loadMyWebview
{
    
    
    NSString *cuurl=[NSString stringWithFormat:@"%@cu",cuIp];
    NSURLRequest *myrequest=[NSURLRequest requestWithURL:[NSURL URLWithString:cuurl]];
    myWebView=[[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    myWebView.delegate=self;
    [myWebView loadRequest:myrequest];
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
-(void)postMessageToService
{
    //启动时就发送消息
    [self sendMessage];
    //每个120s发送一次
    _mytimer=[NSTimer scheduledTimerWithTimeInterval:120.0 target:self selector:@selector(sendeMessage) userInfo:nil repeats:YES];

}

//停止发送消息 用户注销的时候执行
-(void)stoppostMessageToservice
{
    [_mytimer invalidate];
    _mytimer=nil;
}
-(void)sendMessage
{
    NSString *Reset_vm_User=[NSString stringWithFormat:@"%@cu/index.php/Home/Client/updateLoginStatus",cuIp];
    NSURL *url=[NSURL URLWithString:Reset_vm_User];
    NSMutableURLRequest *myrequest=[NSMutableURLRequest requestWithURL:url];
    myrequest.HTTPMethod=@"POST";
    
    [myrequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    //生成一个唯一标示符
    NSString *mytimestr = [[NSUserDefaults standardUserDefaults] objectForKey:@"oneloginuuid"];
    NSLog(@"oneloginuuid:%@", mytimestr);
    NSString *uid=[vminfo share].uid;
    
    //发送的数据
    NSDictionary *json=@{
                         @"key":mytimestr,
                         @"type":@"IOS",
                         @"userid":uid
                         };

    NSData *data=[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    myrequest.HTTPBody=data;
    
    NSData *recvData=[NSURLConnection sendSynchronousRequest:myrequest returningResponse:nil error:nil];
    if(recvData !=nil)
    {
        
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:recvData options:NSJSONWritingPrettyPrinted error:nil];
        NSNumber *mycode=[dic objectForKey:@"code"];
        
        //如果返回值是800 成功
        if ([mycode isEqualToNumber:[NSNumber numberWithLong:800]]) {
            NSLog(@"登陆信息正确");
        }
        else if([mycode isEqualToNumber:[NSNumber numberWithLong:814]])
        {
             //登陆超时处理
            [self callJsLogoff];
        }
    }

}


//登陆超时处理的函数
-(void)callJsLogoff
{
    NSString *textJS=@"window.client.exit(true);";
    [context evaluateScript:textJS];
    [_mytimer invalidate];
    _mytimer=nil;
}

#pragma mark 判断是否是外网
-(void)is_External_network
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
        NSUserDefaults *mydefaults=[[NSUserDefaults alloc] initWithSuiteName:@"group.ct"];
        if([innerNet isEqualToString:@"1"])
        {
          [vminfo share].gatewaycheck=@"NO";
        }else
        {
            [vminfo share].gatewaycheck=@"YES";
        }
        //加载网页
        [self loadMyWebview];
        
    } else
    {
        UIAlertController *myalert=[UIAlertController
                                    alertControllerWithTitle:@"连接错误"
                                    message:@"拒绝连接"
                                    preferredStyle:UIAlertControllerStyleAlert
                                    ];
        UIAlertAction *defaultaction=[UIAlertAction actionWithTitle:@"确定"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                
                                                            }];
        [myalert addAction:defaultaction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:myalert animated:YES completion:nil];
        });
        
        
    }
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






@end
