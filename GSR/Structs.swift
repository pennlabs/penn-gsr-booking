//
//  Structs.swift
//  GSR
//
//  Created by Yagil Burowski on 15/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import Foundation

public struct Location {
    var name : String
    var code : Int
    var path : String
}

public struct Date {
    var string : String
    var compact : String
    var day : Int
}

open class Hour : NSObject {
    var id : Int = 0
    var start : String = ""
    var end : String = ""
    var prev : Hour?
    var next : Hour?
    
    public init(id: Int, start: String, end: String, prev: Hour?) {
        self.id = id
        self.start = start
        self.end = end
        self.prev = prev
    }
}


// MARK: - Turning raw data to structs

public func generateHour(hour rawHour : AnyObject, prev: Hour?) -> Hour {
    
    if let id = rawHour.object(forKey: "id") as? Int {
        
        let start = rawHour.object(forKey: "start_time") as! String
        let end = rawHour.object(forKey: "end_time") as! String
        
        return Hour(id: id, start: start, end: end, prev: prev)
    }
    
    return Hour(id: 0, start: "", end: "",prev: nil)
    
}

public func generateRoomData(_ rawRoomData : AnyObject) -> Dictionary<String, [Hour]> {
    
    var roomData = Dictionary<String, [Hour]>()
    
    let roomDict = rawRoomData as! NSDictionary
    
    for (room, hoursArray) in roomDict {
        let title = room as! String
        let rawHours = hoursArray as! NSArray
        var hours = [Hour]()
        for (index, rawHour) in rawHours.enumerated() {
            if (index == 0) {
                let hour = generateHour(hour: rawHour as AnyObject, prev: nil)
                hours.append(hour)
            } else {
                let hour = generateHour(hour: rawHour as AnyObject, prev: nil)
                let prev = hours[index - 1]
                
                if (hour.start == prev.end) {
                    hour.prev = prev
                    prev.next = hour
                }
                
                hours.append(hour)
            }
        }
        
        roomData[title] = hours
    }
    
    return roomData
}
