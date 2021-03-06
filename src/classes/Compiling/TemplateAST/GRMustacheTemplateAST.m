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

#import "GRMustacheTemplateAST_private.h"
#import "GRMustacheTemplateASTNode_private.h"
#import "GRMustacheTemplateASTVisitor_private.h"

@implementation GRMustacheTemplateAST
@synthesize templateASTNodes=_templateASTNodes;
@synthesize contentType=_contentType;

- (void)dealloc
{
    [_templateASTNodes release];
    [super dealloc];
}

+ (instancetype)placeholderAST
{
    return [[[self alloc] initWithASTNodes:nil contentType:GRMustacheContentTypeHTML] autorelease];
}

+ (instancetype)templateASTWithASTNodes:(NSArray *)templateASTNodes contentType:(GRMustacheContentType)contentType
{
    NSAssert(templateASTNodes, @"nil templateASTNodes");
    return [[[self alloc] initWithASTNodes:templateASTNodes contentType:contentType] autorelease];
}

- (BOOL)isPlaceholder
{
    return (_templateASTNodes == nil);
}

- (instancetype)initWithASTNodes:(NSArray *)templateASTNodes contentType:(GRMustacheContentType)contentType
{
    self = [super init];
    if (self) {
        _templateASTNodes = [templateASTNodes retain];
        _contentType = contentType;
    }
    return self;
}


#pragma mark - <GRMustacheTemplateASTNode>

- (BOOL)acceptTemplateASTVisitor:(id<GRMustacheTemplateASTVisitor>)visitor stop:(BOOL *)stop error:(NSError **)error
{
    return [visitor visitTemplateAST:self stop:stop error:error];
}

- (id<GRMustacheTemplateASTNode>)resolveTemplateASTNode:(id<GRMustacheTemplateASTNode>)templateASTNode
{
    return templateASTNode;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        _templateASTNodes = [[aDecoder decodeObjectForKey:@"templateASTNodes"] retain];
        _contentType = (GRMustacheContentType)[aDecoder decodeIntegerForKey:@"contentType"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_templateASTNodes forKey:@"templateASTNodes"];
    [aCoder encodeInteger:_contentType forKey:@"contentType"];
}

@end
