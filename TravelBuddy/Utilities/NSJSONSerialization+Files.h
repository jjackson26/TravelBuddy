//
//  NSJSONSerialization+Files.h
//  MindMeldVoice
//
//  Created by J.J. Jackson on 10/7/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (Files)

+ (id)JSONObjectWithFileName:(NSString *)fileName
                     options:(NSJSONReadingOptions)options
                       error:(NSError **)error;

@end
