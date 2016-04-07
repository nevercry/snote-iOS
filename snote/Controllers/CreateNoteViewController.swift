//
//  CreateNoteViewController.swift
//  snote
//
//  Created by nevercry on 1/25/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import UIKit
import SwiftyJSON
import MBProgressHUD
import RealmSwift


class CreateNoteViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var pickerAccessorView: UIToolbar!
    
    var realm: Realm!
    var note = Note()
    
    lazy var categories:Results<Category> = {
        return self.realm.objects(Category).sorted("createdAt")
    }()
    
    struct Constents {
        
        struct CellIdentifer {
            static let NoteTitle = "Note Title Cell"
            static let NoteURL = "Note URL Cell"
            static let Note = "Note Cell"
            static let NoteContent = "Note Content Cell"
            static let NoteCategory = "Note Category Cell"
        }
        
        struct SegueIdentifer {
            static let UpdateNotes = "Update Notes"
        }
        
        enum TextFieldTag: Int {
            case Category = 1   // 分类上的tf
            case NoteTitle = 2
            case NoteURL = 3
            case Note = 4
            case CreatCategory = 5 // 创建分类时弹出AlerView上的tf
        }
        
        static let ContentTextViewTag = 6
        
        
    }
    
    // MARK: - 自定义变量
    var selectedCategory: Category? {
        didSet {
            categoryTextField?.text = selectedCategory?.name
            note.category = selectedCategory
            updateDoneButton()
        }
    }
    var categoryTextField: UITextField?
    var isFirstLoad = true
    var newCategoryName: String?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreateNoteViewController.updateModel(_:)), name: UITextFieldTextDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreateNoteViewController.updateModel(_:)), name: UITextViewTextDidChangeNotification, object: nil)
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
    // Done
    @IBAction func done(sender: UIBarButtonItem) {
        view.endEditing(true)
        createNote()
    }
    
    // 取消
    @IBAction func cancel(sender: UIBarButtonItem) {
        view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // categoryAccessoryView Done
    @IBAction func categoryDidSelect(sender: AnyObject) {
        let row = pickerView.selectedRowInComponent(0)
        if categories.count > 0 {
            selectedCategory = categories[row]
        }
        view.endEditing(true)
    }
    
    @IBAction func creatNewCategory(sender: AnyObject) {
        let alertC = UIAlertController(title: "创建新分类", message: "请输入分类名", preferredStyle: .Alert)
        alertC.addTextFieldWithConfigurationHandler { (textField) in
            textField.tag = Constents.TextFieldTag.CreatCategory.rawValue
            textField.delegate = self
        }
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        let doneAction = UIAlertAction(title: "确定", style: .Default) { (action) in
            self.createCategory(self.newCategoryName)
        }
        
        alertC.addAction(cancelAction)
        alertC.addAction(doneAction)
        
        presentViewController(alertC, animated: true, completion: nil)
    }
    
    func updateModel(aNotification: NSNotification) {
        let object = aNotification.object
        
        let tag = object!.tag
        
        let text = (object?.text)! as String
        
        switch tag {
        case Constents.TextFieldTag.Note.rawValue:
            note.note = text
        case Constents.TextFieldTag.NoteTitle.rawValue:
            note.title = text
        case Constents.TextFieldTag.NoteURL.rawValue:
            note.url = text
        case Constents.ContentTextViewTag:
            note.content = text
        case Constents.TextFieldTag.CreatCategory.rawValue:
            newCategoryName = text // 创建新分类时的临时保存的分类名，来调接口
        case Constents.TextFieldTag.Category.rawValue:
            note.category = selectedCategory
        default:
            break
        }
        
        updateDoneButton()
    }
    // MARK: - 获取分类数据
    func loadCategories() {
        MBProgressHUD.showHUDAddedTo(view.window, animated: true)
        SnoteProvider.request(.Categories) { (result) in
            MBProgressHUD.hideAllHUDsForView(self.view.window, animated: true)
            switch result {
            case .Success(let response):
                let json = JSON(data: response.data)
                
                do {
                    try response.filterSuccessfulStatusCodes()
                }
                catch {
                    if let errorMsg = json["message"].string {
                        self.alertViewShow("获取分类失败", andMessage: errorMsg)
                    } else {
                        print("error no sever message")
                        self.alertViewShow("获取分类失败", andMessage: "error no sever message")
                    }
                    return
                }
                // 解析服务器数据
                if let catArr = json.array {
                    for cat in catArr {
                        let category = Category()
                        category.categoryID = cat["_id"].string!
                        category.name = cat["name"].string!
                        let dateStr = cat["meta"]["createAt"].string!
                        category.createdAt = DateHelper().transToDate(dateStr)
                        
                        try! self.realm.write({
                            self.realm.add(category, update: true)
                        })
                    }
                }
                // 获取成功后显示分类pickerView
                self.pickerView.reloadAllComponents()
                // 不用再重复更新
                self.isFirstLoad = false
            case .Failure(let error):
                print(error)
                self.alertViewShow("网络请求失败", andMessage: "请检查网络连接")
            }
        }
    }
    
    // MARK: - 创建新分类
    func createCategory(name: String?) {
        if let _ = name {
            MBProgressHUD.showHUDAddedTo(view.window, animated: true)
            SnoteProvider.request(.CreateCategory(name: name!), completion: { (result) in
                MBProgressHUD.hideAllHUDsForView(self.view.window, animated: true)
                switch result {
                case .Success(let response):
                    let json = JSON(data: response.data)
                    
                    do {
                        try response.filterSuccessfulStatusCodes()
                    }
                    catch {
                        if let errorMsg = json["message"].string {
                            self.alertViewShow("创建分类失败", andMessage: errorMsg)
                        } else {
                            print("error no sever message")
                            self.alertViewShow("创建分类失败", andMessage: "error no sever message")
                        }
                        return
                    }
                    // 解析服务器数据
                    if let cat = json.dictionary {
                        
                        let category = Category()
                        category.categoryID = cat["_id"]!.string!
                        category.name = cat["name"]!.string!
                        let dateStr = cat["meta"]!["createAt"].string!
                        category.createdAt = DateHelper().transToDate(dateStr)
                        
                        try! self.realm.write({
                            self.realm.add(category, update: true)
                        })
                    }
                    // 获取成功后显示分类pickerView
                    self.pickerView.reloadAllComponents()
                case .Failure(let error):
                    print(error)
                    self.alertViewShow("网络请求失败", andMessage: "请检查网络连接")
                }
            })
        } else {
            alertViewShow("分类名为空", andMessage: "请重新填写")
        }
    }
    
    // 创建笔记
    func createNote() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
//        Alamofire.request(.POST, "http://10.0.1.9:3000/notes", parameters: note.toParameters(), encoding: .JSON)
//            .responseJSON { response in
//                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
//                print(response.request)  // original URL request
//                print(response.response) // URL response
//                print(response.data)     // server data
//                print(response.result)   // result of response serialization
//                
//                switch response.result {
//                case .Failure:
//                    self.alertViewShow("请求失败", andMessage: "\(response.result.error)")
//                case .Success:
//                    self.alerViewShow("创建成功", andMessage: "", andHandler: { action in
//                        self.performSegueWithIdentifier(Constents.SegueIdentifer.UpdateNotes, sender: nil)
//                    })
//                }
//        }
        
    }
    
    // MARK: = 显示选择分类PickerView
    func showCategoriesPickerView() {
        
    }
    
    func updateDoneButton() {
        // 改变Done Button
        doneBtn.enabled = (note.title.characters.count > 0 && note.category != nil)
    }
    
    // MARK: - UITableView DataSource Delegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let row = indexPath.row
        
        var cell: UITableViewCell
        switch section {
        case 0:
            if row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellIdentifer.NoteTitle, forIndexPath: indexPath)
            } else if row == 1 {
                cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellIdentifer.NoteCategory, forIndexPath: indexPath)
            } else if row == 2 {
                cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellIdentifer.NoteURL, forIndexPath: indexPath)
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellIdentifer.Note, forIndexPath: indexPath)
            }
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellIdentifer.NoteContent, forIndexPath: indexPath)
            let textViewCell = cell as! TextViewTableViewCell
            textViewCell.placeholderText = "Note Content:"
        default:
            cell = UITableViewCell.init(style: .Default, reuseIdentifier: "Cell")
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        var height: CGFloat
        
        switch section {
        case 0:
            height = 44.0
        case 1:
            height = 110.0
        default:
            height = 44.0
        }
        
        return height
    }
    
    // MARK: UIPickerViewDelegate and DataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if categories.count > 0 {
            let category = categories[row]
            selectedCategory = category
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let category = categories[row]
        return category.name
    }
    
    
    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == Constents.TextFieldTag.Category.rawValue {
            // 从服务器获取分类列表
            if (isFirstLoad) {
                loadCategories()
            }
            
            textField.inputView = pickerView
            textField.inputAccessoryView = pickerAccessorView
            categoryTextField = textField
        }
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

extension String {
    func isEmptyOrWhitespace() -> Bool {
        
        if(self.isEmpty) {
            return true
        }
        
        return (self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "")
    }
}


