//
//  TypeClass.h
//  Balance4Good
//
//  Created by Hira Daud on 1/16/15.
//  Copyright (c) 2015 Hira Daud. All rights reserved.
//

#import <Foundation/Foundation.h>

//Class for storing shoe type, floor type and sensors info for start test screen
//Abbreviation is the four letter abbreviation (Added to JSON File)
//Full Name is shown in the dropdown
@interface TypeClass : NSObject

@property (strong,nonatomic) NSString *abbreviation;
@property (strong,nonatomic) NSString *full_name;

-(id)initWithAbbreviation:(NSString*)abbrev name:(NSString*)name;

@end
