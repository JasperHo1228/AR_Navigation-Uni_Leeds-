//
//  TableViewController.swift
//  landmarkar
//
//  Created by Tsun Yin Ho on 6/6/2022.
//


import MapKit

class TableViewController: UITableViewController {
    var matchingItems:[MKMapItem] = []
    var map: MKMapView? = nil
    var mapSearching:MapSearch? = nil
    var selectedItem:MKPlacemark? = nil
}

// keep updating the searching table content from the searching bar
extension TableViewController:UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //map is refer to the apple map UI
        guard let map = map,
            //searchBarText means the text information that type in text searching bar.
            //if there no text in the searching bar it will return nothing
            let searchBarText = searchController.searchBar.text else { return }
        
        //request means start using the searching related location address
        let request = MKLocalSearch.Request()
        
        //this mean request information that the user would type in the searching bar
        request.naturalLanguageQuery = searchBarText
        request.region = map.region
        //starting to search all the locations that possible refer to the text in the searhcing bar
        //if there not existed any location that the users has inputted it will return nothing, otherwise
        //the matchingItem will be existed
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            
            self.matchingItems = response.mapItems
            //keep refreshing data
            self.tableView.reloadData()
        }
    }

}

//display the number of cell from the matching Items (matching Items = address)
extension TableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
   //display all the possible destination name and address details on each cell
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
               let location_show = matchingItems[indexPath.row].placemark
               cell.textLabel?.text = location_show.name
               let address = "\(location_show.thoroughfare ?? ""), \(location_show.locality ?? ""), \(location_show.subLocality ?? ""), \(location_show.administrativeArea ?? ""), \(location_show.postalCode ?? ""), \(location_show.country ?? "")"
       cell.detailTextLabel?.text = address
               return cell
    }
}


extension TableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //get the user selected destination from the cell
        self.selectedItem = matchingItems[indexPath.row].placemark
        //return the selected location/Item to func location_info which created in MapViewController
        mapSearching?.location_info(placemark: self.selectedItem!)
        dismiss(animated: true, completion: nil)
    }
}
