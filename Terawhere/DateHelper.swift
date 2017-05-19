//
//  DateHelper.swift
//  Terawhere
//
//  Created by Muhd Mirza on 19/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import Foundation

class DateHelper {

	let date = Date()
	let dateFormatter = DateFormatter()

	init() {
	}
	
	func utcDate() -> Date? {
		self.dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
		self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
	
		let tmpDateString = self.dateFormatter.string(from: Date())
		let utcDate = self.dateFormatter.date(from: tmpDateString)
		
		return utcDate
	}
	
	func utcDateFrom(dateString: String?) -> Date? {
		self.dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
		self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
	
		let utcDate = self.dateFormatter.date(from: dateString!)
		
		return utcDate
	}
	
	func utcDateStringFrom(date: Date?) -> String {
		self.dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
		self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let dateString = dateFormatter.string(from: date!)
		
		return dateString
	}
	
	func localTimeFrom(dateString: String?) -> String {
		self.dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
		self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let date = dateFormatter.date(from: dateString!)
		
		dateFormatter.timeZone = TimeZone.autoupdatingCurrent
		dateFormatter.dateFormat = "hh:mm a"
		let localMeetupTime = dateFormatter.string(from: date!)
		
		return localMeetupTime
	}
	
	func localTimeFrom(dateString: String?, withCustomFormat format: String) -> String {
		self.dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
		self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let date = dateFormatter.date(from: dateString!)
		
		dateFormatter.timeZone = TimeZone.autoupdatingCurrent
		dateFormatter.dateFormat = format
		let localMeetupTime = dateFormatter.string(from: date!)
		
		return localMeetupTime
	}
	
	func localTimeFrom(convertedDate: Date?) -> String {
		self.dateFormatter.dateFormat = "hh:mm a"
		let dateString = dateFormatter.string(from: convertedDate!)
		
		return dateString
	}
}
