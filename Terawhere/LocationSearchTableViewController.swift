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

class LocationSearchTableViewController: UITableViewController, UISearchBarDelegate, MKLocalSearchCompleterDelegate {

	var searchController: UISearchController?
	var localSearchCompleter: MKLocalSearchCompleter?
	
	var filteredLocations: [MKLocalSearchCompletion]?
	
	var delegate: LocationSelectProtocol?
	
	// both buttons have the same segues
	// this helps to differentiate
	var state: String?

    override func viewDidLoad() {
        super.viewDidLoad()

		self.searchController = UISearchController.init(searchResultsController: nil)
		searchController?.dimsBackgroundDuringPresentation = false
		searchController?.hidesNavigationBarDuringPresentation = false
		self.definesPresentationContext = true
		
		self.localSearchCompleter = MKLocalSearchCompleter()
		self.localSearchCompleter?.delegate = self
		
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
	
	// MARK: search bar delegate
	public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		self.localSearchCompleter?.queryFragment = searchText
	}
	
	// MARK: MKLocalSearchCompleter delegate
	public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
		self.filteredLocations = completer.results
		
		self.tableView.reloadData()
		
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
		cell.textLabel?.text = self.filteredLocations?[indexPath.row].title
		cell.detailTextLabel?.text = self.filteredLocations?[indexPath.row].subtitle

        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let item = self.filteredLocations?[indexPath.row]
		let request = MKLocalSearchRequest()
		request.naturalLanguageQuery = item?.title
		let search = MKLocalSearch(request: request)
		search.start { (response, error) in
			
			guard let response = response else {
				print("Response is nil")
			
				return
			}
			
			guard let item = response.mapItems.first else {
				print("Item is nil")
				
				return
			}
			
			if self.state == "end" {
				self.delegate?.use(mapItem: item, forLocationState: self.state!)
			}
			
			if self.state == "start" {
				self.delegate?.use(mapItem: item, forLocationState: self.state!)
			}
			
			_ = self.navigationController?.popViewController(animated: true)
		}
	}

}
