//
//  SAETranslationDocument.m
//  SwiftAutoEdit
//
//

#import "SAETranslationDocument.h"

@implementation SAETranslationDocument

@synthesize formatter;

- (BOOL)useSDEF {
    return [NSUserDefaults.standardUserDefaults boolForKey: @"UseSDEFTerminology"];
}

- (NSString *)windowNibName {
    return @"TranslationDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    for (NSTextView *view in @[self.inputView, self.outputView]) {
        [view setAutomaticDashSubstitutionEnabled:NO];
        [view setAutomaticQuoteSubstitutionEnabled:NO];
        [view setAutomaticSpellingCorrectionEnabled:NO];
        [view setAutomaticTextReplacementEnabled:NO];
    }
    [self.inputView.textStorage.mutableString setString: @"tell app \"textedit\" to get documents"]; // TO DO: should restore previous
    languageInstance = [[SAELanguageInstance alloc] initWithLanguage: [OSALanguage languageForName: @"AppleScript"]];
    formatter = [[SAEEventSniffer alloc] initWithDocument: self];
    [languageInstance setEventSniffer: formatter];
}



// TO DO: read+write



- (IBAction)runAppleScript:(id)sender {
    [self clearView:self.outputView];
    NSString *source = [self.inputView.textStorage.mutableString copy];
    OSAScript *script = [[OSAScript alloc] initWithSource: source fromURL: nil languageInstance: languageInstance usingStorageOptions: 0];
    NSAttributedString *scriptResult = nil;
    NSDictionary *errorInfo = nil;
    NSError *error = nil;
    // note: execute... returns fully qualified objspecs
    if (!([script compileAndReturnError: &errorInfo] && [script executeAndReturnDisplayValue: &scriptResult error: &errorInfo])) {
        error = [NSError errorWithDomain: NSOSStatusErrorDomain code: ([errorInfo[OSAScriptErrorNumber] intValue] ?: 1)
                                userInfo: @{NSLocalizedDescriptionKey: errorInfo[OSAScriptErrorMessage] ?: @"Couldn't compile script."}];
    }
    [self writeToView: self.outputView isReply: YES literalResult: scriptResult.string error: error desc: nil];
}


// TO DO: should AS and Swift syntaxes be logged side by side for easier comparison?

-(void)logAppleEvent:(NSAppleEventDescriptor *)desc {
    NSError *error = nil;
    NSString *literalResult = [SAEFormatter formatAppleEvent: desc useSDEF: self.useSDEF];
    [self writeToView: self.logView isReply: NO literalResult: literalResult error: error desc: desc];
}

-(void)logReplyEvent:(NSAppleEventDescriptor *)desc {
    NSError *error = nil;
    NSString *literalResult = [SAEFormatter formatAppleEvent: desc useSDEF: self.useSDEF];
    [self writeToView: self.logView isReply: YES literalResult: literalResult error: error desc: desc];

}

-(void)writeToView:(NSTextView *)view isReply:(BOOL)isReply literalResult:(NSString *)result
                                        error:(NSError *)error desc:(NSAppleEventDescriptor *)desc {
    if (result) {
        NSColor *color;
        if (isReply) {
            color = NSColor.grayColor;
            if (view == self.logView) result = [NSString stringWithFormat: @"// %@", result];
        } else {
            color = NSColor.blackColor;
        }
        [view.textStorage appendAttributedString:
         [[NSAttributedString alloc] initWithString: result attributes: @{NSForegroundColorAttributeName: color}]];
    } else {
        NSMutableString *errorMessage = [NSMutableString stringWithString: @"ERROR: "];
        if (error) {
            [errorMessage appendFormat: @"(%li) %@", error.code, error.localizedDescription];
        } else {
            [errorMessage appendString: @"No details available."];
        }
        if (desc) [errorMessage appendFormat: @"%@\n", desc.description];
        [view.textStorage appendAttributedString:
         [[NSAttributedString alloc] initWithString: errorMessage attributes: @{NSForegroundColorAttributeName: NSColor.redColor}]];
    }
    [view.textStorage.mutableString appendString: @"\n"];
}

-(IBAction)clearLog:(id)sender {
    [self clearView: self.logView];
}

-(void)clearView:(NSTextView *)view {
    [view.textStorage.mutableString setString: @""];
}

@end
