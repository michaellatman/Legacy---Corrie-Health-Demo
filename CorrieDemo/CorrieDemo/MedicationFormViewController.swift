//
//  MedicationFormViewController.swift
//  CorrieDemo
//
//  Created by Michael Latman on 10/17/16.
//  Copyright © 2016 Michael Latman. All rights reserved.
//

import Eureka
import CareKit
class MedicationFormViewController: FormViewController {
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
    var editingActivity: OCKCarePlanActivity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Add Medication"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Cancel", style: .plain, target: self, action: #selector(MedicationFormViewController.closeButtonPressed))
        

        let section = Section("Medication Info")
            <<< TextRow("medName"){ row in
                row.title = "Medication Name"
                row.placeholder = "Enter text here"
                if editingActivity != nil {
                    row.disabled = true
                }
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesAlways
            }
            .cellUpdate({ (cell, row) in
                if(!row.isValid){
                    cell.titleLabel?.textColor = .red
                }
            })
        
            <<< IntRow("dosage"){ row in
                row.title = "Dosage (mg)"
                row.placeholder = "100"
                row.add(rule: RuleRequired())
                row.add(rule: RuleGreaterThan(min: 0))
                row.validationOptions = .validatesAlways
            }
            .cellUpdate({ (cell, row) in
                if(!row.isValid){
                    cell.titleLabel?.textColor = .red
                }
            })
        
            <<< TextRow("instructions"){ row in
                row.title = "Instructions"
                row.placeholder = "Take with water"
            }
            
            /*
            <<< MultipleSelectorRow<String>("days") { row in
                row.title = "Days Taken"
                row.options = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                
                row.add(rule: RuleRequired())
            }*/
        
            <<< ButtonRow(){ row in
                row.title = "Save"
                row.disabled = Condition.function(["medName","dosage", "days"], { (form) -> Bool in
                    if(form.rowBy(tag: "medName")!.validate().isEmpty && form.rowBy(tag: "dosage")!.validate().isEmpty){
                        return false
                    }
                    return true
                })
                row.onCellSelection({ [unowned self] (cell, row) in
                    if(!row.isDisabled){
                        print("Saving!")
                        
                        if(self.editingActivity != nil){
                            self.storeManager.endActivityNow(activity: self.editingActivity!)
                        }
                        
                        
                        let name = (self.form.rowBy(tag: "medName") as! TextRow).value! as String
                        let dosage = (self.form.rowBy(tag: "dosage") as! IntRow).value! as Int
                        let medInstructions = (self.form.rowBy(tag: "instructions") as! TextRow).value

                        
                        let medTask = TakeMedication.init(medicationName: name, medicationDosage: "\(dosage)", medicationUnits: .mg, startDate: nil)
                        
                        if(medInstructions != nil) {
                            medTask.medicationInstructions = medInstructions!
                        }
                    
                        self.storeManager.store.add(medTask.carePlanActivity(), completion: { (completed, error) in
                            // We should handle errors here
                            self.dismiss(animated: true, completion: nil)
                        })
                    }
                })
            }
        
        form +++ section
        
        if editingActivity != nil {
            let selectedActivity = TakeMedication.init(fromDictionary: editingActivity!.userInfo!)
            (form.rowBy(tag: "medName") as! TextRow).value = selectedActivity.medicationName
            (form.rowBy(tag: "dosage") as! IntRow).value = Int.init(string: selectedActivity.medicationDosage)
            (form.rowBy(tag: "instructions") as! TextRow).value = selectedActivity.medicationInstructions
        }
    
        

        // Do any additional setup after loading the view.
    }
    
    func closeButtonPressed(sender: Any){
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
