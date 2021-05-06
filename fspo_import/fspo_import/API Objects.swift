//
//  API Objects.swift
//  fspo_import
//
//  Created by Кирилл on 29.04.2021.
//

import Foundation

public struct Groups_Response : Codable {
    public let result : String?
    public let count_c : Int?
    public let courses : [RCourses]?
}
public struct RCourses : Codable {
    public let course : Int?
    public let count_g : Int?
    public let groups : [RGroup]?
}
public struct RGroup: Codable {
    public let group_id : String
    public let name : String
}


public struct Teachers_Response: Codable {
    public let teachers: [RTeacher]
}

public struct RTeacher: Codable {
    public let user_id: String
    
    public let lastname: String
    public let firstname: String
    public let middlename: String
}




public struct ScheduleResponse: Codable {
    public let result: String
    public let week: String
    public let week_num: Int
    public let count_wd: Int
    public let weekdays: [RWeekday]
}
public struct RWeekday: Codable {
    public let weekday: String
    public let count_p: Int
    public let periods: [RPeriod]
}
public struct RPeriod: Codable {
    public let period: Int
    public let period_start: String
    public let period_end: String
    public let count_s: Int
    public let schedule: [RSchedule]
}
public struct RSchedule: Codable {
    public let name: String
    public let shortname: String
    public let semester: String
    public let lastname: String
    public let firstname: String
    public let middlename: String
    public let group_name: String
    public let place: String
    public let even: String?
    public let odd: String?
    public let group_part: Int
    
    public var oddType: Bool? {
        if even == nil && odd == nil { return nil }
        if even == nil { return true }
        if odd == nil { return false }
        return nil
    }
}
