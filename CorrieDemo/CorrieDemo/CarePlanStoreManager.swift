/*
 Copyright (c) 2016, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import CareKit

class CarePlanStoreManager: NSObject {
    // MARK: Static Properties
    
    static var sharedCarePlanStoreManager = CarePlanStoreManager()
    
    // MARK: Properties
    
    weak var delegate: CarePlanStoreManagerDelegate?
    
    let store: OCKCarePlanStore
    
    //var insights: [OCKInsightItem] {
    //    return insightsBuilder.insights
    //}
    
    // fileprivate let insightsBuilder: InsightsBuilder
    
    
    func getUnendedActivities(atDate: Date, inGroup: String, completion: @escaping ([OCKCarePlanActivity]) -> Swift.Void) {
        store.activities(withGroupIdentifier: ActivityType.takeMedication.rawValue, completion: { (completed, activities, error) -> Void  in
            
            print(activities.count)
            guard (completed == true) else{
                return
            }
            
            guard let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) as? Calendar else {
                fatalError("This should never fail.")
            }
            
            let unfinishedActivities = activities.filter({ (activity) -> Bool in
                
                
                var components: DateComponents? = nil
                if(activity.schedule.endDate != nil){
                    components = activity.schedule.endDate
                    components!.calendar = calendar as Calendar
                    let expireDate = components!.date!
                    switch atDate.compare(expireDate) {
                    case .orderedAscending, .orderedSame:
                        return true
                    default:
                        return false
                    }
                }
                
                return true
            })
            
            completion(unfinishedActivities)
        })

    }
    
    func endActivityNow(activity: OCKCarePlanActivity){
        let activityStartDateComponents = activity.schedule.startDate
        
        let activityStartDate = DateHelper.componentsToDate(activityStartDateComponents as NSDateComponents)
        
        let yesterdayDate = NSDate().addingTimeInterval(-86400.0) as Date
        let yesterdayComponents = DateHelper.dateToComponents(yesterdayDate)
        
        if(activityStartDate.compare(yesterdayDate) == .orderedDescending){
            store.remove(activity, completion: {(completed, error) -> Void in
            })
        }
        else{
            store.setEndDate(yesterdayComponents, for: activity, completion:  {(completed, activity, error) -> Void in
            })
        }
    }
    
    
    // MARK: Initialization
    
    fileprivate override init() {
        // Determine the file URL for the store.
        let searchPaths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let applicationSupportPath = searchPaths[0]
        let persistenceDirectoryURL = URL(fileURLWithPath: applicationSupportPath)
        
        if !FileManager.default.fileExists(atPath: persistenceDirectoryURL.absoluteString, isDirectory: nil) {
            try! FileManager.default.createDirectory(at: persistenceDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Create the store.
        store = OCKCarePlanStore(persistenceDirectoryURL: persistenceDirectoryURL)
        
        /*
         Create an `InsightsBuilder` to build insights based on the data in
         the store.
         */
        //insightsBuilder = InsightsBuilder(carePlanStore: store)
        
        super.init()
        
        // Register this object as the store's delegate to be notified of changes.
        store.delegate = self
        
        // Start to build the initial array of insights.
    }
    
}



extension CarePlanStoreManager: OCKCarePlanStoreDelegate {
    func carePlanStoreActivityListDidChange(_ store: OCKCarePlanStore) {
        print("Store updated!")
        self.delegate?.carePlanStoreManagerDidUpdate(self)
    }
    
    func carePlanStore(_ store: OCKCarePlanStore, didReceiveUpdateOf event: OCKCarePlanEvent) {
    }
}



protocol CarePlanStoreManagerDelegate: class {
    
    func carePlanStoreManagerDidUpdate(_ manager: CarePlanStoreManager)
    
    
}
