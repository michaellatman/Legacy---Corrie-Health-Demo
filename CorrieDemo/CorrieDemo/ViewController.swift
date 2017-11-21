//
//  ViewController.swift
//  CorrieDemo
//
//  Created by Michael Latman on 10/16/16.
//  Copyright © 2016 Michael Latman. All rights reserved.
//

import UIKit
import CareKit
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CarePlanStoreManagerDelegate {
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    fileprivate var currentActivities: [OCKCarePlanActivity] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        storeManager.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCurrentActivities()
    }
    
    func updateCurrentActivities() {
        storeManager.getUnendedActivities(atDate: Date(), inGroup: ActivityType.takeMedication.rawValue, completion: {[weak self] (activities) -> Void in
            self?.currentActivities = activities
            DispatchQueue.main.async {
                self?.tableView.reloadSections(IndexSet.init(integer: 0), with: .automatic)
            }
        })
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let formController = MedicationFormViewController()
        self.present(UINavigationController.init(rootViewController: formController), animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openCareCardButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getActivity(indexPath: IndexPath) -> OCKCarePlanActivity {
        return currentActivities[indexPath.row]
    }
    
    
    // MARK: CarePlan Delegate 
    
    func carePlanStoreManagerDidUpdate(_ manager: CarePlanStoreManager) {
        self.updateCurrentActivities()
    }
    
    // MARK: TableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentActivities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicationCell")!
        let activity = getActivity(indexPath: indexPath)
        cell.textLabel?.text = activity.title
        cell.detailTextLabel?.text = activity.text
        return cell
    }
    
    // MARK: TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let formController = MedicationFormViewController()
        
        formController.editingActivity = currentActivities[indexPath.row]
        self.present(UINavigationController.init(rootViewController: formController), animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            let activity = currentActivities[indexPath.row]
            storeManager.endActivityNow(activity: activity)
        }
    }
    
    
    

}

