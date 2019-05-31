//
//  ViewController.swift
//  MZRKitDemo iOS
//
//  Created by scchnxx on 2019/4/5.
//  Copyright © 2019 scchnxx. All rights reserved.
//

import UIKit
import MZRKit

class ViewController: UIViewController {

    @IBOutlet weak var mzrView: MZRView!
    
    @IBOutlet weak var pickerContainerView: UIView!
    
    @IBOutlet weak var pickerContainerViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerHidden: Bool {
        get {
            return pickerContainerViewBottom.constant != 0
        }
        set {
            pickerContainerViewBottom.constant = !newValue ? 0 : -view.bounds.height / 2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mzrView.makeItem(.textField)
        pickerHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func normal(_ sender: Any) {
        mzrView.normal()
    }
    
    @IBAction func switchPicker(_ sender: Any) {
        UIView.animate(withDuration: 0.33) {
            self.pickerHidden.toggle()
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func makeItem(_ sender: Any) {
        let itemType = MZRView.Item.allCases[pickerView.selectedRow(inComponent: 0)]
        mzrView.makeItem(itemType)
        switchPicker(self)
    }
    
    @IBAction func deleteItem(_ sender: Any) {
        mzrView.deleteSelectedItems()
    }
    
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MZRView.Item.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int,
                    forComponent component: Int) -> NSAttributedString?
    {
        return NSAttributedString(string: "\(MZRView.Item.allCases[row])",
                                  attributes: [.foregroundColor : UIColor.white])
    }
    
}
