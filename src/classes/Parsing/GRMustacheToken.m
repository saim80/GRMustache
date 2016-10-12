// The MIT License
//
// Copyright (c) 2014 Gwendal Roué
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

#import "GRMustacheToken_private.h"


@implementation GRMustacheToken
@synthesize type=_type;
@synthesize templateString=_templateString;
@synthesize templateID=_templateID;
@synthesize line=_line;
@synthesize range=_range;
@synthesize tagInnerRange=_tagInnerRange;

- (void)dealloc
{
    [_templateString release];
    [_templateID release];
    [super dealloc];
}

+ (instancetype)tokenWithType:(GRMustacheTokenType)type templateString:(NSString *)templateString templateID:(id)templateID line:(NSUInteger)line range:(NSRange)range
{
    GRMustacheToken *token = [[[self alloc] init] autorelease];
    token.type = type;
    token.templateString = templateString;
    token.templateID = templateID;
    token.line = line;
    token.range = range;
    return token;
}

- (NSString *)templateSubstring
{
    return [_templateString substringWithRange:_range];
}

- (NSString *)tagInnerContent
{
    return [_templateString substringWithRange:_tagInnerRange];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        _type = [aDecoder decodeIntegerForKey:@"type"];
        _templateString = [[aDecoder decodeObjectForKey:@"templateString"] retain];
        _templateID = [[aDecoder decodeObjectForKey:@"templateID"] retain];
        _line = [aDecoder decodeIntegerForKey:@"line"];
        _range = [[aDecoder decodeObjectForKey:@"range"] rangeValue];
        _tagInnerRange = [[aDecoder decodeObjectForKey:@"tagInnerRange"] rangeValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_type forKey:@"type"];
    [aCoder encodeObject:_templateString forKey:@"templateString"];
    [aCoder encodeObject:_templateID forKey:@"templateID"];
    [aCoder encodeInteger:_line forKey:@"line"];
    [aCoder encodeObject:[NSValue valueWithRange:_range] forKey:@"range"];
    [aCoder encodeObject:[NSValue valueWithRange:_tagInnerRange] forKey:@"tagInnerRange"];
}

@end

