//
//  SwiftDocumentView.swift
//  SwiftAutoEdit
//
//

import AppKit


class SwiftDocumentView: NSTextView {
    
    var syntaxHighlighter: SwiftSyntaxHighlighter?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // workaround for longstanding NSTextView bugs <rdar://12868213> // TO DO: would IB's 'User Defined Runtime Attributes' work?
        self.isAutomaticQuoteSubstitutionEnabled = false
        self.isAutomaticDashSubstitutionEnabled = false
        self.isAutomaticTextReplacementEnabled = false
        self.font = NSFont(name:"Menlo", size:11)
    }
    
    
    public func setup(_ scrollView: NSScrollView) { // hack hack kludge kludge
        // TO DO: ideally would use embedded SK framework as running sourcekitten subprocess on every change is an absolute slug (unfortunately SK framework isn't documented so will require a lot more work); improved integration will also allow autocomplete, live syntax checking, and other modern comforts, and hopefully pave way toward smarter Automation-specific features as well, e.g. allowing users to view a property/elements/command/etc's SDEF-supplied description by option-clicking on its name in their code, or using app dictionary to assist users in constructing longer specifiers as they type (while dictionaries are neither accurate nor complete, and SA type information available to SourceKit is limited to APPLICATION/APPItem/APPItems/APPInsertion types, even fuzzy partial completion suggestions will help)
        if FileManager.default.fileExists(atPath: "/usr/local/bin/sourcekitten") { // add syntax highlighting only if sourcekitten is installed
            self.syntaxHighlighter = SwiftSyntaxHighlighter(textView: self, scrollView: scrollView)
        }
    }
}
