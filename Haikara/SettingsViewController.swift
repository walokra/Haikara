//
//  SettingsViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 7.7.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var useMobileUrlSwitch: UISwitch!
    @IBOutlet weak var showDescSwitch: UISwitch!
    @IBOutlet weak var countryPicker: UIPickerView!

    let settings = Settings.sharedInstance

    var defaults = NSUserDefaults.standardUserDefaults()
    
    let regions: [String] = ["Finland", "Estonia", "Germany", "United States", "Norway", "Denmark", "Sweden", "Netherlands", "Italian"]
    
    @IBAction func useMobileUrl(sender: UISwitch) {
        settings.useMobileUrl = sender.on
        defaults.setObject(settings.useMobileUrl, forKey: "useMobileUrl")
//        println ("useMobileUrl \(settings.useMobileUrl), sender.on=\(sender.on)")
    }
    
    @IBAction func showDesc(sender: UISwitch) {
        settings.showDesc = sender.on
        defaults.setObject(settings.showDesc, forKey: "showDesc")
//        println ("showDesc \(settings.showDesc), sender.on=\(sender.on)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showDescSwitch.on = settings.showDesc
        useMobileUrlSwitch.on = settings.useMobileUrl
        
        countryPicker.dataSource = self
        countryPicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return regions.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return regions[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        settings.country = regions[row]
        defaults.setObject(settings.country, forKey: "country")
//        println ("country \(settings.country)")
        self.view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
