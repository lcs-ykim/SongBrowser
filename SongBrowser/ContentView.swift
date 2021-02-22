//
//  ContentView.swift
//  SongBrowser
//
//  Created by Yeseo Kim on 2021-02-20.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: Stored properties
    
    // Keeps track of what the user searches for
    @State private var searchText = ""
    
    // Keeps the list of songs retrieved from Apple Music
    @State private var songs: [Song] = [] // empty array to start
    
    // MARK: Computed properties
    var body: some View {
        VStack {
            
            SearchBarView(text: $searchText)
                .onChange(of: searchText) { _ in
                    fetchSongResults()
                }
            
            // Show a prompt when no search text is given
            if searchText.isEmpty {
                
                Spacer()
                
                Text("Please enter an artist name")
                    .font(.title)
                    .foregroundColor(.secondary)
                
                Spacer()
                
            } else {
                
                // Search text was given, results obtained
                // Show the list of results
                // Keypath of \.trackId tells the List view what property to use
                // to uniquely identify each song
                List(songs, id: \.trackId) { currentSong in
                    
                    SimpleListItemView(title: currentSong.trackName,
                                       caption: currentSong.artistName)
                    
                }
                
            }
            
        }
    }
    
    // MARK: Functions
    func fetchSongResults() {
        
        let input = searchText.lowercased().replacingOccurrences(of: " ", with: "+")
        
        let url = URL(string: "https://itunes.apple.com/search?term=\(input)&entity=song")!

        var request = URLRequest(url: url)
        request.setValue("application/json",
                         forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in

            guard let songData = data else {

                print("No data in response: \(error?.localizedDescription ?? "Unknown error")")

                return

            }

              print(String(data: songData, encoding: .utf8)!)

            if let decodedSongData = try? JSONDecoder().decode(SearchResult.self, from: songData) {

                print("Song data decoded from JSON successfully")

                DispatchQueue.main.async {

                    songs = decodedSongData.results

                }

            } else {

                print("Could not decode JSON into an instance of the SearchResult structure.")

            }

        }.resume()

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
