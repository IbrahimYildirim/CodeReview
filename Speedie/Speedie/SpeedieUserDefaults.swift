//
//  SpeedieUserDefaults.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 26/06/16.
//
//

import Foundation

class SpeedieUserDefaults {
    
    static let savedActivityKey = "prefs_saved_activites"
    static let askForUserLocationKey = "prefs_ask_for_location"
    static let alarmSettingsKey = "prefs_alarm_settings"
    static let firedAlarmForIncidentKey = "prefs_alarm_busted"
    
    class func updateConfirmedIncidents(_ incidentID : String) {
        let defaults = UserDefaults.standard
        var currentIncidents : [String] = getConfirmedIncidents()
        currentIncidents.append(incidentID)
        defaults.set(currentIncidents, forKey: savedActivityKey)
        defaults.synchronize()
    }
    
    class func getConfirmedIncidents() -> [String] {
        let defaults = UserDefaults.standard
        if let confirmedIncidents = defaults.object(forKey: savedActivityKey) as? [String] {
            return confirmedIncidents
        } else {
            return [String]()
        }
    }
    
    class func userDidClickToBeAskedForLocation() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: askForUserLocationKey)
    }
    
    class func setUserDidClickToBeAskedForLocation() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: askForUserLocationKey)
        defaults.synchronize()
    }
    
    class func getAlarmSettings() -> AlarmSetting {
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: alarmSettingsKey) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as! AlarmSetting
        } else {
            return AlarmSetting()
        }
    }
    
    class func saveAlarmSettings(_ settings: AlarmSetting) {
        let defaults = UserDefaults.standard
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: settings)
        defaults.set(encodedData, forKey: alarmSettingsKey)
        defaults.synchronize()
    }
    
    class func getFiredIncidents() -> [String] {
        let defaults = UserDefaults.standard
        if let firedAlarms = defaults.object(forKey: firedAlarmForIncidentKey) as? [String] {
            return firedAlarms
        } else {
            return [String]()
        }
    }
    
    class func updateFiredIncidents(_ incidentID : String) {
        let defaults = UserDefaults.standard
        var currentIncidents : [String] = getFiredIncidents()
        currentIncidents.append(incidentID)
        defaults.set(currentIncidents, forKey: firedAlarmForIncidentKey)
        defaults.synchronize()
    }
}
