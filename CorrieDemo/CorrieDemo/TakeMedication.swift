import CareKit

/**
 Class that conforms to the `Activity` protocol to define an activity to take
 medication.
 */
class TakeMedication: NSObject, Activity {
    
    enum MedicationUnits: String {
        case mg
    }
    
    // MARK: Activity
    
    let activityType: ActivityType = .takeMedication

    var identifier = UUID.init()
    var medicationName: String
    var medicationDosage: String
    var medicationInstructions: String
    var medicationUnits: MedicationUnits
    
    var startDate: DateComponents
    init(medicationName: String, medicationDosage: String, medicationUnits: MedicationUnits, startDate: DateComponents?, medicationInstructions: String? = "") {
        self.medicationName = medicationName
        self.medicationDosage = medicationDosage
        self.medicationUnits = medicationUnits
        
        self.medicationInstructions = medicationInstructions!
        
        guard let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) else {
            fatalError("This should never fail.")
        }
        
        let today = calendar.components([.day, .month, .year], from: Date())
        
        self.startDate = (startDate != nil) ? startDate! : today
    }
    
    convenience init(fromDictionary: [AnyHashable: Any?]) {
        self.init(medicationName: (fromDictionary["medicationName"] as! String?)!, medicationDosage: (fromDictionary["medicationDosage"] as! String?)!, medicationUnits: MedicationUnits.init(rawValue: fromDictionary["medicationUnits"] as! String)! , startDate: (fromDictionary["startDate"] as! DateComponents), medicationInstructions:  fromDictionary["medicationInstructions"] as! String?)
        self.identifier = fromDictionary["identifier"] as! UUID!
    }
    
    func toDictionary() -> [AnyHashable: Any?] {
        var dictionary: [AnyHashable: Any?] = [:]
        dictionary["identifier"] = identifier
        dictionary["medicationName"] = medicationName
        dictionary["medicationDosage"] = medicationDosage
        dictionary["medicationInstructions"] = medicationInstructions
        dictionary["medicationUnits"] = medicationUnits.rawValue
        dictionary["startDate"] = startDate
        
        return dictionary
    }
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let schedule = OCKCareSchedule.weeklySchedule(withStartDate: self.startDate, occurrencesOnEachDay: [2, 2, 2, 2, 2, 2, 2])
        
        // Get the localized strings to use for the activity.
        let title = self.medicationName
        let summary = "\(self.medicationDosage)\(self.medicationUnits.rawValue)"
        let instructions = self.medicationInstructions
        
        let activity = OCKCarePlanActivity.intervention(
            withIdentifier: identifier.uuidString,
            groupIdentifier: activityType.rawValue,
            title: title,
            text: summary,
            tintColor: Colors.green.color,
            instructions: instructions,
            imageURL: nil,
            schedule: schedule,
            userInfo: self.toDictionary()
        )
        
        return activity
    }
}
