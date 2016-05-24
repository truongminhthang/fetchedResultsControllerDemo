//
//  DepartmentsTVC.swift
//  fetchedResultsController
//
//  Created by Admin on 5/22/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit
import CoreData


class DepartmentsTVC: UITableViewController{

    var dataController : DataController!
    var fetchedResultsController: NSFetchedResultsController!
    weak var previousViewController: UIViewController!
    
    
    private let departmentEntityName = "Department"
    private let departmentCacheName = "departmentCache"
    private let cellIdenfifier      = "cell"
    private let unwindSegueToAddPersonVC = "backToAddNewPerson"
    
    @IBOutlet var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataController = AppDelegate.shareInstance.dataController
        assert(dataController != nil, "dataController chưa tồn tại")
        navigationItem.rightBarButtonItem = addButton
        initializeFetchedResultsController()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        initializeFetchedResultsController()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func initializeFetchedResultsController() {
        let request = NSFetchRequest(entityName: departmentEntityName)
        let departmentSort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [departmentSort]
        
        let moc = self.dataController.context
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: departmentCacheName)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let department = fetchedResultsController.objectAtIndexPath(indexPath) as! DeparmentMO
        // Populate cell from the NSManagedObject instance
        cell.textLabel?.text = department.name
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdenfifier, forIndexPath: indexPath)
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = fetchedResultsController.sections![section]
        return sections.numberOfObjects
    }

    @IBAction func onClickAddButton(sender: AnyObject) {
        showAlertController()
    }
    
    private func showAlertController() {
        let title = "Add"
        let message = "Add department name, please!"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        alert.addTextFieldWithConfigurationHandler { (tf: UITextField) in
            
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action) -> Void in
            let text = alert.textFields![0].text
            if text != "" {
                let department = NSEntityDescription.insertNewObjectForEntityForName(self.departmentEntityName, inManagedObjectContext: self.dataController.context) as! DeparmentMO
                department.name = text
                self.dataController.saveContext()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

//MARK: UITableViewDelegate

extension DepartmentsTVC {
    override func canPerformUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let previousVC = previousViewController else {
            return
        }
        let department = fetchedResultsController.objectAtIndexPath(indexPath) as! DeparmentMO

        if let addNewPersonVC = previousVC as? AddNewPersonVC {
            addNewPersonVC.department = department
            navigationController?.popViewControllerAnimated(true)
        }
        
        if let personsVC = previousVC as? PersonsVC {
            let fetchRequest = personsVC.fetchRequest
            let predicate = NSPredicate(format: "department.name == %@", department.name!)
            let sort = NSSortDescriptor(key: "firstName", ascending: true)
            fetchRequest.sortDescriptors = [sort]
            fetchRequest.predicate = predicate
            personsVC.sectionNameKeyPath = nil
            NSFetchedResultsController.deleteCacheWithName(personsVC.cacheName)
            navigationController?.popViewControllerAnimated(true)
            
        }
    }
    
}


extension DepartmentsTVC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller:
        NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                                    atIndexPath indexPath: NSIndexPath?,
                                                forChangeType type: NSFetchedResultsChangeType,
                                                              newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!],
                                             withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!],
                                             withRowAnimation: .Automatic)
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!)
            configureCell(cell!, indexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!],
                                             withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!],
                                             withRowAnimation: .Automatic)
        }
    }
    
    func controllerDidChangeContent(controller:
        NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                                     atIndex sectionIndex: Int,
                                             forChangeType type: NSFetchedResultsChangeType) {
        
        let indexSet = NSIndexSet(index: sectionIndex)
        
        switch type {
        case .Insert:
            tableView.insertSections(indexSet,
                                     withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(indexSet,
                                     withRowAnimation: .Automatic)
        default :
            break
        }
    }
    
}
