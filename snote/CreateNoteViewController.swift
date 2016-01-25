//
//  CreateNoteViewController.swift
//  snote
//
//  Created by nevercry on 1/25/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import UIKit

class CreateNoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var note = Note()
    
    struct Constents {
        
        struct CellIdentifer {
            static let NoteTitle = "Note Title Cell"
            static let NoteURL = "Note URL Cell"
            static let Note = "Note Cell"
            static let NoteContent = "Note Content Cell"
        }
        
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateModel:", name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
         NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Actions
    // 取消
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateModel(aNotification: NSNotification) {
        let textField = aNotification.object as! UITextField
        let cell = textField.superview?.superview as! UITableViewCell
        let cellId = cell.reuseIdentifier!
        
        switch cellId {
        case Constents.CellIdentifer.Note:
            note.note = textField.text!
        case Constents.CellIdentifer.NoteTitle:
            note.title = textField.text!
        case Constents.CellIdentifer.NoteURL:
            note.url = textField.text!
        default:
            break
        }
    }
    
    // MARK: - UITableView DataSource Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let row = indexPath.row
        
        var cell: UITableViewCell
        switch section {
        case 0:
            if row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellIdentifer.NoteTitle, forIndexPath: indexPath)
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellIdentifer.NoteURL, forIndexPath: indexPath)
            }
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellIdentifer.NoteContent, forIndexPath: indexPath)
            let textViewCell = cell as! TextViewTableViewCell
            textViewCell.placeholderText = "Note Content:"
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellIdentifer.Note, forIndexPath: indexPath)
        default:
            cell = UITableViewCell.init(style: .Default, reuseIdentifier: "Cell")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        var height: CGFloat
        
        switch section {
        case 0:
            height = 44.0
        case 1:
            height = 110.0
        case 2:
            height = 44.0
        default:
            height = 44.0
        }
        
        return height
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
