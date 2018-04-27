//
//  Contact.swift
//  SIT206-Project2
//
//  Created by Kelvin Salim on 27/4/18.
//  Copyright © 2018 Kelvin Salim. All rights reserved.
//

import Foundation

class Contact {
    
    private var _name = "";
    private var _id = "";
    
    init(id: String, name: String) {
        _id = id;
        _name = name;
    }
    
    var name: String {
        get {
            return _name;
        }
    }
    
    var id: String {
        return _id;
    }
}
























