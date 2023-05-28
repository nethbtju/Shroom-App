//
//  HolidayAPI.swift
//  Shroom
//
//  Created by Neth Botheju on 28/5/2023.
//

import Foundation

import Siesta

struct HolidaysAPI {

    private static let service = Service(baseURL: "https://date.nager.at/api/v2")
    
    static let holidaysResource: Resource = {
        HolidaysAPI.service
            .resource("/publicholidays")
            .child("2023")
            .child("AU")
    }()
    
}
