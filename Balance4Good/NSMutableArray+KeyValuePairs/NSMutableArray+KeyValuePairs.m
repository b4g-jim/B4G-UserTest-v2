//
//  NSArray+KeyValuePairs.m
//  Balance4Good
//
//  Created by Hira Daud on 11/23/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import "NSMutableArray+KeyValuePairs.h"

@implementation NSMutableArray (KeyValuePairs)

-(void)setValue:(NSString*)value forKey:(NSString*)key
{
    NSString *val = [NSString stringWithFormat:@"%@= : =%@",key,value];
    [self addObject: val];
}

-(void)setValue:(NSString *)value forKey:(NSString *)key atIndex:(int)index
{
    NSString *val = [NSString stringWithFormat:@"%@= : =%@",key,value];
    [self replaceObjectAtIndex:index withObject:val];
}

-(void)insertTimeStamp:(NSString *)value atIndex:(int)index
{
    NSString *val = [NSString stringWithFormat:@"timestamp= : =%@",value];

    [self insertObject:val atIndex:index];
}

@end