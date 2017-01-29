//
//  TableViewController.swift
//  THLabelExample
//
//  Created by Vitalii Parovishnyk on 1/12/17.
//  Copyright © 2017 IGR Software. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak fileprivate var customTextLabel: THLabel?
}

class TableViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "Cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as! TableViewCell
        
        cell.customTextLabel?.textColor = UIColor.white;
        cell.customTextLabel?.strokeColor = Constants.kStrokeColor;
        cell.customTextLabel?.strokeSize = Constants.kStrokeSize;
        cell.customTextLabel?.gradientStartColor = Constants.kGradientStartColor;
        cell.customTextLabel?.gradientEndColor = Constants.kGradientEndColor;
        
        return cell;
    }

}
