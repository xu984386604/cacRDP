setWinAapp();
//先检测是否要自动登录
    var jumpfrom = GetQueryString('isAutoLogin');
    alert(jumpfrom);
    if(jumpfrom == '1'){
        alert(jumpfrom + "again");
        var autologin = localStorage.getItem('autologin');
        if(autologin == 'true'){
            //获取用户的输入
            let username =  localStorage.getItem('user');
            let encryptedPassword = localStorage.getItem('enpw');
            //获取缓存中的ip地址
            let ipstr = localStorage.getItem('ipaddress');
            let authurl = 'http://'+ipstr+'/cu/index.php/Home/Auth/login.html';
            let locationurl = 'http://'+ipstr+'/cu/Public/vue/build/index.php?code=';
            //将信息发给后台验证
            $.ajax({
                url : authurl,
                method : 'post',
                data : {
                            // mac:mac/*终端mac地址*/,
                            type:'Windows',
                            username:username,
                            password:encryptedPassword
                        }
            })
            .then(function(res){
                if(res.code == 800){
                setCUAddress(ipstr);
                window.location.href = locationurl+res.data.code;  
                }
            },function(err){
                console.log('自动登录验证失败啦');
                console.log(err)
            })
        }
    }
 $(function(){
    //检测屏幕的高度
    $('.mask').height($(document).height());
    //先根据缓存渲染select
    renderselect();
    $("#configip").on('click touchstart', function(e){
        let ipstr = document.querySelector('.cs-placeholder').dataset.ipaddress;
        let ipurl = 'http://'+ipstr+'/iplogin/logintest.html';
        let authurl = 'http://'+ipstr+'/cu/index.php/Home/Auth/login.html';
        let locationurl = 'http://'+ipstr+'/cu/Public/vue/build/index.php?code='
        //将按钮设置成loading状态
       $('.y-head-icon').addClass('y-hide');
       if($('#username').length == 0){
         $('.ant-spin').removeClass('y-hide');
       }
       //点击的时候加载html到当前页面
        $.ajax({
                type:'get',            
                url:ipurl,                                           
                data:{},
                timeout : 3000,
                success:function(data,status,xhr){ //请求成功的回调函数
                    　　　if(xhr.status == 200){
                            setTimeout(function(){
                                $('.ant-spin').addClass('y-hide');
                                $('.insertbox').html(data);
                                $('.insertbox').addClass('animated fadeInRight')
                                $('.insertbox').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function () {
                                    $('.insertbox').css('opacity',1);
                                    $('.insertbox').removeClass('animated fadeInRight');
                                })
                                $('.collapse').removeClass('in');
                                //点击登录按钮
                                $('#login').click(function(){
                                    //获取用户的输入
                                    var username = $('#username').val();
                                    var password = $('#password').val();
                                    //这里要对密码进行加密
                                    var encryptedPassword =  encryptPassword(password);
                                    //将信息发给后台验证
                                    $.ajax({
                                        url : authurl,
                                        method : 'post',
                                        data : {
                                                    // mac:mac/*终端mac地址*/,
                                                    type:'Windows',
                                                    username:username,
                                                    password:encryptedPassword
                                                },
                                    })
                                    .then(function(res){
                                        if(res.code == 800){
                                            //用localstorage存储是否自动登录的信息
                                            if($('.ant-checkbox-wrapper').hasClass('ant-checkbox-checked')){
                                                localStorage.setItem('autologin','true');
                                                //localStorage.setItem('ipaddress','')
                                            }else{
                                                localStorage.setItem('autologin','false')
                                            }
                                            //用localstorage存储上一次的ip地址信息
                                            localStorage.setItem('ipaddress',ipstr)
                                            //存localstorage为自动登录做准备
                                            localStorage.setItem('user',username);
                                            localStorage.setItem('enpw',encryptedPassword);
                                            //进行地址跳转
                                           setCUAddress(ipstr);
                                            window.location.href = locationurl+res.data.code;
                                            
                                        }
                                    },function(err){
                                        console.log('验证失败啦');
                                        console.log(err)
                                    })

                                })
                            },300)
                        

                        }
            　　},
            　　complete : function(XMLHttpRequest,status){ //请求完成后最终执行参数
        　　　　     if(status=='timeout' || status== 'error'){//超时,status还有success,error等值的情况
                        console.log('ip地址无法访问1')
                        if($('#username').length !== 0){
                            $('.insertbox').addClass('animated fadeOutRight')
                            $('.insertbox').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function () {
                                $('.insertbox').css('opacity',0);
                                $('.insertbox').removeClass('animated fadeOutRight');
                                $('.insertbox').html('');
                                $('.ant-spin').addClass('y-hide');
                                $('.y-head-icon').removeClass('y-hide');
                            })
                        }else{
                            setTimeout(function(){
                                $('.ant-spin').addClass('y-hide');
                                $('.y-head-icon').removeClass('y-hide');
                            },300)
                            
                        }
                        
                        var tiphtml = "<div class='bugtip'>ip地址无法访问</div>"
                            $('.select-box').append(tiphtml);
                            setTimeout(function(){
                                $('.bugtip').remove();
                            },800)
                        return;
            　　    }
                }
        })

    })
    $(window).resize(function(){
        $('.mask').height($(document).height());
    }); 
    
})



