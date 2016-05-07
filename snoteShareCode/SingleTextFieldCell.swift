//
//  SingleTextFieldCell.swift
//  snote
//
//  Created by nevercry on 1/25/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import UIKit

public class SingleTextFieldCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak public var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - UITextField Delegate
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
