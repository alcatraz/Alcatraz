// ATZPbxprojParser.m
//
// Copyright (c) 2013 Marin Usalj | supermar.in
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ATZPbxprojParser.h"

static NSString *const PLUGIN_NAME_REGEX = @"(\\w[\\w\\s-]*\\w.xcplugin)";

@implementation ATZPbxprojParser

+ (NSString *)xcpluginNameFromPbxproj:(NSString *)path {
    
    NSError *error = nil;
    NSString *pbxproj = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:PLUGIN_NAME_REGEX
                                                                           options:NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    
    if (error) return nil;
    
    NSTextCheckingResult *result = [regex firstMatchInString:pbxproj options:0 range:NSMakeRange(0, pbxproj.length - 1)];
    NSString *pluginName = result ? [pbxproj substringWithRange:result.range] : nil;
    NSString *nameWithoutExtension = [pluginName substringWithRange:NSMakeRange(0, pluginName.length - 9)];
    
    return nameWithoutExtension;
}

@end
