//
//  AppDelegate.swift
//  Import and Search
//
//  Created by Philip Dow on 2/9/16.
//  Copyright © 2016 Phil Dow. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var searchService: BRSearchService!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        resetSearchDatabaseDirectory()
        initializeSearchDatabase()
        bootstrapSearch()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    // Search database

    func initializeSearchDatabase() {
        guard let databaseDirectory = searchDatabaseDirectory()?.path else {
            print("unable to determine search db path for init")
            return
        }
        
        searchService = CLuceneSearchService(indexPath: databaseDirectory)
        if (searchService as BRSearchService?) == nil {
            print("unable to intialize search database")
        }
    }
    
    func bootstrapSearch() {
        do {
            let path = NSBundle.mainBundle().pathForResource("Test", ofType: "md")!
            let testMD = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
            let doc = BRSimpleIndexable(identifier: "1", data:[
                kBRSearchFieldNameTitle: "Markdown Test",
                kBRSearchFieldNameValue: testMD
            ])
            
            var error: NSError?
            searchService.addObjectToIndexAndWait(doc, error: &error)
            if error != nil {
                print("unable to index Test.md")
            } else {
                print("indexed Test.md")
            }
            
            let results = searchService.search("journler")
            print("\(results)")
            
        } catch {
            NSLog("Unable to read Test.md")
        }
    }
    
    func resetSearchDatabaseDirectory() {
        let fm = NSFileManager()
        
        guard let databaseDirectory = searchDatabaseDirectory() else {
            print("unable to determine search db path for reset")
            return
        }
        guard fm.fileExistsAtPath(databaseDirectory.path!) else {
            return
        }
        
        do { try fm.removeItemAtURL(databaseDirectory) } catch {
            print("unable to clean search database directory")
        }
    }
    
    // Application file paths
    
    func searchDatabaseDirectory() -> NSURL? {
        guard let appSupportDir = applicationDataDirectory() else {
            return nil
        }
        
        let url = appSupportDir.URLByAppendingPathComponent("lucene")
        let fm = NSFileManager()
        
        if !fm.fileExistsAtPath(url.path!) {
            print("creating search directory")
            do { try fm.createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: [:]) } catch {
                print("unable to create search directory")
                return nil
            }
        }
        
        return url
    }
    
    func applicationDataDirectory() -> NSURL? {
        guard let supportDir = applicationSupportDirectory(),
              let bundleID = NSBundle.mainBundle().bundleIdentifier else {
            return nil
        }
        return supportDir.URLByAppendingPathComponent(bundleID)
    }
    
    func applicationSupportDirectory() -> NSURL? {
        return NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)[0]
    }

    // Search import
    
    @IBAction func actionImport(sender: AnyObject?) {
        let op = NSOpenPanel()
        
        op.title = NSLocalizedString("Select plain text files for import, e.g. markdown or code", comment: "")
        op.allowsMultipleSelection = true
        op.canChooseDirectories = false
        op.canChooseFiles = true
        
        op.beginWithCompletionHandler { (result: Int) -> Void in
            if result == NSFileHandlingPanelOKButton {
                self.importFiles(op.URLs)
            }
        }
    }
    
    func importFiles(URLs: [NSURL]) {
        // TODO: batch insert
        for URL in URLs {
            importFile(URL)
        }
    }
    
    func importFile(URL: NSURL) {
        guard let path = URL.path else {
            print("unable to determine path for url: \(URL)")
            return
        }
        
        do {
            let text = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
            let filename = URL.URLByDeletingPathExtension!.lastPathComponent!
            
            let doc = BRSimpleIndexable(identifier: filename, data:[
                kBRSearchFieldNameTitle: filename,
                kBRSearchFieldNameValue: text
            ])
        
            var error: NSError?
            searchService.addObjectToIndexAndWait(doc, error: &error)
            
            if error != nil {
                print("unable to index \(path)")
            } else {
                print("indexed \(path)")
            }
            
            
        } catch {
            print("unable to read file \(path)")
        }
    }
    
    // Search action
    
    @IBAction func actionSearch(sender: AnyObject?) {
        // why isn't my view controller in the responder chain for a toolbar action?
        if let vc = NSApplication.sharedApplication().mainWindow?.contentViewController as? ViewController {
            vc.actionSearch(sender)
        }
    }

}

