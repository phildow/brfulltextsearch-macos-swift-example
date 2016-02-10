//
//  ViewController.swift
//  Import and Search
//
//  Created by Philip Dow on 2/9/16.
//  Copyright © 2016 Phil Dow. All rights reserved.
//

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