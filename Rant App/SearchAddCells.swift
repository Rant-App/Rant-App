//
//  SearchAddCells.swift
//  Rant App
//
//  Created by Aaron Epstein on 3/10/16.
//  Copyright © 2016 Rant-App. All rights reserved.
//

import UIKit

class SearchAddCells: UITableViewCell {
    //MARK: Properties
    
    @IBOutlet weak var AddBtn: AddUIButton!
    @IBOutlet weak var TextLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
