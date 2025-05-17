//  Date extension for fututre

import Foundation

extension Date {
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: self)
    }
}
//   How to extract formated date
//   let currentDate = Date()
//   let formatted = currentDate.formattedDate()
//   print(formatted)
