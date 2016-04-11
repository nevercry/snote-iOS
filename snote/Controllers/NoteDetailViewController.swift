//
//  NoteDetailViewController.swift
//  snote
//
//  Created by nevercry on 4/7/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import UIKit
import RealmSwift
import SafariServices

class NoteDetailViewController: UIViewController,UITextViewDelegate,SFSafariViewControllerDelegate {
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var note: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    // MARK: - 初始化
    func setup() {
        // 初始化标题栏
        title =  note?.title
        
        // 初始化笔记内容
        //*==================
        let contentArrText = NSAttributedString.init(string: (note!.content + "\n"), attributes: [
            NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleBody),
            ])
        let linkUrl = (note!.url.hasPrefix("http")) ? note!.url : ("http://" + note!.url)
        let linkArrText = NSAttributedString.init(string: (note!.url + "\n"), attributes: [
            NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleBody),
            NSLinkAttributeName:linkUrl,
            NSUnderlineStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue
            ])
        let noteArrText = NSAttributedString.init(string: ("\n\n备注：" + note!.note), attributes: [
            NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleBody),
            NSForegroundColorAttributeName:UIColor.redColor(),
            ])
        let resultArrText = NSMutableAttributedString.init()
        resultArrText.appendAttributedString(contentArrText)
        resultArrText.appendAttributedString(linkArrText)
        resultArrText.appendAttributedString(noteArrText)
        
        contentTextView.attributedText = resultArrText
        //====================*
        
        //初始化分类标签
        categoryLabel.text = note?.category?.name
    }
    
    // MARK: - Unwind Segue 从Model返回时更新
    @IBAction func noteDetailUpdate(segue: UIStoryboardSegue) {
        setup()
    }
    
    // MARK: - UITextView Delegate
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        let sfVC = SFSafariViewController(URL: URL, entersReaderIfAvailable: true)
        sfVC.delegate = self
        presentViewController(sfVC, animated: true, completion: nil)
        return false
    }
    
    // MARK: - SFSafariViewControllerDelegate
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEditNote" {
            let navVC = segue.destinationViewController as! UINavigationController
            let topVC = navVC.topViewController! as! EditNoteTVC
            topVC.note = note
        }
    }
    

}