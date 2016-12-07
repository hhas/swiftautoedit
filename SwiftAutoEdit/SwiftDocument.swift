//
//  SwiftDocument.swift
//  SwiftAutoEdit
//
//

// TO DO: Script menu needs to be enabled only when a SwiftDocument window is frontmost

// TO DO: 


import Cocoa

class SwiftDocument: NSDocument {
    
    @IBOutlet var codeView: SwiftDocumentView!
    @IBOutlet var codeScrollView: NSScrollView!
    @IBOutlet var resultView: NSTextView!
    
    var syntaxHighlighter: SwiftSyntaxHighlighter!
    
    // grotty bindings
    
    dynamic var code: NSString = ""
    dynamic var result: NSString = "" // TO DO: would be better as an array of {time, kind (.stdout/.stderr/.exit), message}, allowing result view to distinguish output from errors

    
   
    
    dynamic var scriptTask: Process? // TO DO: need to bind Run/Cancel menu items' Enabled to this
    
    

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }
    
    override func windowControllerDidLoadNib(_ windowController: NSWindowController) {
        self.codeView.setup(self.codeScrollView) // hack
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override var windowNibName: String? {
        // Returns the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
        return "SwiftDocument"
    }

    override func data(ofType typeName: String) throws -> Data {
        // TO DO: include "#!/usr/bin/swift -target x86_64-apple-macosx10.12 -F /Library/Frameworks" at start of script (or restore original "#!..." if it had one?)
        guard let data = (self.code as String).data(using: .utf8) else {
            throw NSError(domain: NSOSStatusErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't write."])
        }
        return data
    }

    override func read(from data: Data, ofType typeName: String) throws {
        guard let source = String(data: data, encoding: .utf8) else {
            throw NSError(domain: NSOSStatusErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't read."])
        }
        // TO DO: remove "#!..." line from start of script, if found
        self.code = source as NSString
    }
    
    func makeTempFile() throws -> URL {
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("temp.XXXXXX") as NSURL
        var buffer = [Int8](repeating: 0, count: Int(PATH_MAX))
        tmp.getFileSystemRepresentation(&buffer, maxLength: buffer.count)
        let fd = mkstemp(&buffer)
        if fd == -1 {
           throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: [NSLocalizedDescriptionKey: "Can't make temp file."])
        }
        return URL(fileURLWithFileSystemRepresentation: buffer, isDirectory: false, relativeTo: nil)
    }
    
    func appendToResult(string: String) {
        self.result = "\(self.result)\(string)\n" as NSString
    }
    
    @IBAction func killSwiftProcess(_ sender: Any) {
        if let task = self.scriptTask {
            task.terminate()
            self.appendToResult(string: "User killed swift process (SIGTERM)")
        }
    }
    
    @IBAction func runScript(_ sender: Any) { // TO DO: error handling!
        if self.scriptTask != nil { return }
        self.result = ""
        let tmp = try! makeTempFile()
        try! (self.code as String).write(to: tmp, atomically: true, encoding: .utf8)
        let task = Process() // TO DO: better to use NSUserUnixTask
        task.launchPath = "/usr/bin/swift"
        task.arguments = ["-target", "x86_64-apple-macosx10.12", "-F", "/Library/Frameworks", "-Onone", tmp.path] // TO DO: include "$HOME/Library/Frameworks" too (check UserDefaults as it probably has domain for getting these paths)
        // TO DO: what about environment? (in particular, encoding)
        // task.currentDirectoryPath // if not set, use current // TO DO: use $HOME?
        
        let outputPipe = Pipe()
        let output = outputPipe.fileHandleForReading
        output.readabilityHandler = {(fh: FileHandle) -> Void in
            if let text = String(data: fh.availableData, encoding: .utf8) { // TO DO: is it safe to assume buffer always ends on complete glyph? is there a better/safer way to decode a UTF8 stream into discrete Strings? // TO DO: how to determine where a logged message ends? (e.g. a long output might require >1 read to obtain it all); would it be better to defer Data->String decoding until it's actually used?
                self.performSelector(onMainThread: #selector(SwiftDocument.appendToResult), with: text, waitUntilDone: false)
            }
        }
        task.standardOutput = outputPipe
        task.standardError = outputPipe
        
        task.terminationHandler = {(task: Process) -> () in
            self.performSelector(onMainThread: #selector(SwiftDocument.appendToResult), with: "Exit status: \(task.terminationStatus)", waitUntilDone: false)
            self.scriptTask = nil
        }
        task.launch()
        self.scriptTask = task
    }

}
