//
//  SwiftSyntaxHighlighter.swift
//  SwiftEdit
//
//  Created by JP Simard on 06/07/2014.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Cocoa

let SWIFT_ELEMENT_TYPE_KEY = "swiftElementType"

struct Token {
    let kind: String
    let range: NSRange
}

public enum SyntaxKind: String {
    case Argument = "source.lang.swift.syntaxtype.argument"
    case AttributeBuiltin = "source.lang.swift.syntaxtype.attribute.builtin"
    case AttributeID = "source.lang.swift.syntaxtype.attribute.id"
    case BuildconfigID = "source.lang.swift.syntaxtype.buildconfig.id"
    case BuildconfigKeyword = "source.lang.swift.syntaxtype.buildconfig.keyword"
    case Comment = "source.lang.swift.syntaxtype.comment"
    case CommentMark = "source.lang.swift.syntaxtype.comment.mark"
    case CommentURL = "source.lang.swift.syntaxtype.comment.url"
    case DocComment = "source.lang.swift.syntaxtype.doccomment"
    case DocCommentField = "source.lang.swift.syntaxtype.doccomment.field"
    case Identifier = "source.lang.swift.syntaxtype.identifier"
    case Keyword = "source.lang.swift.syntaxtype.keyword"
    case Number = "source.lang.swift.syntaxtype.number"
    case Objectliteral = "source.lang.swift.syntaxtype.objectliteral"
    case Parameter = "source.lang.swift.syntaxtype.parameter"
    case Placeholder = "source.lang.swift.syntaxtype.placeholder"
    case String = "source.lang.swift.syntaxtype.string"
    case StringInterpolationAnchor = "source.lang.swift.syntaxtype.string_interpolation_anchor"
    case Typeidentifier = "source.lang.swift.syntaxtype.typeidentifier"

    var colorValue: NSColor {
        switch self {
        case .Keyword:
            return NSColor(red: 0.796, green: 0.208, blue: 0.624, alpha: 1)
        case .Identifier:
            return NSColor.black
        case .Typeidentifier:
            return NSColor(red: 0.478, green: 0.251, blue: 0.651, alpha: 1)
        case .String:
            return NSColor(red: 0.918, green: 0.216, blue: 0.071, alpha: 1)
        case .Number:
            return NSColor(red: 0.22, green: 0.18, blue: 0.827, alpha: 1)
        case .Comment, .CommentMark, .CommentURL, .DocComment, .DocCommentField:
            return NSColor(red: 0, green: 0.514, blue: 0.122, alpha: 1)
        case .AttributeBuiltin:
            return NSColor(red: 0.796, green: 0.208, blue: 0.624, alpha: 1)
        default:
            return NSColor.green
        }
    }
}

class SwiftSyntaxHighlighter: NSObject, NSTextStorageDelegate, NSLayoutManagerDelegate {
    var textStorage: NSTextStorage
    var textView: NSTextView
    var scrollView: NSScrollView

    init(textView: NSTextView, scrollView: NSScrollView) {
        self.textStorage = textView.textStorage!
        self.scrollView = scrollView
        self.textView = textView
        super.init()
        textStorage.delegate = self
        parse()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func visibleRange() -> NSRange {
        let container = self.textView.textContainer
        let layoutManager = self.textView.layoutManager
        let textVisibleRect = self.scrollView.contentView.bounds
        let glyphRange = layoutManager!.glyphRange(forBoundingRect: textVisibleRect, in: container!)
        return layoutManager!.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
    }

    func parse() {
        guard let tokens = parseString(textStorage.string) else { return }
        let range = self.visibleRange()
        let layoutManagerList = textStorage.layoutManagers as [NSLayoutManager]
        for layoutManager in layoutManagerList {
            layoutManager.delegate = self
            layoutManager.removeTemporaryAttribute(SWIFT_ELEMENT_TYPE_KEY, forCharacterRange: range)
            for token in tokens {
                layoutManager.addTemporaryAttributes([SWIFT_ELEMENT_TYPE_KEY: token.kind], forCharacterRange: token.range)
            }
        }
    }
    
    func parseString(_ string: String) -> [Token]? {
        // Shell out to SourceKitten to obtain syntax map for string
        if(string.isEmpty){ return [] }
        let syntaxPipe = Pipe()
        let syntaxTask = Process()
        syntaxTask.launchPath = "/usr/local/bin/sourcekitten"
        syntaxTask.arguments = ["syntax", "--text", string]
        syntaxTask.standardOutput = syntaxPipe
        syntaxTask.launch()
        syntaxTask.waitUntilExit()

        let syntaxMap = NSMutableString(data: syntaxPipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8.rawValue)
        let tokens = try! JSONSerialization.jsonObject(with: syntaxMap!.data(using: String.Encoding.utf8.rawValue)!, options: []) as! [NSDictionary]
        return tokens.map { Token(kind: $0["type"] as! String, range: NSRange(location: $0["offset"] as! Int, length: $0["length"] as! Int)) }
    }

    override func textStorageDidProcessEditing(_ aNotification: Notification) {
        DispatchQueue.main.async {
            self.parse()
        }
    }
    
    func layoutManager(_ layoutManager: NSLayoutManager,
                       shouldUseTemporaryAttributes attrs: [String : Any],
                       forDrawingToScreen toScreen: Bool,
                       atCharacterIndex charIndex: Int,
                       effectiveRange effectiveCharRange: NSRangePointer?) -> [String : Any]? {
        if let type = attrs[SWIFT_ELEMENT_TYPE_KEY] as? String, toScreen {
            if let style = SyntaxKind(rawValue: type)?.colorValue {
                return [NSForegroundColorAttributeName: style]
            } else {
                print("\(type) is not a valid style")
            }
        }
        return attrs
    }
}
