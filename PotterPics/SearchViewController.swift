//
//  SearchViewController.swift
//  PotterPics
//
//  Created by Suraya Shivji on 12/5/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var filteredUsers: [User]!
    var users : [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        getUsers()
        filteredUsers = users
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func getUsers() {
        let DB = FIRDatabase.database().reference()
        let usersRef : FIRDatabaseReference = DB.child("users")
        usersRef.observe(.value, with: { (snapshot) in
            if let dict = snapshot.value as? NSDictionary {
                for item in dict {
                    
                    let json = JSON(item.value)
                    let name: String = json["name"].stringValue
                    let email: String = json["email"].stringValue
                    let fbID: String = json["facebookID"].stringValue
                    let firebaseID: String = item.key as! String
                    // create User, add to users array
                    let user = User(name: name, email: email, facebookID: fbID, userID: firebaseID)
                    self.users.append(user)
                    self.filteredUsers = self.users
                }
            }
        })
    }
    
    // MARK: - Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.filteredUsers != nil { // check for nil
            return self.filteredUsers!.count
        }
        else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! SearchTableViewCell
        cell.searchImageView.image = UIImage()
        let user = filteredUsers[indexPath.row]
        let name = user.name
        cell.searchName.text = name
        cell.searchCountPosts.text = "\(indexPath.row)" // change to number of posts after
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    // MARK: - Search Bar Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // search bar text changed
        if(searchText.isEmpty) {
            filteredUsers = users
        } else {
            // user typed in search box
            // return true in filter if item should be included
            filteredUsers = users.filter({ (user: User) -> Bool in
                let name = user.name
                if name.range(of: searchText, options: .caseInsensitive ) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}
