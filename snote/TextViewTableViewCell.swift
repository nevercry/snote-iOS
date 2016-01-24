//
//  TextViewTableViewCell.swift
//  snote
//
//  Created by nevercry on 1/25/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import UIKit

class TextViewTableViewCell: UITableViewCell, UITextViewDelegate {
    
    var placeholderText: String? {
        didSet {
            placeholderLabel.text = placeholderText 
        }
    }
    private var placeholderLabel : UILabel!

    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
           
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        placeholderLabel = UILabel()
        placeholderLabel.text = placeholderText ?? "Set Placeholder Text!"
        placeholderLabel.font = UIFont.italicSystemFontOfSize(textView.font!.pointSize)
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPointMake(5, textView.font!.pointSize / 2)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabel.hidden = !textView.text.isEmpty
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = !textView.text.isEmpty
    }
    

}
