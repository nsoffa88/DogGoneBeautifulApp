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
  var filteredClients = [Client]()
  let searchController = UISearchController(searchResultsController: nil)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if clients == nil {
      loadNSData()
    }
    
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search Clients"
    navigationItem.searchController = searchController
    definesPresentationContext = true
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
  
  func searchBarIsEmpty() -> Bool {
    return searchController.searchBar.text?.isEmpty ?? true
  }
  
  func filterContentForSearchText(_ searchText: String, scope: String = "All") {
    filteredClients = clients!.filter({( client: Client) -> Bool in
      return (client.clientName?.lowercased().contains(searchText.lowercased()))!
    })
    
    clientTable.reloadData()
  }
  
  func isFiltering() -> Bool {
    return searchController.isActive && !searchBarIsEmpty()
  }
}

extension ClientViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isFiltering() {
      return filteredClients.count
    }
    return clients!.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = clientTable.dequeueReusableCell(withIdentifier: "clientNameCell", for: indexPath)
    let client: Client
    if isFiltering() {
      client = filteredClients[indexPath.row]
    } else {
      client = clients![indexPath.row]
    }
    cell.textLabel?.text = client.clientName
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if isFiltering() {
      client = filteredClients[indexPath.row] as Client
    } else {
      client = clients![indexPath.row] as Client
    }
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

extension ClientViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }
}














