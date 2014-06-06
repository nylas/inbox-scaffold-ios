//
//  INPluginManager.m
//  BigSur
//
//  Created by Ben Gotow on 6/5/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INPluginManager.h"

@implementation INThread (PluginSupport)

- (NSArray*)messages
{
    NSMutableArray * msgs = [NSMutableArray array];
    for (NSString * ID in self.messageIDs)
        [msgs addObject: [INMessage instanceWithID:ID inNamespaceID:self.namespaceID]];
    return msgs;
}

@end

@implementation INMessage (PluginSupport)

@end


@implementation INPluginManager

+ (INPluginManager *)shared
{
	static INPluginManager * sharedManager = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedManager = [[INPluginManager alloc] init];
	});
	return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _pluginBackgroundQueue = dispatch_queue_create("Plugin Processing", NULL);
        _pluginContexts = [[NSMutableDictionary alloc] init];
        [self discoverPlugins];
    }
    return self;
}

- (NSURL*)webViewBaseURL
{
    return [NSURL fileURLWithPath: _pluginCompiledResources];
}

- (void)discoverPlugins
{
    _pluginNamesByRole = [[NSMutableDictionary alloc] init];
    _pluginCompiledResources = [[NSString stringWithFormat:@"~/Documents/Web_Plugin_Root"] stringByExpandingTildeInPath];
    [[NSFileManager defaultManager] removeItemAtPath:_pluginCompiledResources error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:_pluginCompiledResources withIntermediateDirectories:NO attributes:NULL error:NULL];
    
    NSArray * pluginPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"plugin" inDirectory:@"plugins"];
    for (NSString * path in pluginPaths) {
        NSString * pluginName = [[path lastPathComponent] stringByDeletingPathExtension];
        NSString * pluginInfoPath = [path stringByAppendingPathComponent:@"package.json"];
        NSDictionary * pluginInfo = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:pluginInfoPath] options:0 error:NULL];

        for (NSString * pluginRole in pluginInfo[@"roles"]) {
            NSMutableArray * roles = _pluginNamesByRole[pluginRole];
            if (!roles) roles = [NSMutableArray array];
            [roles addObject: pluginName];
            _pluginNamesByRole[pluginRole] = roles;
        }
        
        NSString * resourcesPath = [path stringByAppendingPathComponent: @"resources"];
        for (NSString * resourceName in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcesPath error:NULL]) {
            NSString * src = [resourcesPath stringByAppendingPathComponent: resourceName];
            NSString * dst = [_pluginCompiledResources stringByAppendingPathComponent: resourceName];
            [[NSFileManager defaultManager] copyItemAtPath:src toPath:dst error:NULL];
        }
    }
}

- (JSContext*)contextForPluginWithName:(NSString*)name
{
    if (_pluginContexts[name])
        return _pluginContexts[name];
    
    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:name ofType:@"plugin" inDirectory:@"plugins"];
    NSBundle * pluginBundle = [NSBundle bundleWithPath: bundlePath];
    
    if (!pluginBundle)
        return nil;

    NSString * baseJSPath = [[NSBundle mainBundle] pathForResource:@"compiled" ofType:@"js" inDirectory:@"plugins/base"];
    NSString * baseJS = [NSString stringWithContentsOfFile:baseJSPath encoding:NSUTF8StringEncoding error:NULL];

    NSString * pluginJSPath = [pluginBundle pathForResource:@"plugin" ofType:@"js"];
    NSString * pluginJS = [NSString stringWithContentsOfFile:pluginJSPath encoding:NSUTF8StringEncoding error:NULL];

    JSContext * context = [[JSContext alloc] initWithVirtualMachine: [[JSVirtualMachine alloc] init]];
    context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        context.exception = exception;
        NSLog(@"%@", exception);
    };

    context[@"app"] = self;
	[context evaluateScript: @"plugin = {}"];

    [context evaluateScript: baseJS];
    if (context.exception) {
        NSLog(@"Plugin %@ not loaded due to exception reading compiled.js base code.", name);
        context.exception = nil;
        return nil;
    }
    [context evaluateScript: pluginJS];
    if (context.exception) {
        NSLog(@"Plugin %@ not loaded due to exception reading plugin.js", name);
        context.exception = nil;
        return nil;
    }

    [_pluginContexts setObject:context forKey:name];
    return context;
}

- (NSArray*)pluginNamesForRole:(NSString*)role
{
    return _pluginNamesByRole[role];
}

#pragma Exposed Methods

- (void)alert:(NSString*)alert
{
    [[[UIAlertView alloc] initWithTitle:@"Plugin" message:alert delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)log:(NSString*)msg
{
    NSLog(@"%@", msg);
}

- (void)openURL:(NSString*)url
{
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

- (void)getJSON:(NSString*)url withCallback:(JSValue*)block
{
    AFHTTPRequestOperationManager * manager = [[AFHTTPRequestOperationManager alloc] init];
    AFHTTPRequestOperation * op = [manager GET:url parameters:NULL success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [block callWithArguments: @[responseObject]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [block callWithArguments: @[[NSNull null], error]];
    }];
    [op setResponseSerializer: [[AFJSONResponseSerializer alloc] init]];
    
}

@end
