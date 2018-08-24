/*RSA加密公钥*/
var pk = "D691BF626490C18A65EBD5D8B68494D7B7E9E7FDF8CADA49E3314F950505C85F0ADC48014D40DA002DD217D86A1C391EFF1C913FEEDD1BA57C741E6F94E11C4CD4B5D800E53AF2C51CDB0427390119C4F81CBE3322D96F198CF9822F2A08B53C23774D3F9B926B996BA93C1AFC295B00EF89D523488ECA00D8E258680D59A677836607CD7772CC8806DA55539EEAABFAA6C003FFD8FA5734F0F3D54EEB9DBAA249C2FAF1C261E3F05A88B6AE0E13179F748863A18E4D94045C8F9DB432EF32E1846F5E1E45B955F536669273955C87F0CBDE1258AD1F6FDF52320D4981B4D78BAF7808745626C2D2FD4A088123070B6B23747C7FDFE89739760539F866D4288D";

/*使用RSA方式加密*/
function encryptPassword(p){
    setMaxDigits(259);
    var key = new RSAKeyPair("10001", '10001', pk, 2048);
    p = encryptedString(key, p, RSAAPP.PKCS1Padding, RSAAPP.RawEncoding);
    /*base64*/
    return window.btoa(p);
}


    
/*cookie过期时间*/
var expireTime = 7 * 24 * 60 * 60 * 1000;

function setCookie(name,value,unexpire) {
    let cookie = typeof name == 'object' ? name : {[name]:value};
    var exp = new Date();
    exp.setTime(exp.getTime() + expireTime);
    for(let key in cookie){
        if(unexpire){
            document.cookie = key + "="+ encodeURI(cookie[key]);
        }else{
            document.cookie = key + "="+ encodeURI(cookie[key]) + ";expires=" + exp.toGMTString();
        }
    }
}
function getCookie(name) {
    var arr,reg=new RegExp("(^| )"+name+"=([^;]*)(;|$)");
    if(arr=document.cookie.match(reg))
        return decodeURI(arr[2]);
    else
        return null;
}
function delCookie(name) {
    let arr = name.length ? name : [name];
    arr.map((v,k)=>{
        var exp = new Date();
        exp.setTime(exp.getTime() - expireTime);
        var cval=getCookie(v);
        if(cval!=null)
            document.cookie= v + "="+cval+";expires="+exp.toGMTString();
    });
}