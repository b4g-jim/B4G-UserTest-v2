//
//  NSArray+KeyValuePairs.h
//  Balance4Good
//
//  Created by Hira Daud on 11/23/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (KeyValuePairs)

-(void)setValue:(NSString*)value forKey:(NSString*)key;
-(void)setValue:(NSString*)value forKey:(NSString*)key atIndex:(int)index;
-(void)insertTimeStamp:(NSString *)value atIndex:(int)index;

@end
