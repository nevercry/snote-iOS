//
//  NoteListViewController.swift
//  snote
//
//  Created by nevercry on 1/19/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON
import RealmSwift


class NoteListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - 属性
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var realm: Realm!
    
    
    lazy var notes: Results<Note> = {
        return self.realm.objects(Note).sorted("createdAt")
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()

        loadNotes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadNotes() {
        
        if notes.count == 0 {
            // 没有数据，从服务端获取
            MBProgressHUD.showHUDAddedTo(view, animated: true)
            SnoteProvider.request(.Notes, completion: { (result) in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                switch result {
                case .Success(let response):
                    let json = JSON(data: response.data)
                    
                    do {
                        try response.filterSuccessfulStatusCodes()
                    }
                    catch {
                        if let errorMsg = json["message"].string {
                            self.alertViewShow("登录失败", andMessage: errorMsg)
                        } else {
                            print("error no sever message")
                        }
                        return
                    }
                    // 解析服务器数据
                    if let noteArr = json.array {
                        for note in noteArr {
                            let _note = Note()
                            _note.noteID = note["_id"].string!
                            _note.title = note["title"].string!
                            _note.url = note["url"].string!
                            _note.note = note["note"].string!
                            let dateStr = note["meta"]["createAt"].string!
                            _note.createdAt = DateHelper().transToDate(dateStr)
                            
                            let _category =  Category()
                            _category.categoryID = note["category"]["_id"].string!
                            _category.name = note["category"]["name"].string!
                            
                            _note.category = _category
                            
                            try! self.realm.write({
                                self.realm.add(_note, update: true)
                                self.realm.add(_category, update: true)
                            })
                        }
                        self.tableView.reloadData()
                    }
                case .Failure(let error):
                    print(error)
                    self.alertViewShow("网络请求失败", andMessage: "请检查网络连接")
                }
            })
        }
    }
    
    // MARK: - Action
    // 创建笔记
    @IBAction func createNote(sender: UIBarButtonItem) {
        
    }
    
    @IBAction func updateNotes(sender: UIStoryboardSegue) {
        tableView.reloadData()
    }
    
    
    // MARK: - UITableView DataSource Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let note = notes[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("NoteCell")
        cell?.textLabel?.text = note.title
        cell?.detailTextLabel?.text = note.category?.name
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let segueID = segue.identifier
        
        if segueID == "showNoteDetail" {
            let cell = sender as! UITableViewCell
            let index = tableView.indexPathForCell(cell)!
            let note = notes[index.row]
            let noteDetailControl = segue.destinationViewController as! NoteDetailViewController
            noteDetailControl.note = note
        }
    }
    
    
    
    

}
