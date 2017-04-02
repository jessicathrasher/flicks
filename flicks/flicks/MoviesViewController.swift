//
//  MoviesViewController.swift
//  flicks
//
//  Created by Jessica Thrasher on 3/31/17.
//  Copyright © 2017 Cisco. All rights reserved.
//

import UIKit
import AFNetworking
import KVSpinnerView

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var networkOfflineView: UIView!
    let apiKey = "a3ca980c4173693c64d65288ff11fd52"
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var endpoint: String!
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchBar.delegate = self
        searchBar.tintColor = Config.flicksGreenColor
        
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(self.refreshControlAction(_:)), for: .valueChanged)
        
        // add refresh control to the tableview
        tableView.insertSubview(refreshControl, at: 0)

        self.networkOfflineView.isHidden = true
        self.networkOfflineView.layer.zPosition = CGFloat.greatestFiniteMagnitude
        
        KVSpinnerView.settings.animationStyle = KVSpinnerViewSettings.AnimationStyle.infinite
        KVSpinnerView.settings.linesCount = 1
        KVSpinnerView.settings.backgroundOpacity = 0.8
        KVSpinnerView.settings.backgroundRectColor = Config.flicksDarkGreenColor
        
        getMovies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let indexPath = tableView.indexPathForSelectedRow {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.selectedBackgroundView = UIView()
        }
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        getMovies()
    }
    
    func getMovies() {
        
        KVSpinnerView.show()
        
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                self.networkOfflineView.isHidden = false
                
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                
                self.networkOfflineView.isHidden = true
                
                self.movies = dataDictionary["results"] as? [NSDictionary]
                self.tableView.reloadData()
            }
            self.refreshControl.endRefreshing()
            KVSpinnerView.dismiss()
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let filteredMovies = filteredMovies, filteredMovies.count > 0 {
            return filteredMovies.count
        }
        
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        var movie = movies![indexPath.row]
        
        // If movies are being filtered by search, use the filtered dictionary instead
        if let filteredMovies = filteredMovies, filteredMovies.count > 0 {
          movie = filteredMovies[indexPath.row]
        }
            
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        if let posterPath = movie["poster_path"] as? String {
            let baseURL = "https://image.tmdb.org/t/p/w500"
            
            let imageRequest = URLRequest(url: URL(string: baseURL + posterPath)!)
            
            cell.posterView.setImageWith(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        // if not cached, fade in the image
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        cell.posterView.image = image
                    }
            },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
        }
        
        cell.title.text = title
        cell.overview.text = overview
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.filteredMovies = self.movies?.filter { String(describing: $0["title"]).range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil}
        
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        filteredMovies = [NSDictionary]()
        
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = Config.flicksGreenColor
        cell.selectedBackgroundView = backgroundView
        
        var movie = movies?[(indexPath?.row)!]
        
        if let filteredMovies = filteredMovies, filteredMovies.count > 0 {
            movie = filteredMovies[(indexPath?.row)!]
        }
        
        let detailViewController = segue.destination as! DetailViewController
        
        detailViewController.movie = movie
    }
}
