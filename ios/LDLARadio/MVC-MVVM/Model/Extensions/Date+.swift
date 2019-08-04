//
//  Date+.swift
//  LDLARadio
//
//  Created by fox on 22/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation

extension Date {
    
    /// Conversion from date into more human readable time ago:
    /// years/monts/days/hours/an hour/minutes/seconds ago, or
    /// last year/month/yesterday/now
    func toInfo() -> String? {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: now)
        if let year = components.year {
            if year >= 2 {
                return "\(year) years ago"
            }
            if year >= 1 {
                return "Last year"
            }
        }
        if let month = components.month {
            if month >= 2 {
                return "\(month) months ago"
            }
            if month >= 1 {
                return "Last month"
            }
        }
        if let day = components.day {
            if day >= 2 {
                return "\(day) days ago"
            }
            if day >= 1 {
                return "Yesterday"
            }
        }
        if let hour = components.hour {
            if hour >= 2 {
                return "\(hour) hours ago"
            }
            if hour >= 1 {
                return "An hour ago"
            }
        }
        if let minute = components.minute {
            if minute >= 2 {
                return "\(minute) minutes ago"
            }
            if minute >= 1 {
                return "A minute ago"
            }
        }
        if let second = components.second {
            if second >= 2 {
                return "\(second) seconds ago"
            }
        }
        return "Just now"
    }
    
    func year() -> String? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: Date())
        if let year = components.year {
            return "\(year)"
        }
        return nil
    }
}
