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
//  var clientsDogs: [Dog] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    clientsDogs = getDogs()
  }

  @IBAction func doneSavingClient(_ segue: UIStoryboardSegue) {
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
  }
  
//  func getDogs() -> [Dog] {
//    let clientsDogs = client?.dogs?.allObjects as! [Dog]
//    return clientsDogs
//  }
}

extension ClientInfoViewController: UITableViewDelegate, UITableViewDataSource {
  
//  func numberOfSections(in tableView: UITableView) -> Int {
//    if clientsDogs != [] {
//      return 1 + clientsDogs.count
//    } else {
//      return 1
//    }
//  }
  
//  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//    if section == 0 {
//      return client?.clientName
//    } else {
//      return "Dog Name"
//    }
//  }
  
  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as! UITableViewHeaderFooterView
    header.textLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 25)
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50.0
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UITableViewHeaderFooterView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: tableView.sectionHeaderHeight))
    view.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    if section == 0 {
      view.textLabel?.text = client?.clientName
    } else {
      view.textLabel?.text = "Dog Name"
    }
    return view
  }

  //First Section holds clients info, any section after that holds dog info
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    if section == 0 {
      return Client.entity().attributesByName.count
//    } else {
//      return Dog.entity().attributesByName.count
//    }

  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    if indexPath.section == 0 {
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
//    } else {
//      if indexPath.row == 0 {
//        let cell = clientInfoTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        cell.textLabel?.text = "Dogs Name:"
//        cell.detailTextLabel?.text = clientsDogs[indexPath.section - 1].dogName
//        return cell
//      } else if indexPath.row == 1 {
//        let cell = clientInfoTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        cell.textLabel?.text = "Breed:"
//        cell.detailTextLabel?.text = clientsDogs[indexPath.section - 1].breed
//        return cell
//      } else if indexPath.row == 2 {
//        let cell = clientInfoTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        cell.textLabel?.text = "Age:"
//        cell.detailTextLabel?.text = clientsDogs[indexPath.section - 1].age
//        return cell
//      } else if indexPath.row == 3 {
//        let cell = clientInfoTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        cell.textLabel?.text = "Medical Issues:"
//        cell.detailTextLabel?.text = clientsDogs[indexPath.section - 1].meds
//        return cell
//      } else if indexPath.row == 4 {
//        let cell = clientInfoTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        cell.textLabel?.text = "Vet Info:"
//        cell.detailTextLabel?.text = clientsDogs[indexPath.section - 1].vet
//        return cell
//      } else if indexPath.row == 5 {
//        let cell = clientInfoTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        cell.textLabel?.text = "Personality:"
//        cell.detailTextLabel?.text = clientsDogs[indexPath.section - 1].personality
//        return cell
//      } else if indexPath.row == 6 {
//        let cell = clientInfoTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        cell.textLabel?.text = "Grooming Interval:"
//        cell.detailTextLabel?.text = clientsDogs[indexPath.section - 1].groomInterval
//        return cell
//      } else if indexPath.row == 7 {
//        let cell = clientInfoTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        cell.textLabel?.text = "Shampoo:"
//        cell.detailTextLabel?.text = clientsDogs[indexPath.section - 1].shampoo
//        return cell
//      } else if indexPath.row == 8 {
//        let cell = clientInfoTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        cell.textLabel?.text = "Price:"
//        cell.detailTextLabel?.text = clientsDogs[indexPath.section - 1].price
//        return cell
//      } else {
//        let cell = clientInfoTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        cell.textLabel?.text = "Procedure:"
//        cell.detailTextLabel?.text = clientsDogs[indexPath.section - 1].procedure
//        return cell
//      }
//    }
  }
}







