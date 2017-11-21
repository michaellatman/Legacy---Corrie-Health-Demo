//
//  CORNavigationWrapperViewController.swift
//  CorrieDemo
//
//  Created by Michael Latman on 10/16/16.
//  Copyright © 2016 Michael Latman. All rights reserved.
//

import UIKit
import CareKit

class CORNavigationWrapperViewController: UINavigationController {
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewController = OCKCareCardViewController(carePlanStore: storeManager.store)

        self.setViewControllers([viewController], animated: false)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.topViewController?.navigationItem.title = "CareCard"
        self.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "mymeds"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(CORNavigationWrapperViewController.openMyMeds))
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openMyMeds() {
        self.performSegue(withIdentifier: "goToMyMeds", sender: self)
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
