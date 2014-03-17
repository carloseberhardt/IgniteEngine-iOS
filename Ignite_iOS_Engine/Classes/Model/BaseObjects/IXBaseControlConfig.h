//
//  IXBaseControlConfig.h
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 2/21/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXBaseControl;
@class IXActionContainer;
@class IXPropertyContainer;

@interface IXBaseControlConfig : NSObject <NSCopying>

@property (nonatomic,assign) Class controlClass;
@property (nonatomic,copy)   NSString* styleClass;
@property (nonatomic,strong) NSArray* childControlConfigs;
@property (nonatomic,strong) IXActionContainer* actionContainer;
@property (nonatomic,strong) IXPropertyContainer* propertyContainer;

-(instancetype)initWithControlClass:(Class)controlClass
                         styleClass:(NSString*)styleClass
                  propertyContainer:(IXPropertyContainer*)propertyContainer
                    actionContainer:(IXActionContainer*)actionContainer
             andChildControlConfigs:(NSArray*)childControlConfigs;

+(instancetype)controlConfigWithJSONDictionary:(NSDictionary*)controlJSONDict;
+(NSArray*)controlConfigsWithJSONControlArray:(NSArray*)controlsValueArray;

-(IXBaseControl*)createControl;

@end
