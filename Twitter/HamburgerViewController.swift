//
//  HamburgerViewController.swift
//  Twitter
//
//  Created by Luis Perez on 11/4/16.
//  Copyright © 2016 Luis PerezBunnyLemon. All rights reserved.
//

import UIKit

private enum MenuState {
    case closed
    case open
}

class HamburgerViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var menuView: UIView!
    
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
    private var originalLeftMargin: CGFloat!
    
    weak var menuViewController: MenuViewController! {
        didSet(oldMenuViewController) {
            view.layoutIfNeeded()
            
            if oldMenuViewController != nil {
                removeController(oldMenuViewController)
            }
        
            moveControllerAndView(menuViewController, view: menuView, toParent: self)

        }
    }
    
    weak var contentViewController: UIViewController! {
        didSet(oldContentViewController) {
            view.layoutIfNeeded()
            
            if oldContentViewController != nil {
                removeController(oldContentViewController)
                
            }
            
            moveControllerAndView(contentViewController, view: contentView, toParent: self)
            
            snapMenu(.closed)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func removeController(_ controller: UIViewController) {
        controller.willMove(toParentViewController: nil)
        controller.view.removeFromSuperview()
        controller.didMove(toParentViewController: nil)
    }
    
    private func moveControllerAndView(_ controller: UIViewController, view: UIView, toParent parent: UIViewController) {
        controller.willMove(toParentViewController: parent)
        view.addSubview(controller.view)
        controller.didMove(toParentViewController: parent)
    }
    
    private func snapMenu(_ state: MenuState) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [], animations: {[unowned self] in
            switch state {
            case .open:
                self.leftMarginConstraint.constant = self.view.frame.size.width -  50
            case .closed:
                self.leftMarginConstraint.constant = 0
            }
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        if sender.state == .began {
            originalLeftMargin = leftMarginConstraint.constant
        }
        else if sender.state == .changed {
            leftMarginConstraint.constant = originalLeftMargin + translation.x
        }
        else if sender.state == .ended {
            let velocity = sender.velocity(in: view)
            if velocity.x > 0 {
                snapMenu(.open)
            } else {
                snapMenu(.closed)
            }
        }
        else {
            
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
