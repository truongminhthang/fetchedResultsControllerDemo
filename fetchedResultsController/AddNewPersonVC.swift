//
//  AddNewPersonViewController.swift
//  fetchedResultsController
//
//  Created by Admin on 5/21/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit
import CoreData

private let personEntityName = "Person"


class AddNewPersonVC: UITableViewController {
    
    @IBOutlet weak var firstnameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet weak var departmentNameLabel: UILabel!
    var dataController: DataController!
    var department: DeparmentMO! {
        didSet {
            departmentNameLabel.text = department.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        navigationItem.rightBarButtonItem = saveButton
         dataController = AppDelegate.shareInstance.dataController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onClickSaveButton(sender: AnyObject) {
        let person = NSEntityDescription.insertNewObjectForEntityForName(personEntityName, inManagedObjectContext: dataController.context) as! PersonMO
        person.lastName = lastNameTF.text ?? ""
        person.firstName = firstnameTF.text ?? ""
        person.department = department
        dataController.saveContext()
        
        performSegueWithIdentifier("unwind", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is DepartmentsTVC {
            let vc = segue.destinationViewController as! DepartmentsTVC
            vc.previousViewController = self
        }
    }
    
    
}
