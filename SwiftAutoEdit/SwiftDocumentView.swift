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
        // TO DO: skip if "/usr/local/bin/sourcekitten" not found
        // (ideally would link to framework, as running sourcekitten subprocess on every change is an absolute slug; unstable official APIs and undocumented unofficial ones FTF)
        self.syntaxHighlighter = SwiftSyntaxHighlighter(textView: self, scrollView: scrollView)
    }
}
