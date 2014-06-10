//
//  IXAppManager.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/8/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IXEnums.h"

@class IXBaseControl;
@class IXSandbox;
@class IXViewController;
@class IXPropertyContainer;
@class IXNavigationViewController;
@class JASidePanelController;
@class Reachability;
@class ApigeeClient;
@class MMDrawerController;

@interface IXAppManager : NSObject

@property (nonatomic,assign) IXAppMode appMode;

@property (nonatomic,strong) MMDrawerController* drawerController;
@property (nonatomic,strong) IXNavigationViewController* rootViewController;
@property (nonatomic,strong) IXViewController* rightDrawerViewController;
@property (nonatomic,strong) IXViewController* leftDrawerViewController;

@property (nonatomic,copy) NSString* appConfigPath;
@property (nonatomic,copy) NSString* appDefaultViewPath;
@property (nonatomic,copy) NSString* appLeftDrawerViewPath;
@property (nonatomic,copy) NSString* appRightDrawerViewPath;
@property (nonatomic,copy) NSString* appDefaultViewRootPath;

@property (nonatomic,strong) IXPropertyContainer* deviceProperties;
@property (nonatomic,strong) IXPropertyContainer* appProperties;
@property (nonatomic,strong) IXPropertyContainer* sessionProperties;

@property (nonatomic,copy) NSString* appID;
@property (nonatomic,copy) NSString* pushToken;
@property (nonatomic,copy) NSString* bundleID;
@property (nonatomic,copy) NSString* versionNumberMajor;
@property (nonatomic,copy) NSString* versionNumberMinor;

@property (nonatomic,strong) IXSandbox* applicationSandbox;
@property (nonatomic,strong) Reachability* reachabilty;

@property (nonatomic,strong) ApigeeClient* apigeeClient;

@property (nonatomic,assign,getter = isLayoutDebuggingEnabled) BOOL layoutDebuggingEnabled;

+(IXAppManager*)sharedAppManager;

-(void)startApplication;
-(void)appDidRegisterRemoteNotificationDeviceToken:(NSData *)deviceToken;
-(void)appDidRecieveRemoteNotification:(NSDictionary *)userInfo;

-(IXViewController*)currentIXViewController;

-(void)applyAppProperties;
-(void)storeSessionProperties;

+(UIInterfaceOrientation)currentInterfaceOrientation;
-(NSString*)evaluateJavascript:(NSString*)javascript;

@end
