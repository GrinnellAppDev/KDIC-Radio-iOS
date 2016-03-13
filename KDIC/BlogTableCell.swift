//
//  BlogTableCell.swift
//  KDIC
//
//  Created by Shaun Mataire on 3/1/16.
//  Copyright © 2016 Colin Tremblay. All rights reserved.
//

import UIKit

class BlogTableCell: UITableViewCell {
    
    @IBOutlet weak var blogPostTitle: UILabel!
    @IBOutlet weak var blogPostAuthor: UILabel!
    @IBOutlet weak var datePosted: UILabel!
    @IBOutlet weak var blogPostText: UILabel!
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}