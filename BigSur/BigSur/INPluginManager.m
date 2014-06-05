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
    
    NSString * baseJSPath = [pluginBundle pathForResource:@"plugin" ofType:@"js"];
    NSString * baseJS = [NSString stringWithContentsOfFile:baseJSPath encoding:NSUTF8StringEncoding error:NULL];
    JSContext * context = [[JSContext alloc] initWithVirtualMachine: [[JSVirtualMachine alloc] init]];
    context[@"app"] = self;
    [context evaluateScript: baseJS];
    if (context.exception) {
        NSLog(@"Plugin not loaded due to exception reading plugin.js:\n%@", context.exception);
        context.exception = nil;
        return nil;
    }
    context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        context.exception = exception;
        NSLog(@"%@", exception);
    };

    [_pluginContexts setObject:context forKey:name];
    return context;
}

- (NSArray*)pluginNamesForRole:(NSString*)role
{
    return _pluginNamesByRole[role];
}

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

- (id)getJSON:(NSString*)url
{
    NSURLRequest * request = [NSURLRequest requestWithURL: [NSURL URLWithString: url]];
    NSData * result = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error: NULL];
    return [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:NULL];
}
@end
