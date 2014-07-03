//
//  INPluginManager.h
//  BigSur
//
//  Created by Ben Gotow on 6/5/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol INGlobalExports <JSExport>

- (void)alert:(NSString*)alert;
- (void)log:(NSString*)msg;
- (void)openURL:(NSString*)url;
- (void)getJSON:(NSString*)url withCallback:(JSValue*)callback;

@end

@protocol INThreadExports <JSExport>
@property (nonatomic, strong) NSString * subject;
@property (nonatomic, strong) NSString * snippet;
@property (nonatomic, strong) NSArray * participants;
@property (nonatomic, strong) NSDate * lastMessageDate;
@property (nonatomic, assign) BOOL unread;
- (NSArray*)messages;
@end

@protocol INMessageExports <JSExport>
@property (nonatomic, strong) NSString * body;
@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSString * subject;
@property (nonatomic, strong) NSArray * from;
@property (nonatomic, strong) NSArray * to;
@end

@interface INThread (PluginSupport) <INThreadExports>
- (NSArray*)messages;
@end

@interface INMessage (PluginSupport) <INMessageExports>
@end


@interface INPluginManager : NSObject <INGlobalExports>

@property (nonatomic, strong) NSMutableDictionary * pluginContexts;
@property (nonatomic, strong) NSMutableDictionary * pluginNamesByRole;
@property (nonatomic, strong) dispatch_queue_t pluginBackgroundQueue;
@property (nonatomic, strong) NSString * pluginCompiledResources;

+ (INPluginManager *)shared;

- (NSURL*)webViewBaseURL;

- (JSContext*)contextForPluginWithName:(NSString*)name;
- (NSArray*)pluginNamesForRole:(NSString*)role;

#pragma Exposed Methods

- (void)alert:(NSString*)alert;
- (void)log:(NSString*)msg;
- (void)openURL:(NSString*)url;
- (void)getJSON:(NSString*)url withCallback:(JSValue*)callback;

@end
