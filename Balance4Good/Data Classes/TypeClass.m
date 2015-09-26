//
//  TypeClass.m
//  Balance4Good
//
//  Created by Hira Daud on 1/16/15.
//  Copyright (c) 2015 Hira Daud. All rights reserved.
//

#import "TypeClass.h"

@implementation TypeClass

-(id)initWithAbbreviation:(NSString*)abbrev name:(NSString*)name
{
    self = [super init];
    if(self)
    {
        self.abbreviation = abbrev;
        self.full_name = name;
    }
    return self;
}

@end
