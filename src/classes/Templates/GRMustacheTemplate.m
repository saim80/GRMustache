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

#import "GRMustacheTemplate_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheTemplateRepository_private.h"
#import "GRMustacheTemplateAST_private.h"
#import "GRMustacheRenderingEngine_private.h"
#import "GRMustacheConfiguration_private.h"

@implementation GRMustacheTemplate
@synthesize templateRepository=_templateRepository;
@synthesize templateAST=_templateAST;
@synthesize baseContext=_baseContext;

+ (instancetype)templateFromString:(NSString *)templateString error:(NSError **)error
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheRendering currentTemplateRepository];
    if (templateRepository == nil) {
        templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:[NSBundle mainBundle]];
    }
    GRMustacheContentType contentType = [GRMustacheRendering currentContentType];
    return [templateRepository templateFromString:templateString contentType:contentType error:error];
}

+ (instancetype)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)error
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:bundle];
    return [templateRepository templateNamed:name error:error];
}

+ (instancetype)templateFromContentsOfFile:(NSString *)path error:(NSError **)error
{
    NSString *directoryPath = [path stringByDeletingLastPathComponent];
    NSString *templateExtension = [path pathExtension];
    NSString *templateName = [[path lastPathComponent] stringByDeletingPathExtension];
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:templateExtension encoding:NSUTF8StringEncoding];
    return [templateRepository templateNamed:templateName error:error];
}

+ (instancetype)templateFromContentsOfURL:(NSURL *)URL error:(NSError **)error
{
    NSURL *baseURL = [URL URLByDeletingLastPathComponent];
    NSString *templateExtension = [URL pathExtension];
    NSString *templateName = [[URL lastPathComponent] stringByDeletingPathExtension];
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:baseURL templateExtension:templateExtension encoding:NSUTF8StringEncoding];
    return [templateRepository templateNamed:templateName error:error];
}

+ (NSString *)renderObject:(id)object stop:(BOOL*)stop fromString:(NSString *)templateString error:(NSError **)error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:error];
    return [template renderObject:object stop:stop error:error];
}

+ (NSString *)renderObject:(id)object stop:(BOOL*)stop fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:name bundle:bundle error:error];
    return [template renderObject:object stop:stop error:error];
}

- (void)dealloc
{
    [_templateAST release];
    [_baseContext release];
    [_templateRepository release];
    [super dealloc];
}

- (void)extendBaseContextWithObject:(id)object
{
    self.baseContext = [self.baseContext contextByAddingObject:object];
}

- (void)extendBaseContextWithProtectedObject:(id)object
{
    self.baseContext = [self.baseContext contextByAddingProtectedObject:object];
}

- (void)extendBaseContextWithTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate
{
    self.baseContext = [self.baseContext contextByAddingTagDelegate:tagDelegate];
}

- (NSString *)renderObject:(id)object stop:(BOOL*)stop error:(NSError **)error
{
    GRMustacheContext *context = [self.baseContext contextByAddingObject:object];
    return [self renderContentWithContext:context stop:stop HTMLSafe:NULL error:error];
}

- (NSString *)renderObjectsFromArray:(NSArray *)objects stop:(BOOL*)stop error:(NSError **)error
{
    GRMustacheContext *context = self.baseContext;
    for (id object in objects) {
        context = [context contextByAddingObject:object];
    }
    return [self renderContentWithContext:context stop:nil HTMLSafe:NULL error:error];
}

- (NSString *)renderContentWithContext:(GRMustacheContext *)context stop:(BOOL*)stop HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    if (stop && *stop) return @"";
    
    [GRMustacheRendering pushCurrentTemplateRepository:self.templateRepository];
    GRMustacheRenderingEngine *renderingEngine = [GRMustacheRenderingEngine renderingEngineWithContentType:_templateAST.contentType context:context];
    [renderingEngine renderTemplateAST:_templateAST stop:stop HTMLSafe:HTMLSafe error:error];
    [GRMustacheRendering popCurrentTemplateRepository];
    
    return error && *error ? nil : @"";
}

- (void)setBaseContext:(GRMustacheContext *)baseContext
{
    if (!baseContext) {
        [NSException raise:NSInvalidArgumentException format:@"Invalid baseContext:nil"];
        return;
    }
    
    if (_baseContext != baseContext) {
        [_baseContext release];
        _baseContext = [baseContext retain];
    }
}


#pragma mark - <GRMustacheRendering>

// Allows template to render as "dynamic partials"
- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context stop:(BOOL*)stop HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    return [self renderContentWithContext:context stop:(BOOL*)stop HTMLSafe:HTMLSafe error:error];
}

#pragma mark- NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        GRMustacheTemplateRepository *templateRepository = [GRMustacheRendering currentTemplateRepository];
        if (templateRepository == nil) {
            templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:[NSBundle mainBundle]];
            _templateRepository.configuration.baseContext = [_templateRepository.configuration.baseContext contextWithUnsafeKeyAccess];
        }
        
        _templateRepository = [templateRepository retain];
        _templateAST        = [[aDecoder decodeObjectForKey:@"templateAST"] retain];
        _baseContext        = [_templateRepository.configuration.baseContext retain];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_templateAST forKey:@"templateAST"];
}

@end
