//
//  AppDelegate.swift
//  SwiftAutoEdit
//
//

// TO DO: how practical to fall back to using embedded SA framework if user hasn't installed their own in /Library/Frameworks?

// TO DO: integrate aeglue generation (e.g. see ASDictionary's ObjC glue generator for comparison); note: this needs to use user's installed SA framework (or fall back to embedded SA if not found?); don't call SA APIs directly as there's no guarantee embedded SA will produce same glues as newer installed version

// TO DO: will presumably need to framework-ify generated glue file[s] - how/where is best to install it? (note: would be best to add framework build option to aeglue, and leave save location for user to specify)

// TO DO: how practical to embed sourcekitten executable? (or just leave that as external dependency until SourceKitten framework can be embedded?)

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



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
        print("TO DO: open editor help")
    }

    @IBAction func openAutomationHelp(_ sender: Any) {
        print("TO DO: open installed/embedded SA documentation")
    }

}

