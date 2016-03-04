//
//  PostTableViewCell.swift
//  Rant App
//
//  Created by Aaron Epstein on 3/1/16.
//  Copyright © 2016 Rant-App. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    //MARK: Properties

    @IBOutlet weak var PostTextLabel: UILabel!
    @IBOutlet weak var TimeStampLabel: UILabel!
    @IBOutlet weak var TagsLabel: UILabel!
    @IBOutlet weak var CountLabel: UILabel!
    @IBOutlet weak var ClapImage: UIImageView!
    
    @IBOutlet weak var ReplyButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
