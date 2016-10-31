//
//  Utilities.swift
//  Twitter
//
//  Created by Luis Perez on 10/30/16.
//  Copyright © 2016 Luis PerezBunnyLemon. All rights reserved.
//

import UIKit

func presentNotification(parentViewController controller: UIViewController, notificationTitle title: String, notificationMessage message: String, completion: (() -> Void)?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
    controller.present(alert, animated: true, completion: completion)
}
