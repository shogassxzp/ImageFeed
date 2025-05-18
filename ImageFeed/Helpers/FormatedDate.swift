//  Date extension from previous project with mod. Using in configCell

import Foundation

extension Date {
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: self)
    }
}
//   How to use formated date
//   let currentDate = Date()
//   let formatted = currentDate.formattedDate()
//   print(formatted)
