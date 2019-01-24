//
//  AlarmSettings.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 19/03/17.
//
//

import Foundation

let kAlarmActive = "alarmActive"
let kAlarmRadius = "alarmRadius"
let kSpeedControlAlarm = "speedControlAlarm"
let kCueAlarm = "cueAlarm"
let kAccidentAlarm = "accidentAlarm"
let kOtherAlarm = "otherAlarm"

class AlarmSetting : NSObject, NSCoding {
    
    //Alarm variables : Default values
    var alarmIsActive       : Bool  = true
    var alarmRadius         : Int   = 1000
    var speedControlAlarm   : Bool  = true
    var cueAlarm            : Bool  = false
    var accidentAlarm       : Bool  = false
    var otherAlarm          : Bool  = false
    
    override init() {
        //Initialize with default values
    }
    
    required init?(coder decoder: NSCoder) {
        
        self.alarmIsActive = decoder.decodeBool(forKey: kAlarmActive)
        self.alarmRadius = decoder.decodeInteger(forKey: kAlarmRadius)
    
        self.speedControlAlarm = decoder.decodeBool(forKey: kSpeedControlAlarm)
        self.cueAlarm = decoder.decodeBool(forKey: kCueAlarm)
        self.accidentAlarm = decoder.decodeBool(forKey: kAccidentAlarm)
        self.otherAlarm = decoder.decodeBool(forKey: kOtherAlarm)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(alarmIsActive, forKey: kAlarmActive)
        coder.encode(alarmRadius, forKey: kAlarmRadius)
        coder.encode(speedControlAlarm, forKey: kSpeedControlAlarm)
        coder.encode(cueAlarm, forKey: kCueAlarm)
        coder.encode(accidentAlarm, forKey: kAccidentAlarm)
        coder.encode(otherAlarm, forKey: kOtherAlarm)
    }
    
    func getActiveIncidentTypes() -> [IncidentType] {
        
        var incidentTypes = [IncidentType]()
        
        if accidentAlarm {
            incidentTypes.append(IncidentType.Accident)
        }
        
        if cueAlarm {
            incidentTypes.append(IncidentType.Cue)
        }
        
        if speedControlAlarm {
            incidentTypes.append(IncidentType.SpeedControl)
        }
        
        if otherAlarm {
            incidentTypes.append(IncidentType.Other)
        }
        
        return incidentTypes
    }
}
