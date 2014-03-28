//
//  NSString+IXAdditions.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 11/25/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "NSString+IXAdditions.h"

#import "IXConstants.h"

static NSString* const kIXFloatFormat = @"%f";

@implementation NSString (IXAdditions)

+(NSString*)ix_stringFromBOOL:(BOOL)boolean
{
    return (boolean) ? kIX_TRUE : kIX_FALSE;
}

+(NSString*)ix_stringFromFloat:(float)floatValue
{
    return [NSString stringWithFormat:kIXFloatFormat,floatValue];
}

+(NSString*)ix_truncateString:(NSString*)string toIndex:(NSInteger)index
{
    if (index > 0 && string.length > index)
        return [NSString stringWithFormat:@"%@...", [string substringToIndex:MIN(index, string.length)]];
    else
        return string;
}

+(NSString*)ix_monogramString:(NSString *)string
{
    if (string.length > 0)
        return [NSString stringWithFormat:@"%@.", [string substringToIndex:1]];
    else
        return string;
}

+(BOOL)ix_string:(NSString*)string containsSubstring:(NSString*)substring options:(NSStringCompareOptions)options
{
    return [string rangeOfString:substring options:options].location != NSNotFound;
}

@end
