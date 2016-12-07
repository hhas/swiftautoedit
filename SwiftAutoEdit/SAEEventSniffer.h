//
//  SAEEventSniffer.h
//  SwiftAutoEdit
//
//

#import <Foundation/Foundation.h>
#import "SAELanguageInstance.h"

@class SAETranslationDocument;

@interface SAEEventSniffer : NSObject {
    
    SAETranslationDocument * __weak translationDocument;
}

- (instancetype)initWithDocument:(SAETranslationDocument *)document;

- (BOOL)sniffEvent:(NSAppleEventDescriptor *)desc;

- (void)sniffReply:(NSAppleEventDescriptor *)desc;

@end
