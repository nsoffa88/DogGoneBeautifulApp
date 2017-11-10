//
//  ClientViewController.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 10/31/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class ClientViewController: UIViewController {
  @IBOutlet weak var clientTable: UITableView!
  
  var client: CKRecord?
  var filteredClients = [CKRecord]()
  let searchController = UISearchController(searchResultsController: nil)
  
  let database = CKContainer.default().privateCloudDatabase
  var clientRecords = [CKRecord]()
  var dogRecords = [CKRecord]()
  var allDataLoaded = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    queryDatabase()
    
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search Clients"
    navigationItem.searchController = searchController
    definesPresentationContext = true
  }
  
  @IBAction func doneViewingClientInfo(_ segue: UIStoryboardSegue) {
    clientRecords = sortRecords(records: clientRecords)
    DispatchQueue.main.async {
      self.clientTable.reloadData()
    }
  }
  @IBAction func doneSavingClient(_ segue: UIStoryboardSegue) {
    clientRecords = sortRecords(records: clientRecords)
    DispatchQueue.main.async {
      self.clientTable.reloadData()
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "addClientSegue" {
      let destinationNavController = segue.destination as! UINavigationController
      if let addClientVC = destinationNavController.topViewController as? AddClientViewController {
        addClientVC.newClient = true
        addClientVC.clientRecords = clientRecords
      }
    }
    if segue.identifier == "viewClientInfoSegue" {
      let destinationNavController = segue.destination as! UINavigationController
      if let viewClientVC = destinationNavController.topViewController as? ClientInfoViewController {
        viewClientVC.client = client
        let clientsDogs = getDogs(clientRecord: client!)
        viewClientVC.clientsDogs = clientsDogs
        viewClientVC.dogRecords = dogRecords
      }
    }
  }
  
  func queryDatabase() {
    let clientQuery = CKQuery(recordType: "Client", predicate: NSPredicate(value: true))
    clientQuery.sortDescriptors = [NSSortDescriptor(key: "Name", ascending: true)]
    database.perform(clientQuery, inZoneWith: nil) { (records, error) in
      if error == nil {
        print("Client Records Retrieved")
        self.clientRecords = records!
      } else {
        print(error)
      }
      if self.allDataLoaded == true {
        DispatchQueue.main.async {
          self.clientTable.reloadData()
          print("Reloaded Table in ClientQuery")
        }
      } else {
        self.allDataLoaded = true
      }
    }
    
    let dogQuery = CKQuery(recordType: "Dog", predicate: NSPredicate(value: true))
    database.perform(dogQuery, inZoneWith: nil) { (records, error) in
      if error == nil {
        print("Dog Records Retrieved")
        self.dogRecords = records!
      } else {
        print(error)
      }
      if self.allDataLoaded == true {
        DispatchQueue.main.async {
          self.clientTable.reloadData()
          print("Reloaded Table in dogQuery")
        }
      } else {
        self.allDataLoaded = true
      }
    }
  }
  
  func searchBarIsEmpty() -> Bool {
    return searchController.searchBar.text?.isEmpty ?? true
  }

  func filterContentForSearchText(_ searchText: String, scope: String = "All") {
//    filteredClients = clients!.filter({( client: Client) -> Bool in
//      return (client.clientName?.lowercased().contains(searchText.lowercased()))!
//    })
    filteredClients = clientRecords.filter({( client: CKRecord) -> Bool in
      let clientNameString = client.value(forKey: "Name") as! String
      return (clientNameString.lowercased().contains(searchText.lowercased()))
    })

    clientTable.reloadData()
  }

  func isFiltering() -> Bool {
    return searchController.isActive && !searchBarIsEmpty()
  }
  
  func sortRecords(records: [CKRecord]) -> [CKRecord] {
    let sortedRecords = records.sorted(by: { $1.value(forKey: "Name") as! String > $0.value(forKey: "Name") as! String})
    return sortedRecords
  }
  
  func getDogs(clientRecord: CKRecord) -> [CKRecord] {
    var clientsDogs = [CKRecord]()
    for dogRecord in dogRecords {
      let dogOwnerReference = dogRecord.value(forKey: "OwnerReference") as! CKReference
      let dogOwnerID = dogOwnerReference.recordID.recordName
      if dogOwnerID == clientRecord.recordID.recordName {
        clientsDogs.append(dogRecord)
      }
    }
    return clientsDogs
  }
}

extension ClientViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isFiltering() {
      return filteredClients.count
    }
    return clientRecords.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = clientTable.dequeueReusableCell(withIdentifier: "clientNameCell", for: indexPath)
    
    var clientRecord: CKRecord
    if isFiltering() {
      clientRecord = filteredClients[indexPath.row]
    } else {
      clientRecord = clientRecords[indexPath.row]
    }
    
    let clientName = clientRecord.value(forKey: "Name") as! String
    var clientsDogs = [CKRecord]()
    var dogsString: String = ""
    
    cell.textLabel?.text = clientName
    
    clientsDogs = getDogs(clientRecord: clientRecord)
    
    for (index, dogRecord) in clientsDogs.enumerated() {
      if clientsDogs.count - 1 > index {
        dogsString.append(dogRecord.value(forKey: "Name") as! String + ", ")
      } else {
        dogsString.append(dogRecord.value(forKey: "Name") as! String)
      }
    }

    cell.detailTextLabel?.text = dogsString
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if isFiltering() {
      client = filteredClients[indexPath.row]
    } else {
      client = clientRecords[indexPath.row]
    }
    self.performSegue(withIdentifier: "viewClientInfoSegue", sender: self)
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    var clientIDToRemove: CKRecordID
    var dogsToRemove: [CKRecord]
    var filtered: Bool
    if isFiltering() {
      clientIDToRemove = filteredClients[indexPath.row].recordID
      dogsToRemove = getDogs(clientRecord: filteredClients[indexPath.row])
      filtered = true
    } else {
      clientIDToRemove = clientRecords[indexPath.row].recordID
      dogsToRemove = getDogs(clientRecord: clientRecords[indexPath.row])
      filtered = false
    }
    database.delete(withRecordID: clientIDToRemove) { (records, _) in
      guard records != nil else { return }
      if filtered {
        for (index, client) in self.clientRecords.enumerated() {
          if client.recordID == clientIDToRemove {
            self.filteredClients.remove(at: indexPath.row)
            self.clientRecords.remove(at: index)
          }
        }
      } else {
        self.clientRecords.remove(at: indexPath.row)
      }
      print(self.clientRecords)
      for dogToRemove in dogsToRemove {
        for (index, dog) in self.dogRecords.enumerated() {
          if dogToRemove.recordID == dog.recordID {
            self.dogRecords.remove(at: index)
          }
        }
      }
      DispatchQueue.main.async {
        self.clientTable.reloadData()
      }
    }
  }
}

extension ClientViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }
}














