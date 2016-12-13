//
//  SAETranslationDocument.h
//  SwiftAutoEdit
//
//

// TO DO: file read+write (Q. how to prevent user accidentally saving over production scripts while experimenting with translations?)

#import <Cocoa/Cocoa.h>
#import "SAELanguageInstance.h"
#import "SAEEventSniffer.h"
#import "SwiftAutoEdit-Swift.h"


@interface SAETranslationDocument : NSDocument {
    SAELanguageInstance *languageInstance;
    SAEEventSniffer *formatter;
}

@property (assign) IBOutlet NSTextView *inputView, *outputView, *logView;

@property (readonly) BOOL useSDEF;

@property (readonly) SAEEventSniffer *formatter;

@property NSAttributedString *code;


- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError;

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError;


-(IBAction)runAppleScript:(id)sender;

-(void)logAppleEvent:(NSString *)desc;

-(void)logReplyEvent:(NSString *)desc;

-(void)writeToView:(NSTextView *)view isReply:(BOOL)isReply literalResult:(NSString *)result
             error:(NSError *)error desc:(NSAppleEventDescriptor *)desc;

-(IBAction)clearLog:(id)sender;

@end
