//
//  NoteListViewController.swift
//  snote
//
//  Created by nevercry on 1/19/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
import SwiftyJSON


class NoteListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - 属性
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    
    
    var notes:[JSON] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()

        loadNotes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadNotes() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        
    }
    
    // MARK: - Action
    // 创建笔记
    @IBAction func createNote(sender: UIBarButtonItem) {
        
    }
    
    @IBAction func updateNotes(sender: UIStoryboardSegue) {
        loadNotes()
    }
    
    
    // MARK: - UITableView DataSource Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        
        var note = notes[indexPath.row]
        
        if cell == nil {
            cell = UITableViewCell.init(style: .Default, reuseIdentifier: "Cell")
            cell?.textLabel?.text = note["title"].string
        }
        
        return cell!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    

}
