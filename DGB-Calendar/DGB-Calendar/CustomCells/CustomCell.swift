//
//  CustomCell.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 10/16/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CustomCell: JTAppleCell {
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var selectedView: UIView!
  @IBOutlet weak var eventDotView: UIImageView!
}
