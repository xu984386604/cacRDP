if(isios()){
    var ipstatus = "0";
    window.app.setFlag();
    $(function(){
        // $('.maskloading').removeClass('y-hide');

        if(ipstatus !== "1"){
            if(localStorage.getItem('lastip')){
                var ipstr = localStorage.getItem('lastip');
                var ipurl = 'http://'+ipstr+'/cu';
                    $.ajax({
                            type:'get',            
                            url:ipurl,                                           
                            data:{},
                            timeout : 3000,
                            success:function(data,status,xhr){ //请求成功的回调函数
                                　　　if(xhr.status == 200){
                                    getCUAddress('http://'+ipstr+'/');
                                        if(localStorage.getItem('lastip')){
                                            localStorage.setItem('lastip',ipstr);
                                        }else{
                                            localStorage.setItem('lastip',ipstr);
                                        }
                                        window.location.href=ipurl;
    
                                    }
                        　　},
                        　　complete : function(XMLHttpRequest,status){ //请求完成后最终执行参数
                            //$('.maskloading').addClass('y-hide');
                    　　　　if(status=='timeout'){//超时,status还有success,error等值的情况
                                    var tiphtml = "<div class='bugtip'>ip地址无法访问</div>"
                                    $('.select-box').append(tiphtml);
                                    setTimeout(function(){
                                        $('.bugtip').remove();
                                    },800)
                                return;
                        　　    }
                            }
                })
            }else{
                // $('.maskloading').addClass('y-hide');
            }
        }else{
            
        }
             
        //检测屏幕的高度
        $('.mask').height($(document).height());
        //先根据缓存渲染select
        renderselect();
        $(document).on( 'click touchstart', function(ev) {
            
            var target = ev.target;
            if(isfocus() && target !== document.querySelector('.cs-select') && !hasParent( target, document.querySelector('.cs-select') ) ){
                $('div.y-test-box').addClass('y-hide');
                $('div.y-test-box').removeClass('y-show');
                $('.cs-addicon ').addClass('y-hide');
                $('.cs-addicon ').removeClass('y-show');
                $('.y-placeholder').addClass('y-show');
                $('.y-placeholder').removeClass('y-hide');
                $('.cs-options').addClass('y-show');
                $('.cs-options').removeClass('y-hide');
                if($('.cs-placeholder')){
                    $('.cs-placeholder').addClass('y-show');
                    $('.cs-placeholder').removeClass('y-hide')
                }
                $('.double-input-box').removeClass('y-focus');
            }
        } );
        $("#configip").click(function(e){
            var event = e;
            //将按钮设置成loading状态
            addRippleEffect(event);
        })    
          
    })
    
    var addRippleEffect = function (e) {
            var ipstr = $('.y-placeholder').val();
            var reg = /[^:]*:([^:]*)/;
            ipstr=ipstr.replace(reg,"$1");
            var ipurl = 'http://'+ipstr+'/cu';
            $.ajax({
                    type:'get',            
                    url:ipurl,                                           
                    data:{},
                    timeout : 3000,
                    success:function(data,status,xhr){ //请求成功的回调函数
                        　　　if(xhr.status == 200){
                            getCUAddress('http://'+ipstr+'/');
                                if(localStorage.getItem('lastip')){
                                    localStorage.setItem('lastip',ipstr);
                                }else{
                                    localStorage.setItem('lastip',ipstr);
                                }
                                //  $('.maskloading').addClass('y-hide');

                                window.location.href=ipurl;
                            }
                　　},
                　　complete : function(XMLHttpRequest,status){ //请求完成后最终执行参数
            　　　　if(status=='timeout'){//超时,status还有success,error等值的情况
                            console.log('ip地址无法访问1')
                            var tiphtml = "<div class='bugtip'>ip地址无法访问</div>"
                                $('.select-box').append(tiphtml);
                                setTimeout(function(){
                                    $('.bugtip').remove();
                                },800)
                        return;
                　　    }
                    }
            })
       
        return false;
    }
}else{
    var ipstatus = getjumpfrom();
    $(function(){
        // $('.maskloading').removeClass('y-hide');
        if(ipstatus !== '1'){
            if(localStorage.getItem('lastip')){
                var ipstr = localStorage.getItem('lastip');
                var ipurl = 'http://'+ipstr+'/cu';
                    $.ajax({
                            type:'get',            
                            url:ipurl,                                           
                            data:{},
                            timeout : 3000,
                            success:function(data,status,xhr){ //请求成功的回调函数
                                　　　if(xhr.status == 200){
                                    getCUAddress('http://'+ipstr+'/');
                                        if(localStorage.getItem('lastip')){
                                            localStorage.setItem('lastip',ipstr);
                                        }else{
                                            localStorage.setItem('lastip',ipstr);
                                        }
                                        window.location.href=ipurl;
    
                                    }
                        　　},
                        　　complete : function(XMLHttpRequest,status){ //请求完成后最终执行参数
                            //$('.maskloading').addClass('y-hide');
                    　　　　if(status=='timeout'){//超时,status还有success,error等值的情况
                                    var tiphtml = "<div class='bugtip'>ip地址无法访问</div>"
                                        $('.select-box').append(tiphtml);
                                        setTimeout(function(){
                                            $('.bugtip').remove();
                                        },800)
                                return;
                        　　    }
                            }
                })
            }else{
                // $('.maskloading').addClass('y-hide');
            }
        }else{
            // $('.maskloading').addClass('y-hide');
        }
             
        //检测屏幕的高度
        $('.mask').height($(document).height());
        //先根据缓存渲染select
        renderselect();
        $(document).on( 'click touchstart', function(ev) {
            
            var target = ev.target;
            if(isfocus() && target !== document.querySelector('.cs-select') && !hasParent( target, document.querySelector('.cs-select') ) ){
                $('div.y-test-box').addClass('y-hide');
                $('div.y-test-box').removeClass('y-show');
                $('.cs-addicon ').addClass('y-hide');
                $('.cs-addicon ').removeClass('y-show');
                $('.y-placeholder').addClass('y-show');
                $('.y-placeholder').removeClass('y-hide');
                $('.cs-options').addClass('y-show');
                $('.cs-options').removeClass('y-hide');
                if($('.cs-placeholder')){
                    $('.cs-placeholder').addClass('y-show');
                    $('.cs-placeholder').removeClass('y-hide')
                }
                $('.double-input-box').removeClass('y-focus');
            }
        } );
        $("#configip").click(function(e){
            var event = e;
            //将按钮设置成loading状态
            addRippleEffect(event);
        })    
          
    })
    
    var addRippleEffect = function (e) {
            var ipstr = $('.y-placeholder').val();
            var reg = /[^:]*:([^:]*)/;
            ipstr=ipstr.replace(reg,"$1");
            var ipurl = 'http://'+ipstr+'/cu';
            $.ajax({
                    type:'get',            
                    url:ipurl,                                           
                    data:{},
                    timeout : 3000,
                    success:function(data,status,xhr){ //请求成功的回调函数
                        　　　if(xhr.status == 200){
                            getCUAddress('http://'+ipstr+'/');
                                if(localStorage.getItem('lastip')){
                                    localStorage.setItem('lastip',ipstr);
                                }else{
                                    localStorage.setItem('lastip',ipstr);
                                }
                                //  $('.maskloading').addClass('y-hide');

                                window.location.href=ipurl;
                            }
                　　},
                　　complete : function(XMLHttpRequest,status){ //请求完成后最终执行参数
            　　　　if(status=='timeout'){//超时,status还有success,error等值的情况
                            console.log('ip地址无法访问1')
                            var tiphtml = "<div class='bugtip'>ip地址无法访问</div>"
                                $('.select-box').append(tiphtml);
                                setTimeout(function(){
                                    $('.bugtip').remove();
                                },800)
                        return;
                　　    }
                    }
            })
       
        return false;
    }
}

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
    // $('.maskloading').addClass('y-hide')
    $('.select-box').html("<select class='cs-select cs-skin-underline optlist'></select>");
    if (localStorage.getItem('iplist')) {
            var opthtml='',iplist = JSON.parse(localStorage.getItem('iplist'));
            iplist.forEach(function(value, index){
                if(index == 0){
                    opthtml = opthtml + "<option selected>"+value+"</option>";
                }else{
                    opthtml = opthtml + "<option value='"+index+"'>"+value+"</option>";
                }  
            })
            $(".optlist").html(opthtml);
        }
    [].slice.call( document.querySelectorAll( 'select.cs-select' ) ).forEach( function(el) {	
        console.log(el)
        new SelectFx(el);
    } );
    $('.cs-placeholder').click(function(){
        $(this).toggleClass("main");
    })
    $(".option-delete").click(function(){
        //删除localstorage中相应的东西
        var iplist = JSON.parse(localStorage.getItem('iplist'));
        var ipindex = iplist.indexOf($(this).parents("span").text());
        iplist.splice(ipindex,1)
        localStorage.setItem('iplist', JSON.stringify(iplist));
        $(this).parents("li").remove();
    })
    $('.y-placeholder').click(function(ev){
        //console.log('dianjile')
        ev.preventDefault();
        if($('div.y-test-box').length == 0){
            var testSelEl = document.createElement( 'div' );
            var ipinputHtml = "<div class='y-test-box'><input class='y-form-control-test y-address'></input><span>:</span><input class='y-form-control-test y-ipcontent y-ipcontent-one'></input><span>.</span><input class='y-form-control-test y-ipcontent y-ipcontent-two'></input><span>.</span><input class='y-form-control-test y-ipcontent y-ipcontent-three'></input><span>.</span><input class='y-form-control-test y-ipcontent y-ipcontent-four'></input><span>:</span><input class='y-form-control-test y-port'></input></div>";
            var ipaddhtml = "<span class='cs-addicon iconfont icon-plus' id='addip'></span>";
            var html = "<div class='y-test-box col-xs-11'><div class='col-xs-2'><div class='row'><input class='y-address col-xs-10 y-form-control-test'></input><span class=''>:</span></div></div><div class='col-xs-2'><div class='row'><input class='y-ipcontent col-xs-10 y-form-control-test'></input><span class=''>.</span></div></div><div class='col-xs-2'><div class='row'><input class='y-ipcontent col-xs-10 y-form-control-test'></input><span class=''>.</span></div></div><div class='col-xs-2'><div class='row'><input class='y-ipcontent col-xs-10 y-form-control-test'></input><span class=''>.</span></div></div><div class='col-xs-2'><div class='row'><input class='y-ipcontent col-xs-10 y-form-control-test'></input><span class=''>:</span></div></div><div class='col-xs-2'><div class='row'><input class='y-port col-xs-10 y-form-control-test'></input></div></div> </div><span class='cs-addicon iconfont icon-plus col-xs-1' id='addip'></span>";
            $('.double-input-box').append(html);
            $('.y-placeholder').addClass('y-hide');
            $('.y-placeholder').removeClass('y-show');
            $('.cs-options').addClass('y-hide');
            $('.cs-options').removeClass('y-show');
            if($('.cs-placeholder')){
                $('.cs-placeholder').addClass('y-hide');
                $('.cs-placeholder').removeClass('y-show')
            }
            $('select.cs-select') .addClass('cs-focus')
        }else{
            $('div.y-test-box').addClass('y-show');
            $('div.y-test-box').removeClass('y-hide');
            $('.cs-addicon ').addClass('y-show');
            $('.cs-addicon ').removeClass('y-hide');
            $('.y-placeholder').addClass('y-hide');
            $('.y-placeholder').removeClass('y-show');
            $('.cs-options').addClass('y-hide');
            $('.cs-options').removeClass('y-show');
            if($('.cs-placeholder')){
                $('.cs-placeholder').addClass('y-hide');
                $('.cs-placeholder').removeClass('y-show')
            }
        }
        $('.double-input-box').addClass('y-focus');
        
        $("#addip").click(function(){
            //将ip加入localstorage中
            //先判断ip地址是否合
            var ipstr = $('.y-address').val() + ':';
            var flag = true;
            $('.y-ipcontent').each(function(index){
                if(!isValidIP($(this).val()) || !$(this).val()){
                    console.log('ip地址格式错误')
                    //显示提示框ip错
                    flag =false;
                }
                if(index == 0){
                    ipstr = ipstr + $(this).val()
                }else{
                    ipstr = ipstr +'.'+ $(this).val()
                }
            })
            if(flag && (ipstr !=='undefined:')){
                console.log(ipstr)
                if($('.y-port').val()){
                    ipstr =ipstr + ':' + $('.y-port').val();
                }
                if(ipstr !== ''){
                    if (localStorage.getItem('iplist')) {
                        var iplist = JSON.parse(localStorage.getItem('iplist'));
                        //如果已经存在则不添加
                        if(iplist.indexOf(ipstr) == -1){
                            console.log("ip不存在")
                            iplist.push(ipstr);
                            localStorage.setItem('iplist', JSON.stringify(iplist));
                        }else{
                            console.log("ip已存在")
                        }   
                    }else{
                        var testarr = [];
                        localStorage.setItem('iplist', JSON.stringify(testarr));
                        var iplist = JSON.parse(localStorage.getItem('iplist'));
                        iplist.push(ipstr);
                        localStorage.setItem('iplist', JSON.stringify(iplist));
                    }
                }
                renderselect();
            }else{
                var tiphtml = "<div class='bugtip'>ip地址格式错误</div>"
                $('.select-box').append(tiphtml);
                setTimeout(function(){
                    $('.bugtip').remove();
                },800)
            }
            
        })
    })
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
function isValidIP(ip) {
    var reg = /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/;
    return reg.test(ip);
} 
function getCUAddress(ipurl){
    window.app.getCUAddress(JSON.stringify({url:ipurl}))
};
function getjumpfrom(){
    window.app.getjumpfrom()
}

function isios(){
    var u = navigator.userAgent;
    var isiOS = !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/);
    return isiOS;
}
function insertIntoLocal(flag){
    ipstatus = flag;
}

function setFlag(){
    window.app.setFlag();

}
