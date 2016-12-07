//
//  DictionaryDocument.swift
//  SwiftAutoEdit
//
//

import Cocoa
import OSAKit


class DictionaryDocument: NSDocument {
    
    @IBOutlet var dictionaryController: OSADictionaryController!
    
    var sdef: Data?

    override var windowNibName: String? {
        return "DictionaryDocument"
    }
    
    override func windowControllerDidLoadNib(_ windowController: NSWindowController) {
        if let sdef = self.sdef, let dict = OSADictionary(data: sdef, error: nil) {
            self.dictionaryController.setDictionary(dict)
            Swift.print("TO DO: finish dictionary viewer support") // TO DO: what else needs hooked up?
        } else {
            NSLog("Can't display SDEF.")
        }
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        self.sdef = data
    }
}

