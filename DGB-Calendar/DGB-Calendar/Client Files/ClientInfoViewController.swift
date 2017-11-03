//
//  ClientInfoViewController.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 10/31/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//

import UIKit
import CoreData

class ClientInfoViewController: UIViewController {
  @IBOutlet weak var clientInfoTable: UITableView!
  
  var client: Client?
  var clientsDogs: [Dog] = []
  var dogToPass: Dog?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    clientsDogs = getDogs()
  }

  @IBAction func doneSavingClient(_ segue: UIStoryboardSegue) {
    clientsDogs = getDogs()
    clientInfoTable.reloadData()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "editClientInfoSegue" {
      let destinationNavController = segue.destination as! UINavigationController
      if let editVC = destinationNavController.topViewController as? AddClientViewController {
        editVC.newClient = false
        editVC.client = client
      }
    }
    if segue.identifier == "addDogSegue" {
      let destinationNavController = segue.destination as! UINavigationController
      if let editVC = destinationNavController.topViewController as? AddDogViewController {
        editVC.newDog = true
        editVC.client = client
      }
    }
    if segue.identifier == "viewDogInfoSegue" {
      let destinationNavController = segue.destination as! UINavigationController
      if let viewVC = destinationNavController.topViewController as? DogInfoViewController {
        viewVC.newDog = false
        viewVC.dog = dogToPass
      }
    }
  }
  
  func getDogs() -> [Dog] {
    let clientsDogs = client?.dogs.allObjects as! [Dog]
    return clientsDogs
  }
}

extension ClientInfoViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as! UITableViewHeaderFooterView
    if section == 0 {
      header.textLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 25)
    } else {
      header.textLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 20)
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return 50.0
    } else {
      return 40.0
    }
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UITableViewHeaderFooterView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: tableView.sectionHeaderHeight))
    view.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    if section == 0 {
      view.textLabel?.text = client?.clientName
    } else {
      view.textLabel?.text = "Dogs"
    }
    return view
  }

  //First Section holds clients info, any section after that holds dog info
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return Client.entity().attributesByName.count
    } else {
      return client!.dogs.count
    }

  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      if indexPath.row == 0 {
        let cell = clientInfoTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Phone:"
        cell.detailTextLabel?.text = client?.phoneNumber
        return cell
      } else if indexPath.row == 1 {
        let cell = clientInfoTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Address:"
        cell.detailTextLabel?.text = client?.address
        return cell
      } else if indexPath.row == 2 {
        let cell = clientInfoTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Email:"
        cell.detailTextLabel?.text = client?.email
        return cell
      } else if indexPath.row == 3 {
        let cell = clientInfoTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Referred By:"
        cell.detailTextLabel?.text = client?.referredBy
        return cell
      } else {
        let cell = clientInfoTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Referrals:"
        cell.detailTextLabel?.text = client?.referrals
        return cell
      }
    } else {
      let cell = clientInfoTable.dequeueReusableCell(withIdentifier: "DogCell", for: indexPath)
      cell.textLabel?.text = clientsDogs[indexPath.row].dogName
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 1 {
      dogToPass = clientsDogs[indexPath.row]
      self.performSegue(withIdentifier: "viewDogInfoSegue", sender: self)
    }
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    if indexPath.section == 1 {
      return true
    } else {
      return false
    }
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    guard let dogToRemove = clientsDogs[indexPath.row] as? Dog, editingStyle == .delete else {
      return
    }
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    let managedContext = appDelegate.persistentContainer.viewContext
    
    managedContext.delete(dogToRemove)
    do {
      try managedContext.save()
      clientInfoTable.reloadData()
    } catch let error as NSError {
      print("Deleting error: \(error), \(error.userInfo)")
    }
  }
}







