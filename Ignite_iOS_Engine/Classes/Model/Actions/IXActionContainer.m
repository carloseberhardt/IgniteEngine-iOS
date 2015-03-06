//
//  IXActionContainer.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/9/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXActionContainer.h"

#import "IXAppManager.h"
#import "IXSandbox.h"
#import "IXBaseAction.h"
#import "IXViewController.h"
#import "IXNavigationViewController.h"
#import "IXBaseControl.h"
#import "IXLayout.h"
#import "IXPropertyContainer.h"
#import "IXAlertAction.h"
#import "IXLogger.h"

// NSCoding Key Constants
IX_STATIC_CONST_STRING kIXActionsDictNSCodingKey = @"actionsDict";
IX_STATIC_CONST_STRING kIXRepeatDelay = @"repeatDelay"; // amount of time to wait before firing action to prevent rapid repeating of actions (useful on keyboard input actions)

@interface IXActionContainer ()

@property (nonatomic,strong) NSMutableDictionary* actionsDict;

@end

@implementation IXActionContainer

@synthesize ownerObject = _ownerObject;

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        _actionsDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone*)zone
{
    IXActionContainer* actionContainerCopy = [[[self class] allocWithZone:zone] init];
    if( actionContainerCopy )
    {
        [actionContainerCopy setOwnerObject:[self ownerObject]];
        [[self actionsDict] enumerateKeysAndObjectsUsingBlock:^(NSString* actionName, NSArray* actionArray, BOOL *stop) {
            NSMutableArray* actionArrayCopy = [[NSMutableArray alloc] initWithArray:actionArray copyItems:YES];
            [actionContainerCopy addActions:actionArrayCopy];
        }];
    }
    return actionContainerCopy;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if( self )
    {
        NSDictionary* actionsDictionary = [aDecoder decodeObjectForKey:kIXActionsDictNSCodingKey];
        for( NSArray* actionsArray in [actionsDictionary allValues] )
        {
            [self addActions:actionsArray];
        }
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self actionsDict] forKey:kIXActionsDictNSCodingKey];
}

+(IXActionContainer*)actionContainerWithJSONActionsArray:(NSArray*)actionsArray
{
    IXActionContainer* actionContainer = nil;
    if( [actionsArray isKindOfClass:[NSArray class]] && [actionsArray count] )
    {
        actionContainer = [[IXActionContainer alloc] init];
        for( id actionJSONDict in actionsArray )
        {
            if( [actionJSONDict isKindOfClass:[NSDictionary class]] )
            {
                id eventNameValue = actionJSONDict[kIX_ON];
                NSArray* eventNameStrings = nil;
                if( eventNameValue )
                {
                    if( [eventNameValue isKindOfClass:[NSString class]] )
                    {
                        eventNameStrings = [eventNameValue componentsSeparatedByString:kIX_COMMA_SEPERATOR];
                    }
                    else if( [eventNameValue isKindOfClass:[NSArray class]] )
                    {
                        eventNameStrings = eventNameValue;
                    }
                    
                    if( [eventNameStrings count] > 1 )
                    {
                        [actionContainer addActions:[IXBaseAction actionsWithEventNames:eventNameStrings jsonDictionary:actionJSONDict]];
                    }
                    else
                    {
                        [actionContainer addAction:[IXBaseAction actionWithEventName:[eventNameStrings firstObject] jsonDictionary:actionJSONDict]];
                    }
                }
            }
        }
    }
    return actionContainer;
}

-(IXBaseObject*)ownerObject
{
    return _ownerObject;
}

-(void)setOwnerObject:(IXBaseObject *)ownerObject
{
    _ownerObject = ownerObject;
    for( NSArray* actionArray in [[self actionsDict] allValues] )
    {
        for( IXBaseAction* action in actionArray )
        {
            [[action actionProperties] setOwnerObject:ownerObject];
            [[action parameterProperties] setOwnerObject:ownerObject];
            [[action subActionContainer] setOwnerObject:ownerObject];
        }
    }
}

-(NSMutableArray*)actionsForEvent:(NSString*)eventName
{
    if( eventName == nil )
        return nil;
    
    return [self actionsDict][eventName];
}

