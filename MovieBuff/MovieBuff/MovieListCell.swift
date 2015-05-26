//
//  MovieListCell.swift
//  MovieBuff
//
//  Created by Zeeshan Khan on 16/05/15.
//  Copyright (c) 2015 Zeeshan Khan. All rights reserved.
//

import UIKit

class Babusha {
    
    var name: NSString?
    var age: NSString!
    
    var dob: NSString
    init(dob: NSString) {
        self.dob = dob
    }
    
}

typealias MyClosure = (name: String) -> Void

class MyClass {
    
//    var x: String // = ""   // This is okay
//    let y: String = ""   // This is a compiler error
    
    func myfun(closure: MyClosure) {
        
        println("Sexy sexy mujhe log bole, hi sexy hello sexy log bole... eeee")
        
        self.myfun { (name) -> Void in
            
        }
    }
}

class MovieListCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgVThumb: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
