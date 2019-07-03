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
//let DB_BASE  = Database.database().reference()

class DataService {
    static let instance = DataService()

    private var _REF_BASE: DatabaseReference!

    //Initializer access level change now
    private init() {
         self._REF_BASE = Database.database().reference()
    }

    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }

    var REF_USERS: DatabaseReference {
        return  _REF_BASE.child("user")
    }

    var REF_DRIVERS: DatabaseReference {
        return _REF_BASE.child("driver")
    }

    var REF_TRIPS: DatabaseReference {
        return _REF_BASE.child("trips")
    }

    func createFirebase(uid: String, userData: Dictionary<String, Any>, isDriver: Bool) {
        if isDriver {
            REF_DRIVERS.child(uid).updateChildValues(userData)
        } else {
            REF_USERS.child(uid).updateChildValues(userData)
        }
    }
    
    func driverIsAvailable(key: String, handler: @escaping (_ status: Bool?) -> Void) {
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let driverSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for driver in driverSnapshot {
                    if driver.key == key {
                        if driver.childSnapshot(forPath: ACCOUNT_PICKUP_MODE_ENABLED).value as? Bool == true {
                            if driver.childSnapshot(forPath: DRIVER_IS_ON_TRIP).value as? Bool == true {
                                handler(false)
                            } else {
                                handler(true)
                            }
                        }
                    }
                }
            }
        })
    }
}
