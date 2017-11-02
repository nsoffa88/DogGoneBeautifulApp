//
//  ClientViewController.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 10/31/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//

import UIKit
import CoreData

class ClientViewController: UIViewController {
  @IBOutlet weak var clientTable: UITableView!
  
  var clients: [Client]?
  var client: Client?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if clients == nil {
      loadNSData()
    }
  }
  
  @IBAction func doneViewingClientInfo(_ segue: UIStoryboardSegue) {
    loadNSData()
    clientTable.reloadData()
  }
  @IBAction func doneSavingClient(_ segue: UIStoryboardSegue) {
    loadNSData()
    clientTable.reloadData()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "addClientSegue" {
      let destinationNavController = segue.destination as! UINavigationController
      if let addClientVC = destinationNavController.topViewController as? AddClientViewController {
        addClientVC.newClient = true
      }
    }
    if segue.identifier == "viewClientInfoSegue" {
      let destinationNavController = segue.destination as! UINavigationController
      if let viewClientVC = destinationNavController.topViewController as? ClientInfoViewController {
        viewClientVC.client = client
      }
    }
  }
  
  // Only do this once on viewDidLoad, output to array, and access that array for ClientTable
  func loadNSData() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Client")
    let alphabeticalSortDescriptor = NSSortDescriptor(key: "clientName", ascending: true)
    let sortDescriptors = [alphabeticalSortDescriptor]
    fetchRequest.sortDescriptors = sortDescriptors
    
    do {
      clients = try managedContext.fetch(fetchRequest) as! [Client]
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }
}

extension ClientViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return clients!.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let client = clients![indexPath.row]
    let cell = clientTable.dequeueReusableCell(withIdentifier: "clientNameCell", for: indexPath)
    cell.textLabel?.text = client.value(forKeyPath: "clientName") as? String
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    client = clients![indexPath.row] as Client
    self.performSegue(withIdentifier: "viewClientInfoSegue", sender: self)
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    guard let clientToRemove = clients![indexPath.row] as? Client, editingStyle == .delete else {
      return
    }
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    let managedContext = appDelegate.persistentContainer.viewContext

    managedContext.delete(clientToRemove)
    do {
      try managedContext.save()
      clientTable.reloadData()
    } catch let error as NSError {
      print("Deleting error: \(error), \(error.userInfo)")
    }
  }
}














