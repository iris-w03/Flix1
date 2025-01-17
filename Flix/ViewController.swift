//
//  ViewController.swift
//  Flix
//
//  Created by Ziyue Wang on 2/22/22.
//

import UIKit
import AlamofireImage

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet var searchBarView: UISearchBar!
    
    var movies = [[String:Any]]() // an array of dictionaries
    var filteredMovies = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBarView.delegate = self
        searchBarView.endEditing(true)
        requestData()
    }
    
    //3 functions to handle search movies
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            searchBarView.endEditing(true)
        }
        
    func searchBarSearchButtonClicked(_ searchBarView: UISearchBar) {
        searchBarView.endEditing(true)
        }
        
    func searchBarCancelButtonClicked(_ searchBarView: UISearchBar) {
        searchBarView.endEditing(true)
        }
    
    // search movie and show new list
    func searchBar(_ searchBarView: UISearchBar, textDidChange searchText: String){
        filteredMovies = []
        if (searchText == ""){
            filteredMovies = movies
        }
        else{
            for movie in movies{
                let title = movie["title"] as! String
                if (title.lowercased().contains(searchText.lowercased())){
                    filteredMovies.append(movie)
                }
            }
        }
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell
            
            let movie = filteredMovies[indexPath.row]
                    
            let title = movie["title"] as! String
            let synopsis = movie["overview"] as! String
                    
            cell.titleLabel.text = title
            cell.synopsisLabel.text = synopsis
                    
            let baseUrl = "https://image.tmdb.org/t/p/w185"
            let posterPath = movie["poster_path"] as! String
                    
            let posterUrl = URL(string: baseUrl + posterPath)
                    
            cell.posterView.af.setImage(withURL: posterUrl!)
                    
            return cell
            
    }
    
    //load movies info
    func requestData(){
        // Do any additional setup after loading the view.
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) {[self] (data, response, error) in
             // This will run when the network request returns
             if let error = error {
                    print(error.localizedDescription)
             } else if let data = data {
                    let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    let typeCheck = type(of: dataDictionary)
                    print("type: \(typeCheck)")

                    // TODO: Get the array of movies
                    // TODO: Store the movies in a property to use elsewhere
                    // TODO: Reload your table view data
                 self.movies = dataDictionary["results"] as! [[String:Any]]
                 filteredMovies = movies
                 self.tableView.reloadData()
             }
        }
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        //print("Loading up the details screen!")
        
        // Find the selected movie
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)!
        let movie = movies[indexPath.row]
        
        // Pass the selected movie to the details view controller
        let detailsViewController = segue.destination as! MovieDetailsViewController
        detailsViewController.movie = movie
        
        //返回的时候原来选中的被deselect
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

