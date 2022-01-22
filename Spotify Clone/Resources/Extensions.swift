//
//  Extensions.swift
//  Spotify Clone
//
//  Created by Le Hoang Anh on 22/01/2022.
//

import Foundation

extension String {
 
    static func formattedDate(string: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        guard let date = dateFormatter.date(from: string) else {
            return string
        }
        
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
}
