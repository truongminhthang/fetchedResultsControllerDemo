//
//  ViewController.swift
//  fetchedResultsController
//
//  Created by Admin on 5/21/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit
import CoreData


class PersonsVC: UIViewController {
    
    private let personEntityName = "Person"

    let cacheName    = "rootCache"


    var dataController          : DataController!
    var fetchedResultsController: NSFetchedResultsController!
    
    var fetchRequest            : NSFetchRequest = {
        let request = NSFetchRequest(entityName: "Person")
        let departmentSort = NSSortDescriptor(key: "department.name", ascending: true)
        let lastNameSort = NSSortDescriptor(key: "lastName", ascending: true)
        request.sortDescriptors = [departmentSort, lastNameSort]
        return request
    }()
    
    var sectionNameKeyPath: String? = {
        return "department.name"
    }()
    
    @IBOutlet weak var tbv: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataController = AppDelegate.shareInstance.dataController
        automaticallyAdjustsScrollViewInsets = false
        


        assert(dataController != nil)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        initializeFetchedResultsController(fetchRequest, sectionNameKeyPath: sectionNameKeyPath)
    }

    deinit {
        NSFetchedResultsController.deleteCacheWithName(cacheName)
    }
    
    func initializeFetchedResultsController(request: NSFetchRequest, sectionNameKeyPath: String?) {
        let moc = self.dataController.context
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            tbv.reloadData()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let employee = fetchedResultsController.objectAtIndexPath(indexPath) as! PersonMO
        // Populate cell from the NSManagedObject instance
        cell.textLabel?.text = "\(employee.lastName ?? "") \(employee.firstName ?? "")"
        cell.detailTextLabel?.text = employee.department?.name
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = fetchedResultsController.sections![section]
        return sections.numberOfObjects
    }

    func tableView( tableView : UITableView,  titleForHeaderInSection section: Int)->String {
        return fetchedResultsController.sections![section].name
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
        if segue.destinationViewController is AddNewPersonVC {
        } else if segue.destinationViewController is DepartmentsTVC {
            let vc = segue.destinationViewController as! DepartmentsTVC
            vc.previousViewController = self
        }
        
    }
}

extension PersonsVC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller:
        NSFetchedResultsController) {
        tbv.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                                    atIndexPath indexPath: NSIndexPath?,
                                                forChangeType type: NSFetchedResultsChangeType,
                                                              newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            tbv.insertRowsAtIndexPaths([newIndexPath!],
                                             withRowAnimation: .Automatic)
        case .Delete:
            tbv.deleteRowsAtIndexPaths([indexPath!],
                                             withRowAnimation: .Automatic)
        case .Update:
            let cell = tbv.cellForRowAtIndexPath(indexPath!)
            configureCell(cell!, indexPath: indexPath!)
        case .Move:
            tbv.deleteRowsAtIndexPaths([indexPath!],
                                             withRowAnimation: .Automatic)
            tbv.insertRowsAtIndexPaths([newIndexPath!],
                                             withRowAnimation: .Automatic)
        }
    }
    
    func controllerDidChangeContent(controller:
        NSFetchedResultsController) {
        tbv.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                                     atIndex sectionIndex: Int,
                                             forChangeType type: NSFetchedResultsChangeType) {
        
        let indexSet = NSIndexSet(index: sectionIndex)
        
        switch type {
        case .Insert:
            tbv.insertSections(indexSet,
                                     withRowAnimation: .Automatic)
        case .Delete:
            tbv.deleteSections(indexSet,
                                     withRowAnimation: .Automatic)
        default :
            break
        }
    }
    
}


