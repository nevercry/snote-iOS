//
//  SingleTextFieldCell.swift
//  snote
//
//  Created by nevercry on 1/25/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import UIKit

class SingleTextFieldCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - UITextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
