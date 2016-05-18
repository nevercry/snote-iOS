//
//  ShareViewController.swift
//  snoteShare
//
//  Created by nevercry on 4/13/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import UIKit
import snoteShareCode
import MobileCoreServices
import RealmSwift

class ShareViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    struct Constents {
        struct CellID {
            static let Title = "Note Title Cell"
            static let URL = "Note URL Cell"
            static let Content = "Note Content Cell"
            static let Note = "Note Note Cell"
            static let Category = "Note Category Cell"
        }
        
        static let CreateCategoryTextFieldTag = 1
        static let NoteTextFieldTag = 2
        static let CategoryTextFieldTag = 3
        static let TitleTextFieldTag = 4
    }
    
    var note = Note()
    var realm: Realm!
    
    lazy var categories:Results<Category> = {
        return self.realm.objects(Category).sorted("createdAt")
    }()
    
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var pickerAccessorView: UIToolbar!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    
    
    // MARK: - Actions
    // Done
    @IBAction func done(sender: UIBarButtonItem) {
        view.endEditing(true)
        createNote()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
    }
    
    // MARK: - 选择分类 categoryAccessoryView Done
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
            textField.tag = Constents.CreateCategoryTextFieldTag
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
    
    
    lazy var urlSession: NSURLSession = {
        // 初始化urlSession
        var config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPAdditionalHeaders = ["x-access-token":SnoteUserDefaults.token]
        config.timeoutIntervalForRequest = 10 // 网络请求超时设置10秒，不能再长了，时间宝贵
        var session = NSURLSession(configuration: config)
        return session
    }()
    
    lazy var activityView: UIActivityIndicatorView = {
        var acV = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
        acV.hidesWhenStopped = true
        let size = UIScreen.mainScreen().bounds.size
        acV.center = CGPointMake(size.width/2, size.height/2)
        self.view.addSubview(acV)
        acV.stopAnimating()
        return acV
    }()
    
    // MARK: - 获取Categories 数据
    func loadCategories() {
        let url = NSURL(string: "http://10.0.1.15:3000/api/v1/categories")
        let urlReq = NSURLRequest(URL: url!)
        self.activityView.startAnimating()
        self.urlSession.dataTaskWithRequest(urlReq) { (data, res, err) in
            dispatch_async(dispatch_get_main_queue(), { 
                self.activityView.stopAnimating()
            })
            if (err != nil) {
                print("err happenning \(err)")
                dispatch_async(dispatch_get_main_queue(), {
                    self.categoryTextField?.endEditing(true)
                    let alertC = UIAlertController.init(title: "网络错误", message: "连接错误", preferredStyle: .Alert)
                    let dfAction = UIAlertAction.init(title: "确定", style: .Cancel, handler: nil)
                    alertC.addAction(dfAction)
                    self.presentViewController(alertC, animated: true, completion: nil)
                })
            } else {
                let httpRes = res as! NSHTTPURLResponse
                let statusCode = httpRes.statusCode
                let jsonData = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                print("data is \(jsonData)" )
                
                if (statusCode >= 200 && statusCode < 299) {
                    let dataArr = jsonData as! NSArray
                    
                    var cats:[Category] = []
                    for cat in dataArr {
                        let category = Category()
                        let catDic = cat as! NSDictionary
                        category.categoryID = catDic["_id"] as! String
                        category.name = catDic["name"] as! String
                        let dateStr = catDic["meta"]!["createAt"] as! String
                        category.createdAt = self.transToDate(dateStr)
                        
                        cats.append(category)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { 
                        try! self.realm.write({
                            self.realm.add(cats, update: true)
                        })
                    })
                    
                    // 获取成功后显示分类pickerView
                    // 不用再重复更新
                    self.isFirstLoad = false
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.pickerView.reloadAllComponents()
                    })
                } else {
                    let errorDic = jsonData as! NSDictionary
                    let errMsg = errorDic["message"] as! String
                    self.categoryTextField?.endEditing(true)
                    let alertC = UIAlertController.init(title: "网络错误", message: errMsg, preferredStyle: .Alert)
                    let dfAction = UIAlertAction.init(title: "确定", style: .Cancel, handler: nil)
                    alertC.addAction(dfAction)
                    self.presentViewController(alertC, animated: true, completion: nil)
                }
            }
        }.resume()
    }
    
    // MARK: - 创建新分类
    func createCategory(name: String?) {
        if let _ = name {
            let url = NSURL(string: "http://10.0.1.15:3000/api/v1/categories")
            let urlReq = NSMutableURLRequest(URL: url!)
            urlReq.HTTPMethod = "POST"
            let params = ["name":name!]
            let bodyData = try! NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
            urlReq.HTTPBody = bodyData
            urlReq.setValue("application/json", forHTTPHeaderField: "Content-type")
            urlReq.setValue("application/json", forHTTPHeaderField: "Accept")
            urlReq.setValue("\(bodyData.length)", forHTTPHeaderField: "Content-Length")
            
//            print("url body is \(bodyData)")
            
            self.activityView.startAnimating()
            self.urlSession.dataTaskWithRequest(urlReq, completionHandler: { (data, res, err) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityView.stopAnimating()
                })
                
                if (err != nil) {
                    print("err happenning \(err)")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.categoryTextField?.endEditing(true)
                        let alertC = UIAlertController.init(title: "网络错误", message: "连接错误", preferredStyle: .Alert)
                        let dfAction = UIAlertAction.init(title: "确定", style: .Cancel, handler: nil)
                        alertC.addAction(dfAction)
                        self.presentViewController(alertC, animated: true, completion: nil)
                    })
                } else {
                    let httpRes = res as! NSHTTPURLResponse
                    let statusCode = httpRes.statusCode
                    let jsonData = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    print("data is \(jsonData)" )
                    
                    if (statusCode >= 200 && statusCode < 299) {
                        // 请求成功
                        // 解析服务器数据
                        let catDic = jsonData as! NSDictionary
                        
                        let category = Category()
                        category.categoryID = catDic["_id"] as! String
                        category.name = catDic["name"] as! String
                        let dateStr = catDic["meta"]!["createAt"] as! String
                        category.createdAt = self.transToDate(dateStr)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            try! self.realm.write({
                                self.realm.add(category, update: true)
                            })
                            
                            // 获取成功后显示分类pickerView
                            self.pickerView.reloadAllComponents()
                        })
                    
                    } else {
                        let errorDic = jsonData as! NSDictionary
                        let errMsg = errorDic["message"] as! String
                        self.categoryTextField?.endEditing(true)
                        let alertC = UIAlertController.init(title: "网络错误", message: errMsg, preferredStyle: .Alert)
                        let dfAction = UIAlertAction.init(title: "确定", style: .Cancel, handler: nil)
                        alertC.addAction(dfAction)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.presentViewController(alertC, animated: true, completion: nil)
                        })
                    }
                }
            }).resume()
        } else {
            // 没有填写分类名 警告
            self.categoryTextField?.endEditing(true)
            let alertC = UIAlertController.init(title: "分类名为空", message: "请重新填写", preferredStyle: .Alert)
            let dfAction = UIAlertAction.init(title: "确定", style: .Cancel, handler: nil)
            alertC.addAction(dfAction)
            self.presentViewController(alertC, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - 创建笔记
    func createNote() {
        self.activityView.startAnimating()
        
        let url = NSURL(string: "http://10.0.1.15:3000/api/v1/notes")
        let urlReq = NSMutableURLRequest(URL: url!)
        urlReq.HTTPMethod = "POST"
        let params = ["title": note.title, "url": note.url, "content": note.content, "note": note.note, "category": note.category!.categoryID]
        let bodyData = try! NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
        urlReq.HTTPBody = bodyData
        urlReq.setValue("application/json", forHTTPHeaderField: "Content-type")
        urlReq.setValue("application/json", forHTTPHeaderField: "Accept")
        urlReq.setValue("\(bodyData.length)", forHTTPHeaderField: "Content-Length")
        
        self.urlSession.dataTaskWithRequest(urlReq, completionHandler: { (data, res, err) in
            dispatch_async(dispatch_get_main_queue(), {
                self.activityView.stopAnimating()
            })
            
            if (err != nil) {
                print("err happenning \(err)")
                dispatch_async(dispatch_get_main_queue(), {
                    let alertC = UIAlertController.init(title: "网络错误", message: "连接错误", preferredStyle: .Alert)
                    let dfAction = UIAlertAction.init(title: "确定", style: .Cancel, handler: nil)
                    alertC.addAction(dfAction)
                    self.presentViewController(alertC, animated: true, completion: nil)
                })
            } else {
                let httpRes = res as! NSHTTPURLResponse
                let statusCode = httpRes.statusCode
                let jsonData = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                print("data is \(jsonData)" )
                
                if (statusCode >= 200 && statusCode < 299) {
                    // 请求成功
                    // 解析服务器数据
                    let noteDic = jsonData as! NSDictionary
                    
                    self.note.noteID = noteDic["_id"] as! String
                    let dateStr = noteDic["meta"]!["createAt"] as! String
                    self.note.createdAt = self.transToDate(dateStr)
                    
                    
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        try! self.realm.write({
                            self.realm.add(self.note, update: true)
                        })
                        
                        self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
                        
                        
                    })
                    
                } else {
                    let errorDic = jsonData as! NSDictionary
                    let errMsg = errorDic["message"] as! String
                    let alertC = UIAlertController.init(title: "网络错误", message: errMsg, preferredStyle: .Alert)
                    let dfAction = UIAlertAction.init(title: "确定", style: .Cancel, handler: nil)
                    alertC.addAction(dfAction)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alertC, animated: true, completion: nil)
                    })
                }
            }
        }).resume()
    }

    
    func updateDoneButton() {
        // 改变Done Button
        doneBtn.enabled = (note.title.characters.count > 0 && note.category != nil)
    }
    
    // MARK: － 更新Model
    
    func updateModel(aNotification: NSNotification) {
        let object = aNotification.object
        
        let tag = object!.tag
        
        let text = (object?.text)! as String
        switch tag {
        case Constents.NoteTextFieldTag:
            note.note = text
        case Constents.CreateCategoryTextFieldTag:
            newCategoryName = text // 创建新分类时的临时保存的分类名，来调接口
        case Constents.CategoryTextFieldTag:
            note.category = selectedCategory
        case Constents.TitleTextFieldTag:
            note.title = text
        default:
            break
        }
        
        updateDoneButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化Realm
        // 默认把数据库存在 App Group里
        let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.nevercry.snote")!
        let realmURL = directory.URLByAppendingPathComponent("db.realm")
        
        // 数据库迁移设置
        Realm.Configuration.defaultConfiguration = Realm.Configuration(fileURL: realmURL, readOnly: false, schemaVersion: 1, migrationBlock: { (migration, oldSchemaVersion) in
            if (oldSchemaVersion < 1) {
                migration.enumerate(Category.className()) { oldObject, newObject in
                    // combine name fields into a single field
                    newObject!["createdAt"] = NSDate(timeIntervalSince1970: 1)
                }
            }
        })
        
        realm = try! Realm()
        
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = item.attachments?.first as? NSItemProvider {
                
                let propertyList = String(kUTTypePropertyList)
                
                if itemProvider.hasItemConformingToTypeIdentifier(propertyList) {
                    itemProvider.loadItemForTypeIdentifier(propertyList, options: nil, completionHandler: { (diction, error) in
                        if let shareDic = diction as? NSDictionary {
                            if let results = shareDic.objectForKey(NSExtensionJavaScriptPreprocessingResultsKey) as? NSDictionary {
                                let shareTitle = results.objectForKey("title") as? NSString
                                let shareUrl = results.objectForKey("url") as? NSString
                                let shareContent = item.attributedContentText?.string
                                
                                self.note.title = shareTitle as! String
                                self.note.url = shareUrl as! String
                                self.note.content = shareContent! as String
                                
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            }
            print("分享内容是: \(item.attributedContentText?.string)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShareViewController.updateModel(_:)), name: UITextFieldTextDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShareViewController.updateModel(_:)), name: UITextViewTextDidChangeNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        
        switch section {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellID.Title, forIndexPath: indexPath)
            let cusCell = cell as! SingleTextFieldCell
            cusCell.textField.text = self.note.title
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellID.URL, forIndexPath: indexPath)
            cell.textLabel?.text = self.note.url
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellID.Content, forIndexPath: indexPath)
            cell.textLabel?.text = self.note.content
        case 3:
            cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellID.Note, forIndexPath: indexPath)
        case 4:
            cell = tableView.dequeueReusableCellWithIdentifier(Constents.CellID.Category, forIndexPath: indexPath)
        default:
            cell = UITableViewCell.init(style: .Default, reuseIdentifier: "Cell")
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height: CGFloat = 44.0
        return height
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        switch section {
        case 0:
            title = "标题"
        case 1:
            title = "URL"
        case 2:
            title = "内容"
        case 3:
            title = "备注"
        case 4:
            title = "分类"
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
        if textField.tag == Constents.CategoryTextFieldTag {
            // 从服务器获取分类列表
            if (isFirstLoad) {
                loadCategories()
            }
            
            textField.inputView = pickerView
            textField.inputAccessoryView = pickerAccessorView
            categoryTextField = textField
        }
    }
    
    // MARK: -  Helper Methods
    func transToDate(dateString: String) -> NSDate {
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormater.dateFromString(dateString)!
    }
    
}
