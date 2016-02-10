//
//  ViewController.swift
//  Import and Search
//
//  Created by Philip Dow on 2/9/16.
//  Copyright © 2016 Phil Dow. All rights reserved.
//

/*
Copyright (c) 2016 Philip Dow

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var tableView: NSTableView!
    
    var searchService: BRSearchService! { // yuck!
        return (NSApplication.sharedApplication().delegate as! AppDelegate).searchService
    }

    var results: BRSearchResults?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        tableView.setDataSource(self)
        tableView.setDelegate(self)
    }
    
    // Search
    
    @IBAction func actionSearch(sender: AnyObject?) {
        guard let searchField = sender as? NSSearchField else {
            return
        }
        
        let searchText = searchField.stringValue
        results = searchService.search(searchText)
        tableView.reloadData()
    }
}

// MARK: - NSTableViewDataSource

extension ViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let results = results else {
            return 0
        }
        return Int(results.count())
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        guard let tableColumn = tableColumn else {
            return nil
        }
        
        let fieldName = tableColumn.identifier
        return results?.resultAtIndex(UInt(row)).valueForField(fieldName)
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        return
    }
}

// MARK: - NSTableViewDelegate

extension ViewController: NSTableViewDelegate {

}