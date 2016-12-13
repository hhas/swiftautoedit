//
//  AppDelegate.swift
//  SwiftAutoEdit
//
//

// TO DO: how practical to fall back to using embedded SA framework if user hasn't installed their own in /Library/Frameworks?

// TO DO: integrate aeglue generation (e.g. see ASDictionary's ObjC glue generator for comparison); note: this needs to use user's installed SA framework (or fall back to embedded SA if not found?); don't call SA APIs directly as there's no guarantee embedded SA will produce same glues as newer installed version

// TO DO: will presumably need to framework-ify generated glue file[s] - how/where is best to install it? (note: would be best to add framework build option to aeglue, and leave save location for user to specify)

// TO DO: how practical to embed sourcekitten executable? (or just leave that as external dependency until SourceKitten framework can be embedded?)

// TO DO: prefs option for specifying default imports (e.g. Cocoa, SwiftAutomation, MacOSGlues) to include in all new documents? (or a 'new -> from template' menu option?); as with '#!...' line, these might be hidden by default (with option to toggle their visibility) to reduce amount of boilerplate

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let automationFrameworkPath = "/Library/Frameworks/SwiftAutomation.framework"
        
    var automationFramework: Bundle { // used to locate current installed aeglue + SA docs, or fall back to embedded version if not found
        if let bundle = Bundle(path: self.automationFrameworkPath) {
            return bundle
        } else {
            return Bundle(url: Bundle.main.url(forResource: "SwiftAutomation",
                                               withExtension: "framework", subdirectory: Bundle.main.privateFrameworksPath)!)!
        }
    }
    
    var aeglueURL: URL { return self.automationFramework.url(forResource: "aeglue", withExtension: "", subdirectory: "bin")! }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UserDefaults.standard.register(defaults: ["SendAppleEvents":false, "UseSDEFTerminology":false]) // TO DO: if/when OS's AETE-to-SDEF translator can guarantee 100% translations, the UseSDEFTerminology option can be deleted; until then, paranoia is pragmatism
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    @IBAction func openTranslationDocument(_ sender: Any) {
        let controller = NSDocumentController.shared()
        let document = try! controller.makeUntitledDocument(ofType:"TranslationDocument")
        controller.addDocument(document)
        document.makeWindowControllers()
        document.showWindows()
    }
    
    @IBAction func openHelp(_ sender: Any) {
        NSWorkspace.shared().open(Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "doc")!) // TO DO: which is better: open in App help or user's default browser?
    }

    @IBAction func openAutomationHelp(_ sender: Any) {
        guard let docURL = self.automationFramework.url(forResource: "index", withExtension: "html", subdirectory: "doc") else {
            fatalError("Older installed SwiftAutomation framework doesn't contain Resources/doc. Please open SwiftAutomation project directly in Xcode, pull latest changes, and rebuild Release.")
        }
        NSWorkspace.shared().open(docURL) // TO DO: which is better: open in App help or user's default browser?
    }

}

