//
//  JSCallOcProtocol.h
//  FreeRDP
//
//  Created by conan on 2018/7/27.
//
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSCallOcProtocol <JSExport>

JSExportAs(openApp, -(void)AcceptTheDataFromJs:(NSString*)data);
JSExportAs(setUserInfo, -(void)AcceptUidAndKeepHeartBeat:(NSString *)data);
JSExportAs(logOff, -(void)StopHeartBeat:(id)num);
JSExportAs(g, -(void)getCUAddress:(id)num);

@end
