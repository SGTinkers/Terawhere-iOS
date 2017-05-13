//
//  LocationSearchTableViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 3/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit
import MapKit

protocol LocationSelectProtocol {
	func use(mapItem: MKMapItem, forLocationState state: String)
}

class LocationSearchTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {

	var searchController: UISearchController?
	
	var filteredLocations: [MKMapItem]?
	
	var delegate: LocationSelectProtocol?
	
	// both buttons have the same segues
	// this helps to differentiate
	var state: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
		
		self.searchController = UISearchController.init(searchResultsController: nil)
		searchController?.searchResultsUpdater = self
		searchController?.dimsBackgroundDuringPresentation = false
		searchController?.hidesNavigationBarDuringPresentation = false
		self.definesPresentationContext = true
		
		self.searchController?.searchBar.delegate = self
		self.tableView.tableHeaderView = self.searchController?.searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		if let filteredMapItems = self.filteredLocations {
			return filteredMapItems.count
		}
		
        return 0
    }
	
	// MARK: Search results updating delegate
	public func updateSearchResults(for searchController: UISearchController) {
		if let searchBarText = self.searchController?.searchBar.text {
			if searchBarText.isEmpty {
				self.filteredLocations?.removeAll()
				
				self.tableView.reloadData()
			}
		}
	
		let localSearchReq = MKLocalSearchRequest()
		localSearchReq.naturalLanguageQuery = self.searchController?.searchBar.text
		
		let localSearch = MKLocalSearch.init(request: localSearchReq)
		localSearch.start { (response, error) in
			self.filteredLocations = response?.mapItems
			
			self.tableView.reloadData()
		}
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
		cell.textLabel?.text = self.filteredLocations?[indexPath.row].name

        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let mapItem = self.filteredLocations?[indexPath.row] {
			if self.state == "end" {
				self.delegate?.use(mapItem: mapItem, forLocationState: self.state!)
			}
			
			if self.state == "start" {
				self.delegate?.use(mapItem: mapItem, forLocationState: self.state!)
			}
		
			_ = self.navigationController?.popViewController(animated: true)
		}
	}

}
