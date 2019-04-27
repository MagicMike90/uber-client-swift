//
//  DataService.swift
//  uber-clone
//
//  Created by Michael Luo on 27/4/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import Firebase
import UIKit

// Get a reference to the storage service using the default Firebase App
let DB_BASE  = Database.database().reference()

class DataService {
    static let instance = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USER = DB_BASE.child("user")
    private var _REF_DRIVER = DB_BASE.child("driver")
    private var _REF_TRIPS = DB_BASE.child("trips")

    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USER
    }
    
    var REF_DRIVERS: DatabaseReference {
        return _REF_DRIVER
    }
    
    var REF_TRIPS: DatabaseReference {
        return _REF_TRIPS
    }
    
    func createFirebase(uid: String, userData: Dictionary<String, Any>, isDriver: Bool) -> Void {
        if isDriver {
            REF_DRIVERS.child(uid).updateChildValues(userData)
        } else {
            REF_USERS.child(uid).updateChildValues(userData)
        }
    }
}
