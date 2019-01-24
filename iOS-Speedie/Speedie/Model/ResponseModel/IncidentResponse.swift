//
//  IncidentResponse.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 6/19/16.
//
//

import Foundation
import ObjectMapper
import SwiftDate

enum IncidentType : String {
    case SpeedControl = "SpeedControl"
    case Cue = "Traffic"
    case Accident = "Accident"
    case Other = "Other"
}

class IncidentResponse : Mappable, Equatable {
    
    var id : String = ""
    var type : IncidentType = .SpeedControl
    var address : String = ""
    var latitude : Double = 0.0
    var longiuted : Double = 0.0
    var description : String = ""
    var confirms : Int = 0
    var denies : Int = 0
    
    var createdAt : Date = 3.days.ago()!
    var activities : [ActivityResponse]?
    
    required init?(map: Map) {
        
    }
    
    init(){
        
    }
    
    func mapping(map: Map) {
        createdAt <- (map["timeStamp"], DateTransform())
        id <- map["_id"]
        type <- map["type"]
        address <- map["address"]
        latitude <- map["latitude"]
        longiuted <- map["longitude"]
        denies <- map["denies"]
        confirms <- map["confirms"]
        description <- map["description"]
        activities <- map["activities"]
    }
    
    func titleForType() -> String {
        switch type {
        case .SpeedControl: return "Fart Kontrol"
        case .Cue: return "Kø"
        case .Accident: return "Trafik Uheld"
        case .Other: return "Andet"
        }
    }
    
    func imageNameForType() -> String {
        switch type {
        case .SpeedControl: return "SpeedControlRound"
        case .Cue: return "CueRound"
        case .Accident: return "AccidentRound"
        case .Other: return "OtherRound"
        }
    }
    
    func createdDate(includeCreated include : Bool) -> String {
        let mutableString = NSMutableString()
        
        if include {
            mutableString.append("Oprettet ")
        }
        
        if createdAt.isToday {
            mutableString.append("I dag")
        } else if createdAt.isYesterday {
            mutableString.append("I går")
        } else {
            mutableString.append("\(createdAt.day.timeValue).\(createdAt.month.timeValue)")
        }
        
        mutableString.append(" kl. \(createdAt.hour.timeValue).\(createdAt.minute.timeValue)")
        
        return mutableString as String
    }
}

func ==(lhs: IncidentResponse, rhs: IncidentResponse) -> Bool {
    return lhs.id == rhs.id
}
