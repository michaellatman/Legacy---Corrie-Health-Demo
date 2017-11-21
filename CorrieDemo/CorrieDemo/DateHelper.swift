//
//  DateHelper.swift
//  CorrieDemo
//
//  Created by Michael Latman on 10/17/16.
//  Copyright © 2016 Michael Latman. All rights reserved.
//

import Foundation

public class DateHelper {
    static func componentsToDate(_ date: NSDateComponents) -> Date{
        guard let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) else {
            fatalError("This should never fail.")
        }
        
        date.calendar = calendar as Calendar
        
        return date.date!
    }
    
    static func dateToComponents(_ date: Date) -> DateComponents{
        guard let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) else {
            fatalError("This should never fail.")
        }
        
        return calendar.components([.day, .month, .year], from: date)
    }
    
    
}
