//
//  IXLogAction.m
//  Ignite Engine
//
//  Created by Brandon on 3/23/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXLogAction.h"

#import "IXAppManager.h"
#import "IXActionContainer.h"
#import "IXAttributeContainer.h"
#import "IXLogger.h"

static NSString* const kIXText = @"text";
static NSString* const kIXDelay = @"delay";

@implementation IXLogAction

-(void)execute
{
    [super execute];
    
    IXAttributeContainer* actionProperties = [self actionProperties];
    
    NSString* text = [actionProperties getStringValueForAttribute:kIXText defaultValue:nil];
    
    IX_LOG_DEBUG(@"Log action: %@", text);
}

@end