function operationData(myurl,method,data){
    return $.ajax({
                type:method,            
                url:myurl,                                           
                data:data,
                timeout : 1000,
            })
}
function operationDatatest(myurl,method){
    return $.ajax({
                type:method,            
                url:myurl,
            })
}
function renderselect(){

    [].slice.call( document.querySelectorAll( 'select.cs-select' ) ).forEach( function(el) {	
        console.log(el)
        new SelectFx(el);
    } );

}
function isfocus(){
    if($('.double-input-box').hasClass('y-focus')){
        return true;
    }else{
        return false;
    }
}
function hasParent( e, p ) {
    if (!e) return false;
    var el = e.target||e.srcElement||e||false;
    while (el && el != p) {
        el = el.parentNode||false;
    }
    return (el!==false);
};

//判断ip地址是否合法
function isValidIP(ip) {
    var reg = /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/;
    return reg.test(ip);
} 

//判断用户名和密码是否为空
function isValidinput(data){
    
}

//与客户端通信，向客户端发送当前打开的ip地址
function setCUAddress(ipurl){
    window.app.setCUAddress(JSON.stringify({url:ipurl}))
};

//与安卓端通信，确定页面跳转方向
function getjumpfrom(){
    return window.app.getjumpfrom()
}

//判断客户端是否是ios
function isios(){
    var u = navigator.userAgent;
    var isiOS = !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/);
    return isiOS;
}

//与ios通信，ios调用该函数，确定页面方向
function insertIntoLocal(flag){
    ipstatus = flag;
}

//与ios通信，让ios调用页面上的insertIntoLocal函数，确定页面的跳转方向
function setFlag(){
    window.app.setFlag();

}

//window端设置window.app对象
function setWinAapp(){
    /*连接windows客户端时与其建立通道，获得app对象*/
    if(navigator.userAgent.indexOf('Windows') !=-1){
        var script = document.createElement('script');
        script.src = "./static/js/qwebchannel.js";
        document.body.appendChild(script);
        var buildChannel = function(){
            if(typeof QWebChannel != 'undefined'){
                new QWebChannel(qt.webChannelTransport,function(channel){
                    window.channel = channel;
                    window.app = channel.objects.app;
                    app.hideHomeButton();
                    console.log(channel);
                })
            }
        }
        buildChannel();
    }
}

function GetQueryString(name)
{
     var reg = new RegExp("(^|&)"+ name +"=([^&]*)(&|$)");
     var r = window.location.search.substr(1).match(reg);
     if(r!=null)return  unescape(r[2]); return null;
}
