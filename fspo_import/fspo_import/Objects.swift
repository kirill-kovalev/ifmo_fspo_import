//
//  Objects.swift
//  fspo_import
//
//  Created by Кирилл on 29.04.2021.
//

import Foundation


class SchedUser: Hashable {
    var id: String { name }
    var hashValue: Int { id.hashValue }
    static func == (lhs: SchedUser, rhs: SchedUser) -> Bool { lhs.id == rhs.id }
    
    init(name: String) {
        self.name = name
    }
    
    let name: String
    
    var lessons: Set<Lesson> = .init()
}

extension SchedUser {
    func lessons(isOdd: Bool, weekday: String) -> [Lesson] {
        lessons.filter({
            $0.isOdd == isOdd &&
            $0.day == weekday
        })
    }
}



class Lesson: Hashable {
    var id: String { name + "\(period)" + day + "\(isOdd)"  }
    var hashValue: Int { id.hashValue }
    static func == (lhs: Lesson, rhs: Lesson) -> Bool { lhs.id == rhs.id }
    
    init(name: String, place: String, period: Int, period_start: String, period_end: String, day: String, isOdd: Bool, tags: String? = nil) {
       self.name = name
       self.place = place
       self.period = period
       self.period_start = period_start
       self.period_end = period_end
       self.day = day
       self.isOdd = isOdd
       self.tags = tags
   }
   
   

    public let name: String
    public let place: String
    
    public let period: Int
    public let period_start: String
    public let period_end: String
    
    public let day: String
    public let isOdd: Bool
    
    var groups: Set<SchedUser> = .init()
    var preps: Set<SchedUser> = .init()
    
    var tags: String?
    var desc: String {
        """
        \(isOdd ? "Не" : "  ")четная; \(day) \(period) : \(name)
            groups: \(groups.map(\.name).joined(separator: ", "))
            teachers: \(preps.map(\.name).joined(separator: ", "))
            tags: \(tags ?? "")
        """
    }
}

extension Lesson {
    var codable: CodableData {
        .init(id: MD5(id),
              subject: name,
              groups: groups.map(\.id),
              preps: preps.map(\.id),
              lessonNum: period,
              start: period_start,
              end: period_end,
              weekday: day,
              isOdd: isOdd)
    }
    struct CodableData: Codable {
        let id: String
        let subject: String
        let groups: [String]
        let preps: [String]
        let lessonNum: Int
        
        let start: String
        let end: String
        
        let weekday: String
        let isOdd: Bool
    }
}


extension SchedUser {
    var codable: CodableData {
        .init(id: MD5(id),
              name: name)
    }
    struct CodableData: Codable {
        let id: String
        let name: String
    }
}