-(BOOL)hasActionsForEvent:(NSString*)eventName
{
    NSArray* actionsForEvent = [self actionsForEvent:eventName];
    return actionsForEvent != nil && [actionsForEvent count] > 0;
}

-(BOOL)hasActionsWithEventNamePrefix:(NSString*)eventNamePrefix;
{
    BOOL hasActionsWithEventNamePrefix = NO;
    if( eventNamePrefix )
    {
        for( NSString* actionNameKey in [[self actionsDict] allKeys] )
        {
            if( [actionNameKey hasPrefix:eventNamePrefix] )
            {
                hasActionsWithEventNamePrefix = YES;
                break;
            }
        }
    }
    return hasActionsWithEventNamePrefix;
}

-(void)addActionsFromActionContainer:(IXActionContainer*)actionContainer
{
    for( NSArray* actionArray in [[self actionsDict] allValues] )
    {
        [self addActions:actionArray];
    }
}

-(void)addActions:(NSArray*)actions
{
    for( IXBaseAction* action in actions )
    {
        [self addAction:action];
    }
}

-(void)addAction:(IXBaseAction*)action
{
    NSString* actionEventName = [action eventName];
    if( action == nil || actionEventName == nil )
    {
        IX_LOG_ERROR(@"ERROR: Unable to add action with unknown type. Check your JSON configuration for a missing (or mis-spelled) _type property.");
        return;
    }

    [action setActionContainer:self];

    NSMutableArray* actionsForType = [self actionsForEvent:actionEventName];
    if( actionsForType == nil )
    {
        actionsForType = [[NSMutableArray alloc] initWithObjects:action, nil];
        [[self actionsDict] setObject:actionsForType forKey:actionEventName];
    }
    else if( ![actionsForType containsObject:action] )
    {
        [actionsForType addObject:action];
    }
}

-(void)executeActionsForEventNamed:(NSString*)eventName
{
    [self executeActionsForEventNamed:eventName propertyWithName:nil mustHaveValue:nil];
}

-(void)executeActionsForEventNamed:(NSString*)eventName propertyWithName:(NSString*)propertyName mustHaveValue:(NSString*)value
{
    NSArray* actionsForEventName = [self actionsForEvent:eventName];
    if( actionsForEventName == nil )
        return;
    
    UIInterfaceOrientation currentOrientation = [IXAppManager currentInterfaceOrientation];
    for( IXBaseAction* action in actionsForEventName )
    {
        BOOL enabled = [action actionProperties] ? [[action actionProperties] getBoolPropertyValue:kIX_ENABLED defaultValue:YES] : YES;
        if( enabled && [action areConditionalAndOrientationMaskValid:currentOrientation] )
        {
            BOOL shouldFireAction = (value == nil || propertyName == nil );
            if( !shouldFireAction )
            {
                NSString* actionValue = [[action actionProperties] getStringPropertyValue:propertyName defaultValue:nil];
                if( actionValue )
                {
                    shouldFireAction = [actionValue isEqualToString:value];
                }
            }
            
            if( shouldFireAction )
            {
                CGFloat delay = [[action actionProperties] getFloatPropertyValue:kIX_DELAY defaultValue:0.0f];
                CGFloat repeatDelay = [[action actionProperties] getFloatPropertyValue:kIXRepeatDelay defaultValue:0.0f];

                if (repeatDelay > 0.0f)
                {
                    [NSObject cancelPreviousPerformRequestsWithTarget:action selector:@selector(execute) object:nil];
                    [action performSelector:@selector(execute) withObject:nil afterDelay:repeatDelay];
                }
                else if( delay > 0.0f )
                {
                    [action performSelector:@selector(execute) withObject:nil afterDelay:delay];
                }
                else
                {
                    [action execute];
                }
            }
        }
    }
}

-(NSString*)description
{
    NSMutableString* description = [NSMutableString string];
    [[self actionsDict] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [description appendFormat:@"\nActions For %@:\n",key];
        for( IXBaseAction* action in obj )
        {
            [description appendString:[action description]];
        }
    }];
    return description;
}

@end
