//
//  SAEEventSniffer.m
//  SwiftAutoEdit
//
//

#import "SAEEventSniffer.h"
#import "SAETranslationDocument.h"

@implementation SAEEventSniffer

- (instancetype)initWithDocument:(SAETranslationDocument *)document {
    self = [super init];
    if (self) {
        translationDocument = document;
    }
    return self;
}


// called by SAELanguageInstance

- (BOOL)sniffEvent:(NSAppleEventDescriptor *)desc {
    [translationDocument performSelectorOnMainThread: @selector(logAppleEvent:) withObject: desc waitUntilDone: NO];
    return [NSUserDefaults.standardUserDefaults boolForKey: @"SendAppleEvents"];
}

- (void)sniffReply:(NSAppleEventDescriptor *)desc {
    [translationDocument performSelectorOnMainThread: @selector(logReplyEvent:) withObject: desc waitUntilDone: NO];
}

@end
