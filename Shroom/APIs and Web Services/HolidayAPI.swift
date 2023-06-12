//
//  HolidayAPI.swift
//  Shroom
//
//  Created by Neth Botheju on 28/5/2023.
//

import Foundation

import Siesta

/// This code was referenced and modified from the installation guide provided by
/// BustOutSolutions/Siesta written by Paul Cantrell and 29 other contributors in 2016
/// (Link: https://swiftpackageindex.com/bustoutsolutions/siesta)
struct HolidaysAPI {

    
    private static let service = Service(baseURL: "https://date.nager.at/api/v2")
    
    static let holidaysResource: Resource = {
        HolidaysAPI.service
            .resource("/publicholidays")
            .child("\(Calendar.current.component(.year, from: Date()))")
            .child("AU")
    }()
    
}
