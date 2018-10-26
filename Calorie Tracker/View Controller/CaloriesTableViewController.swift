//
//  CaloriesTableViewController.swift
//  Calorie Tracker
//
//  Created by Ilgar Ilyasov on 10/26/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData
import SwiftChart

class CaloriesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Property
    
    let cellIdentifier = "CaloriesCell"
    let calorieController = CalorieController()
    
    // DateFormatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    // NSFetchedResultController
    lazy var fetchedResultsController: NSFetchedResultsController<Calorie> = {
        
        let fetchRequest: NSFetchRequest<Calorie> = Calorie.fetchRequest()
        let sortDescriptor = [NSSortDescriptor(key: "timestamp", ascending: true)]
        fetchRequest.sortDescriptors = sortDescriptor
        
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "timestamp", cacheName: nil)
        
        frc.delegate = self
        try! frc.performFetch()
        
        return frc
    }()
    
    // SwiftCharts
    var chart = Chart()
    
    
    // MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = CGRect(x: 0, y: 0,
                           width: view.frame.width, height: chartView.frame.height)
        chart = Chart(frame: frame)
        chartView.addSubview(chart)
        drawChart()
        
        NotificationCenter.default.addObserver(self, selector: #selector(drawChart), name: .didUpdateChart, object: nil)
    }
    
    @objc func drawChart() {
        guard let amounts = fetchedResultsController.fetchedObjects?.compactMap({ Double($0.amount) }) else { return }
        let series = ChartSeries(amounts)
        series.color = ChartColors.cyanColor()
        series.area = true
        chart.add(series)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        chart.setNeedsDisplay()
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var chartView: UIView!
    
    // MARK: - Action
    
    @IBAction func addBarButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add Calorie intake", message: "Enter the amount of calories in field", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Calories:"
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let submit = UIAlertAction(title: "Submit", style: .default) { (submit) in
            guard let calorieAmount = alert.textFields?.first?.text, !calorieAmount.isEmpty else { return }
            self.calorieController.addCalorie(amount: Int(calorieAmount) ?? 0)
            NotificationCenter.default.post(name: .didUpdateChart, object: nil) // Send notification
            self.tableView.reloadData()
        }
        
        alert.addAction(cancel)
        alert.addAction(submit)
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let calorie = fetchedResultsController.object(at: indexPath)
        let amount = String(calorie.amount)
        let timestamp = dateFormatter.string(from: calorie.timestamp ?? Date())
        
        cell.textLabel?.text = "Calories: \(amount)"
        cell.detailTextLabel?.text = timestamp
        
        return cell
    }
}

// MARK: - NotificationCenter

extension Notification.Name {
    static let didUpdateChart = Notification.Name("didUpdateChart")
}

// MARK: - NSFetchedResultsControllerDelegate

extension CalorieTableViewController {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {return}
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else {return}
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else {return}
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath,
                let newIndexPath = newIndexPath else {return}
            //            tableView.moveRow(at: indexPath, to: newIndexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
}
