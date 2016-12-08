//
//  OSADictionaryView.h
//  SwiftAutoEdit
//
//

#import <Cocoa/Cocoa.h>
#import <OSAKit/OSAKit.h>
#import <WebKit/WebKit.h>

@interface OSADictionaryView : NSView

@property (strong) IBOutlet NSSplitView *splitView;
@property (strong) IBOutlet NSOutlineView *outlineView;
@property (strong) IBOutlet WebView *contentView;
@property (strong) IBOutlet NSTabView *tabView;
@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSBrowser *suiteBrowser;
@property (strong) IBOutlet NSBrowser *containmentBrowser;
@property (strong) IBOutlet NSBrowser *inheritanceBrowser;

@end
