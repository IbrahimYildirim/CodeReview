//
//  Activity.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 6/26/16.
//
//

import Foundation
import ObjectMapper

enum ActivityType : String {
    case Deny
    case Confirm
}

class ActivityResponse : Mappable {

    var type : ActivityType?
    var createdAt : Date = 3.days.ago()!
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        type <- map["type"]
        createdAt <- (map["timeStamp"], DateTransform())
    }
    
    func getAttributedText() -> NSAttributedString {
        let string = NSMutableString()
        string.append(type! == .Confirm ? "Bekræftet: " : "Afkræftet: ")
        string.append("\(createdAt.hour.timeValue).\(createdAt.minute.timeValue)")
        string.append("\n")
        return NSAttributedString(attributedString: (string as String).attributedTextWithColor(type! == .Confirm ? Colors.acceptColor() : Colors.dismissColor()))
    }
}
