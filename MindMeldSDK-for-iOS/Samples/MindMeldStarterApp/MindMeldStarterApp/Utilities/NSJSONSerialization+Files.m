//
//  NSJSONSerialization+Files.m
//  MindMeldVoice
//
//  Created by J.J. Jackson on 10/7/14.
//  Copyright (c) 2014 Expect Labs. All rights reserved.
//

#import "NSJSONSerialization+Files.h"

@implementation NSJSONSerialization (Files)

+ (id)JSONObjectWithFileName:(NSString *)fileName
                     options:(NSJSONReadingOptions)options
                       error:(NSError **)error
{
    NSString *fileExtension = fileName.pathExtension;
    fileName = fileName.stringByDeletingPathExtension;

    NSURL *url = [[NSBundle mainBundle] URLForResource:fileName
                                         withExtension:fileExtension];
    NSData *data = [NSData dataWithContentsOfURL:url];
    id object = [NSJSONSerialization JSONObjectWithData:data
                                                options:options
                                                  error:error];

    return object;
}

@end
