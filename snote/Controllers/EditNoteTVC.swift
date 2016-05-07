//
//  EditNoteTVC.swift
//  snote
//
//  Created by nevercry on 4/11/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import UIKit
import RealmSwift
import MBProgressHUD
import SwiftyJSON
import snoteShareCode


class EditNoteTVC: UITableViewController, UITextFieldDelegate {
    var note: Note?
    var realm: Realm!
    var updateParams: [String:String] = [:]
    
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var pickerAccessorView: UIToolbar!
    
    lazy var categories: Results<Category> = {
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
            static let UpdateNotes = "Note Detail Update Notes"
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
            updateParams["category"] = selectedCategory!.categoryID
            updateDoneButton()
        }
    }
    var categoryTextField: UITextField?
    var isFirstLoad = true
    var newCategoryName: String?
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        clearsSelectionOnViewWillAppear = false
        title = "修改笔记"
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
    
    // MARK: - Actions
    // Done
    @IBAction func done(sender: UIBarButtonItem) {
        view.endEditing(true)
        updateNote()
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
    
    // 创建新分类
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
            updateParams["note"] = text
        case Constents.TextFieldTag.NoteTitle.rawValue:
            updateParams["title"] = text
        case Constents.TextFieldTag.NoteURL.rawValue:
            updateParams["url"] = text
        case Constents.ContentTextViewTag:
            updateParams["content"] = text
        case Constents.TextFieldTag.CreatCategory.rawValue:
            newCategoryName = text // 创建新分类时的临时保存的分类名，来调接口
        case Constents.TextFieldTag.Category.rawValue:
            updateParams["category"] = selectedCategory!.categoryID
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
    
    
    
    // MARK: - 更新笔记
    func updateNote() {
        if updateParams.keys.count > 0 {
            try! self.realm.write({
                for (key,value) in updateParams {
                    if key == "category" {
                        note?.category = selectedCategory
                    } else {
                        note?.setValue(value, forKey: key)
                    }
                }
            })
            MBProgressHUD.showHUDAddedTo(navigationController?.view, animated: true)
            SnoteProvider.request(.UpdateNote(id: note!.noteID, params: updateParams)) { (result) in
                MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
                switch result {
                case .Success(let response):
                    let json = JSON(data: response.data)
                    
                    do {
                        try response.filterSuccessfulStatusCodes()
                    }
                    catch {
                        if let errorMsg = json["message"].string {
                            self.alertViewShow("更新笔记失败", andMessage: errorMsg)
                        } else {
                            print("error no sever message")
                            self.alertViewShow("更新笔记失败", andMessage: "error no sever message")
                        }
                        return
                    }
                    // 解析服务器数据
//                    if let dataDic = json.dictionary {
//                        let updateNote = dataDic["note"]!.dictionary!
//                        try! self.realm.write({
//                            self.note?.createdAt
//                        })
//                        
//                    }
                    
                    // 返回并更新数据
                    self.performSegueWithIdentifier(Constents.SegueIdentifer.UpdateNotes, sender: nil)
                case .Failure(let error):
                    print(error)
                    self.alertViewShow("网络请求失败", andMessage: "请检查网络连接")
                }
            }
        }
    }
    
    func updateDoneButton() {
        doneBtn.enabled = updateParams.keys.count > 0
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        
        var cell: UITableViewCell
        
        var textFieldCell: SingleTextFieldCell
        switch section {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellIdentifer.NoteTitle, forIndexPath: indexPath)
            textFieldCell = cell as! SingleTextFieldCell
            textFieldCell.textField.text = note?.title
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellIdentifer.NoteCategory, forIndexPath: indexPath)
            // 分类不属于SingleTextFieldCell类
            let tf = cell.viewWithTag(Constents.TextFieldTag.Category.rawValue) as! UITextField
            tf.text = note?.category?.name
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellIdentifer.NoteURL, forIndexPath: indexPath)
            textFieldCell = cell as! SingleTextFieldCell
            textFieldCell.textField.text = note?.url
        case 3:
            cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellIdentifer.Note, forIndexPath: indexPath)
            textFieldCell = cell as! SingleTextFieldCell
            textFieldCell.textField.text = note?.note
        case 4:
            cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellIdentifer.NoteContent, forIndexPath: indexPath)
            let textViewCell = cell as! TextViewTableViewCell
            textViewCell.textView.text = note?.content
            textViewCell.placeholderText = "笔记内容"   // 先设置textView里的内容，再设置placehodlerText 这样占位符才能正确判断是否隐藏
        default:
            cell = UITableViewCell.init(style: .Default, reuseIdentifier: "Cell")
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        var height: CGFloat
        
        switch section {
        case 4:
            height = 110.0
        default:
            height = 44.0
        }
        
        return height
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        switch section {
        case 0:
            title = "标题"
        case 1:
            title = "分类"
        case 2:
            title = "URL"
        case 3:
            title = "备注"
        case 4:
            title = "内容"
        default:
            title = ""
        }
        
        return title
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
}
