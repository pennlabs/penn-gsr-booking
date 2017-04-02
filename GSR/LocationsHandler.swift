//
//  LocationsHandler.swift
//  GSR
//
//  Created by Yagil Burowski on 15/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import Foundation

class LocationsHandler {
    static func getLocations() -> [Location] {
        return [Location(name: "VP GSR", code: 1799, path: "/booking/vpdlc"),
                Location(name: "Weigle", code: 1722, path: "/booking/wic"),
                Location(name: "Lippincott", code: 1768, path: "/booking/lippincott"),
                Location(name: "Edu Commons", code: 848, path: "/booking/educom"),
                Location(name: "VP Sem. Rooms", code: 4409, path: "/booking/seminar"),
                Location(name: "Noldus Observer", code: 3621, path: "/booking/noldus"),
                Location(name: "Lippincott Sem. Rooms", code: 2587, path: "/booking/lippseminar"),
                Location(name: "Levin Building", code: 13489, path: "/booking/levin"),
                Location(name: "Glossberg Recording Room", code: 1819, path: "/booking/glossberg"),
                Location(name: "Dental GSR", code: 13107, path: "/booking/dental"),
                Location(name: "Dental Sem", code: 13532, path: "/booking/dentalseminar"),
                Location(name: "Biomedical Lib.", code: 505, path: "/booking/biomed")
        ]
    }
}