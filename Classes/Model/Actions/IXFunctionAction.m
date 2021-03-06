//
//  IXFunctionAction.m
//  IXgee_iOS_Engine
//
//  Created by Robert Walsh on 11/17/13.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
//

#import "IXFunctionAction.h"
#import "IXAttribute.h"
#import "IXAttributeContainer.h"
#import "IXSandbox.h"
#import "IXBaseControl.h"
#import "IXActionContainer.h"
#import "IXBaseDataProvider.h"

#import "IXAppManager.h"
#import "SDWebImageManager.h"
#import "IXDataLoader.h"
#import "IXControlCacheContainer.h"

#import "MMDrawerController.h"

// IXFunctionAction Properties
static NSString* const kIXFunctionName = @"name";
//TODO: deprecate in future release
static NSString* const kIXFunctionNameOld = @"functionName";

static NSString* const kIXDuration = @"duration";

@implementation IXFunctionAction

-(void)execute
{
    NSArray* objectIDs = [[self actionProperties] getCommaSeparatedArrayOfValuesForAttribute:kIX_TARGET defaultValue:nil];
    NSString* functionName = ([[self actionProperties] getStringValueForAttribute:kIXFunctionName defaultValue:nil]) ?: [[self actionProperties] getStringValueForAttribute:kIXFunctionNameOld defaultValue:nil];

    CGFloat duration = [[self actionProperties] getFloatValueForAttribute:kIXDuration defaultValue:0.0f];
    if( [objectIDs count] && [functionName length] > 0 )
    {
        if ([[objectIDs firstObject] isEqualToString:kIXAppRef])
        {
            [[IXAppManager sharedAppManager] applyFunction:functionName parameters:[self setProperties]];
        }
        else
        {
            IXBaseObject* ownerObject = [[self actionContainer] ownerObject];
            IXSandbox* sandbox = [ownerObject sandbox];
            NSArray* objectsWithID = [sandbox getAllControlsAndDataProvidersWithIDs:objectIDs
                                                                     withSelfObject:ownerObject];
            if( [objectsWithID count] )
            {
                if (duration > 0)
                {
                    [UIView animateWithDuration:duration
                                          delay:0.0f
                                        options:UIViewAnimationOptionTransitionCrossDissolve
                                     animations:^{
                                         for( IXBaseObject* baseObject in objectsWithID )
                                         {
                                             [baseObject applyFunction:functionName withParameters:[self setProperties]];
                                         }
                                     }
                                     completion:nil];
                }
                else
                {
                    for( IXBaseObject* baseObject in objectsWithID )
                    {
                        [baseObject applyFunction:functionName withParameters:[self setProperties]];
                    }
                }
            }
        }
    }
    
    [self actionDidFinishWithEvents:nil];
}

@end
