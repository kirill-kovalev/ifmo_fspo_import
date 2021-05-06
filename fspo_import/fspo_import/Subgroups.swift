//
//  Subgroups.swift
//  fspo_import
//
//  Created by Кирилл on 29.04.2021.
//

import Foundation

class SubgroupsImport: KeepAlive {
    let fspoGroups: Array<RGroup> = URLSession.shared.syncTask(with: URL(string: "https://ifspo.ifmo.ru/api/groups?jsondata=%7B%22app_key%22%20%3A%20%22b13f556af4ed3da2f8d484a617fee76d78be1166%22%7D")!).0
        .flatMap({try? JSONDecoder().decode(Groups_Response.self, from: $0)})
        .flatMap(\.courses)?
        .compactMap(\.groups)
        .flatMap({ $0 }) ?? []

    let fspoTeachers: Array<RTeacher> = URLSession.shared.syncTask(with: URL(string: "https://ifspo.ifmo.ru/api/teachers?jsondata=%7B%22app_key%22%20%3A%20%22b13f556af4ed3da2f8d484a617fee76d78be1166%22%7D")!).0
        .flatMap({try? JSONDecoder().decode(Teachers_Response.self, from: $0)})?
        .teachers ?? []

    
    lazy var groups: Set<SchedUser> = Set(fspoGroups.flatMap({
        [
            SchedUser(name: $0.name + "/1"),
            SchedUser(name: $0.name + "/2")
        ]
    }))
    lazy var preps: Set<SchedUser> = Set(fspoTeachers.map({ SchedUser(name: "\($0.firstname) \($0.lastname) \($0.middlename)") }))
    
    lazy var schedUsers: Set<SchedUser> = { Set(Array(groups) + Array(preps)) }()

    lazy var fspoSchedule = fspoGroups
        .map(\.group_id)
        .flatMap({[
            URL(string: "https://ifspo.ifmo.ru/api/schedule?jsondata=%7B%0A%20%20%22type%22%20%3A%20%22group%22%2C%0A%20%20%22id%22%20%3A%20\($0)%2C%0A%20%20%22week%22%20%3A%20%22now%22%2C%0A%20%20%22app_key%22%20%3A%20%22b13f556af4ed3da2f8d484a617fee76d78be1166%22%0A%7D"),
            URL(string: "https://ifspo.ifmo.ru/api/schedule?jsondata=%7B%0A%20%20%22type%22%20%3A%20%22group%22%2C%0A%20%20%22id%22%20%3A%20\($0)%2C%0A%20%20%22week%22%20%3A%20%22next%22%2C%0A%20%20%22app_key%22%20%3A%20%22b13f556af4ed3da2f8d484a617fee76d78be1166%22%0A%7D"),
        ].compactMap({ $0 })
        })
        .map(URLSession.shared.syncTask)
        .compactMap(\.0)
        .map({try! JSONDecoder().decode(ScheduleResponse.self, from: $0)})
        .flatMap(\.weekdays)
        .flatMap({ weekday in
            weekday.periods.flatMap({ period in
                period.schedule.map({ (weekday, period, $0) })
            })
        })

    
    var lessons: [String: Lesson] = [:]
    
    
    func insertLesson(name: String, place: String, period: Int, period_start: String, period_end: String, day: String, isOdd: Bool,
                      group_name: String, prep_name: String) {
        var lesson = Lesson(name: name,
                            place: place,
                            period: period,
                            period_start: period_start,
                            period_end: period_end,
                            day: day,
                            isOdd: isOdd)
        lesson = lessons[lesson.id] ?? lesson
        
        if let group = schedUsers.first(where: { $0.name == group_name }) {
            lesson.groups.insert(group)
            group.lessons.insert(lesson)
        }
        
        if let prep = schedUsers.first(where: { $0.name == prep_name }) {
            lesson.preps.insert(prep)
            prep.lessons.insert(lesson)
        }
        
        lessons[lesson.id] = lesson
    }
    
    init() throws {
        _ = schedUsers
        _ = fspoSchedule
        
        for (weekday, period, fspoLesson) in fspoSchedule {
            
            let prepName = "\(fspoLesson.firstname) \(fspoLesson.lastname) \(fspoLesson.middlename)"
            var groupNames : [String] = []
            if fspoLesson.group_part == 0 {
                groupNames = [
                    fspoLesson.group_name + "/1",
                    fspoLesson.group_name + "/2",
                ]
            } else if fspoLesson.group_part == 1 {
                groupNames = [ fspoLesson.group_name + "/1"]
            } else if fspoLesson.group_part == 2 {
                groupNames = [ fspoLesson.group_name + "/2"]
            }
            
            for group_name in groupNames {
                
                if let isOdd = fspoLesson.oddType {
                    insertLesson(name: fspoLesson.name,
                                 place: fspoLesson.place,
                                 period: period.period,
                                 period_start: period.period_start,
                                 period_end: period.period_end,
                                 day: weekday.weekday,
                                 isOdd: isOdd,
                                 group_name: group_name,
                                 prep_name: prepName)
                } else {
                    insertLesson(name: fspoLesson.name,
                                 place: fspoLesson.place,
                                 period: period.period,
                                 period_start: period.period_start,
                                 period_end: period.period_end,
                                 day: weekday.weekday,
                                 isOdd: true,
                                 group_name: group_name,
                                 prep_name: prepName)
                    insertLesson(name: fspoLesson.name,
                                 place: fspoLesson.place,
                                 period: period.period,
                                 period_start: period.period_start,
                                 period_end: period.period_end,
                                 day: weekday.weekday,
                                 isOdd: false,
                                 group_name: group_name,
                                 prep_name: prepName)
                }
            }
        }
//        lessons = [:]
        
//        schedUsers.forEach({ print($0.name, $0.id) })
        
//        printLessons( lessons.map(\.value))
            
        
        let l = schedUsers.first(where: { $0.name == "Y2433/1" })?.lessons(isOdd: false, weekday: "Четверг") ?? []
        printLessons(l)
        
        
        
        let url = FileManager().homeDirectoryForCurrentUser.appendingPathComponent("Desktop")

        print("lessons")
        try JSONEncoder().encode(lessons.map(\.value.codable)).write(to: url.appendingPathComponent("lessons.json"))

        print("schedUsers")
        try JSONEncoder().encode(schedUsers.map(\.codable)).write(to: url.appendingPathComponent("schedUsers.json"))

    }
    
    func printLessons(_ lessons: Array<Lesson>) {
        lessons
        .sorted(by: { $1.period > $0.period })
        .sorted(by: { $1.day > $0.day })
        .sorted(by: {
            let a = $0.isOdd ? 1 : 0
            let b = $1.isOdd ? 1 : 0
            return a > b
        })
        .forEach({ print($0.desc) })
    }
}
