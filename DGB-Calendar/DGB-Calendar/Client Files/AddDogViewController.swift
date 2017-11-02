//
//  AddDogViewController.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 11/2/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//

import UIKit
import CoreData

class AddDogViewController: UIViewController {
  @IBOutlet weak var dogNameTextField: UITextField!
  @IBOutlet weak var breedTextField: UITextField!
  @IBOutlet weak var ageTextField: UITextField!
  @IBOutlet weak var medsTextField: UITextField!
  @IBOutlet weak var vetInfoTextField: UITextField!
  @IBOutlet weak var personalityTextField: UITextField!
  @IBOutlet weak var groomTextField: UITextField!
  @IBOutlet weak var shampooTextField: UITextField!
  @IBOutlet weak var priceTextField: UITextField!
  @IBOutlet weak var procedureTextField: UITextField!
  
  var client: Client?
  var dog: Dog?
  var newDog: Bool?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if dog != nil {
      dogNameTextField.text = dog?.dogName
      breedTextField.text = dog?.breed
      ageTextField.text = dog?.age
      medsTextField.text = dog?.meds
      vetInfoTextField.text = dog?.vet
      personalityTextField.text = dog?.personality
      groomTextField.text = dog?.groomInterval
      shampooTextField.text = dog?.shampoo
      priceTextField.text = dog?.price
      procedureTextField.text = dog?.procedure
    }
  }
  
  @IBAction func saveDogInfo(_ sender: Any) {
    if(dogNameTextField.text! != "" && breedTextField.text! != "") {
      let dogNameToSave =  dogNameTextField.text
      let breedToSave = breedTextField.text
      let ageToSave = ageTextField.text
      let medsToSave = medsTextField.text
      let vetInfoToSave = vetInfoTextField.text
      let personalityToSave = personalityTextField.text
      let groomToSave = groomTextField.text
      let shampooToSave = shampooTextField.text
      let priceToSave = priceTextField.text
      let procedureToSave = procedureTextField.text
      
      self.save(name: dogNameToSave!, breed: breedToSave!, age: ageToSave!, meds: medsToSave!, vetInfo: vetInfoToSave!, personality: personalityToSave!, groomInterval: groomToSave!, shampoo: shampooToSave!, price: priceToSave!, procedure: procedureToSave!)
    } else {
      let alert = UIAlertController(title: "Error",
                                    message: "Must include atleast a Name and Breed",
                                    preferredStyle: .alert)
      let endAlert = UIAlertAction(title: "Back",
                                   style: .default)
      alert.addAction(endAlert)
      present(alert, animated: true)
    }
  }
  
  func save(name: String, breed: String, age: String, meds: String, vetInfo: String, personality: String, groomInterval: String, shampoo: String, price: String, procedure: String) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    if newDog == true {
      let entity = NSEntityDescription.entity(forEntityName: "Dog", in: managedContext)
      
      let dog = NSManagedObject(entity: entity!, insertInto: managedContext) as! Dog
      
      dog.setValue(name, forKey: "dogName")
      dog.setValue(breed, forKey: "breed")
      dog.setValue(age, forKey: "age")
      dog.setValue(meds, forKey: "meds")
      dog.setValue(vetInfo, forKey: "vet")
      dog.setValue(personality, forKey: "personality")
      dog.setValue(groomInterval, forKey: "groomInterval")
      dog.setValue(shampoo, forKey: "shampoo")
      dog.setValue(price, forKey: "price")
      dog.setValue(procedure, forKey: "procedure")
      
      dog.owner = client
      
      do {
        try managedContext.save()
        self.performSegue(withIdentifier: "doneSavingClient", sender: self)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    } else {
      let dogToChange = dog! as NSManagedObject
      
      dogToChange.setValue(name, forKey: "dogName")
      dogToChange.setValue(breed, forKey: "breed")
      dogToChange.setValue(age, forKey: "age")
      dogToChange.setValue(meds, forKey: "meds")
      dogToChange.setValue(vetInfo, forKey: "vet")
      dogToChange.setValue(personality, forKey: "personality")
      dogToChange.setValue(groomInterval, forKey: "groomInterval")
      dogToChange.setValue(shampoo, forKey: "shampoo")
      dogToChange.setValue(price, forKey: "price")
      dogToChange.setValue(procedure, forKey: "procedure")
      
      do {
        try dogToChange.managedObjectContext?.save()
        self.performSegue(withIdentifier: "doneSavingClient", sender: self)
      } catch let error as NSError {
        print("Could not edit. \(error), \(error.userInfo)")
      }
    }
  }
  
}







