//
//  DogInfoViewController.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 11/2/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//

import UIKit

class DogInfoViewController: UIViewController {
  @IBOutlet weak var dogInfoTableView: UITableView!
  
  var dog: Dog?
  var newDog: Bool?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dogInfoTableView.estimatedRowHeight = 50
    dogInfoTableView.rowHeight = UITableViewAutomaticDimension
  }

  @IBAction func doneSavingClient(_ segue: UIStoryboardSegue) {
    dogInfoTableView.reloadData()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "editDogInfoSegue" {
      let destinationNavController = segue.destination as! UINavigationController
      if let editVC = destinationNavController.topViewController as? AddDogViewController {
        editVC.newDog = false
        editVC.dog = dog
      }
    }
  }
}

extension DogInfoViewController: UITableViewDelegate, UITableViewDataSource {
  
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
    view.textLabel?.text = dog?.dogName
    return view
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return Dog.entity().attributesByName.count - 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let cell = dogInfoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.titleText.text = "Breed:"
      cell.detailText.text = dog?.breed
      return cell
    } else if indexPath.row == 1 {
      let cell = dogInfoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.titleText.text = "Age:"
      cell.detailText.text = dog?.age
      return cell
    } else if indexPath.row == 2 {
      let cell = dogInfoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.titleText.text = "Medical Issues:"
      cell.detailText.text = dog?.meds
      return cell
    } else if indexPath.row == 3 {
      let cell = dogInfoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.titleText.text = "Vet Info:"
      cell.detailText.text = dog?.vet
      return cell
    } else if indexPath.row == 4 {
      let cell = dogInfoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.titleText.text = "Personality:"
      cell.detailText.text = dog?.personality
      return cell
    } else if indexPath.row == 5 {
      let cell = dogInfoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.titleText.text = "Grooming Interval:"
      cell.detailText.text = dog?.groomInterval
      return cell
    } else if indexPath.row == 6 {
      let cell = dogInfoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.titleText.text = "Shampoo:"
      cell.detailText.text = dog?.shampoo
      return cell
    } else if indexPath.row == 7 {
      let cell = dogInfoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.titleText.text = "Price:"
      cell.detailText.text = dog?.price
      return cell
    } else {
      let cell = dogInfoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.titleText.text = "Procedure:"
      cell.detailText.text = dog?.procedure
      return cell
    }
  }
}










