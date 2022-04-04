//
//  CalcCalendar.swift
//  HeartManager
//
//  Created by 中西康之 on 2019/05/08.
//  Copyright © 2019 中西康之. All rights reserved.
//

import Foundation

protocol CalendarLogic: class {
    func dateManager(year: Int, month: Int)
    func numberOfWeeks(year: Int, month: Int)
}

class CalendarUseCase: CalendarLogic {
    
    var responseForCalendar: ResponseForCalendar?
    
    private let daysPerWeek = 7
    private let isLeapYear = { (year: Int) in year % 400 == 0 || (year % 4 == 0 && year % 100 != 0) }
    public let zellerCongruence = { (year: Int, month: Int, day: Int) in (year + year/4 - year/100 + year/400 + (13 * month + 8)/5 + day) % 7 }
    
    func dateManager(year: Int, month: Int) {
        let firstDayOfWeek = dayOfWeek(year, month, 1)
        let numberOfCells = numberOfWeeks(year, month) * daysPerWeek
        let days = numberOfDays(year, month)
        
        var PreviousYear = year
        var PreviousMonth = month - 1
        if month == 1 {
            PreviousYear = year - 1
            PreviousMonth = 12
        }
        let PreviousMonthDays = numberOfDays(PreviousYear, PreviousMonth)
        let daysArray = alignmentOfDays(firstDayOfWeek, numberOfCells, days, PreviousMonthDays)
        
        
        responseForCalendar?.responseDateManager(response: daysArray)
    }
    
    func numberOfWeeks(year: Int, month: Int) {
        let weeks = numberOfWeeks(year, month)
        responseForCalendar?.responseNumberOfWeeks(response: weeks)
    }
    
}

//MARK:- Core Logic
extension CalendarUseCase {

    public func dayOfWeek(_ year: Int, _ month: Int, _ day: Int) -> Int {
        var year = year
        var month = month
        if month == 1 || month == 2 {
            year -= 1
            month += 12
        }
        return zellerCongruence(year, month, day)
    }
    
    private func numberOfWeeks(_ year: Int, _ month: Int) -> Int {
        if conditionFourWeeks(year, month) {
            return 4
        } else if conditionSixWeeks(year, month) {
            return 6
        } else {
            return 5
        }
    }
    
    private func numberOfDays(_ year: Int, _ month: Int) -> Int {
        var monthMaxDay = [1:31, 2:28, 3:31, 4:30, 5:31, 6:30, 7:31, 8:31, 9:30, 10:31, 11:30, 12:31]
        if month == 2, isLeapYear(year) {
            monthMaxDay.updateValue(29, forKey: 2)
        }
        return monthMaxDay[month]!
    }
    
    private func conditionFourWeeks(_ year: Int, _ month: Int) -> Bool {
        let firstDayOfWeek = dayOfWeek(year, month, 1)
        return !isLeapYear(year) && month == 2 && (firstDayOfWeek == 0)
    }
    
    private func conditionSixWeeks(_ year: Int, _ month: Int) -> Bool {
        let firstDayOfWeek = dayOfWeek(year, month, 1)
        let days = numberOfDays(year, month)
        return (firstDayOfWeek == 6 && days == 30) || (firstDayOfWeek >= 5 && days == 31)
    }
    
    private func alignmentOfDays(_ firstDayOfWeek: Int, _ numberOfCells: Int, _ days: Int, _ PreviousMonthDays: Int) -> [[String:String]] {
        var daysArray = [[String:String]]()
        var dayCount = 0
        for i in 0 ... numberOfCells {
            let diff = i - firstDayOfWeek
            if diff < 0 {
                daysArray.append(["pre":String(PreviousMonthDays + diff + 1)])
            } else if dayCount >= days {
                daysArray.append(["next":String(diff - days + 1)])
            } else {
                daysArray.append(["main":String(diff + 1)])
                dayCount += 1
            }
        }
        return daysArray
    }

}
