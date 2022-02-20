//
//  APICaller.swift
//  Spotify
//
//  Created by Le Hoang Anh on 17/01/2022.
//

import Foundation

final class APICaller {
    
    static let shared = APICaller()
    private init() {}
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
    
    // MARK: - Albums
    
    public func getAlbumDetails(
        for album: Album,
        completion: @escaping (Result<AlbumDetailsResponse, Error>) -> Void
    ) {
        
        makeRequest(
            with: URL(string: "\(Constants.baseAPIURL)/albums/\(album.id)"),
            type: .GET
        ) { request in
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(AlbumDetailsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    }
    
    
    // MARK: - Playlists
    
    public func getPlaylistDetails(
        for playlist: Playlist,
        completion: @escaping (Result<PlaylistDetailsResponse, Error>) -> Void
    ) {
        
        makeRequest(
            with: URL(string: "\(Constants.baseAPIURL)/playlists/\(playlist.id)"),
            type: .GET
        ) { request in
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(PlaylistDetailsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    }

    public func getCurrentUserPlaylists(
        completion: @escaping (Result<[Playlist], Error>) -> Void
    ) {
        makeRequest(
            with: URL(string: "\(Constants.baseAPIURL)/me/playlists?limit=50"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(
                        LibraryPlaylistsResponse.self,
                        from: data
                    )
                    
                    completion(.success(result.items))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    }
    
    public func createPlaylist(
        with name: String,
        completion: @escaping (Bool) -> Void
    ) {
        getCurrentUserProfile { [weak self] result in
            switch result {
            case .success(let profile):
                let urlString = "\(Constants.baseAPIURL)/users/\(profile.id)/playlists"
                
                self?.makeRequest(with: URL(string: urlString), type: .POST) { baseRequest in
                    var request = baseRequest
                    let bodyData = ["name": name]
                    request.httpBody = try? JSONSerialization.data(
                        withJSONObject: bodyData,
                        options: .fragmentsAllowed
                    )
                    
                    let task = URLSession.shared.dataTask(with: request) { data, _, error in
                        guard let data = data, error == nil else {
                            completion(false)
                            return
                        }
                        
                        do {
                            let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                            
                            if let response = result as? [String: Any],
                               let _ = response["id"] as? String {
                                
                                completion(true)
                            } else {
                                print("ERROR - createPlaylist: Failed to get id")
                                completion(false)
                            }
                            
                        } catch {
                            completion(false)
                        }
                    }
                    
                    task.resume()
                }
                
            case .failure(let error):
                print("ERROR - getCurrentUserProfile inside createPlaylist: \(error.localizedDescription)")
            }
        }
    }
    
    public func addTrackToPlaylist(
        track: AudioTrack,
        playlist: Playlist,
        completion: @escaping (Bool) -> Void
    ) {
        makeRequest(
            with: URL(string: "\(Constants.baseAPIURL)/playlists/\(playlist.id)/tracks"),
            type: .POST
        ) { baseRequest in
            
            let bodyData = [
                "uris": [
                    "spotify:track:\(track.id)",
                ]
            ]
            
            var request = baseRequest
            request.httpBody = try? JSONSerialization.data(
                withJSONObject: bodyData,
                options: .fragmentsAllowed
            )
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    
                    if let response = result as? [String: Any],
                       let _ = response["snapshot_id"] as? String {
                        
                        completion(true)
                    } else {
                        print("ERROR - createPlaylist: Failed to get snapshot_id")
                        completion(false)
                    }
                    
                } catch {
                    print("ERROR - addTrackToPlaylist: \(error.localizedDescription)")
                    completion(false)
                }
            }
            
            task.resume()
        }
    }
    
    public func removeTrackFromPlaylist(
        track: AudioTrack,
        playlist: Playlist,
        completion: @escaping (Bool) -> Void
    ) {
        makeRequest(
            with: URL(string: "\(Constants.baseAPIURL)/playlists/\(playlist.id)/tracks"),
            type: .DELETE
        ) { baseRequest in
            
            let bodyData = [
                "tracks": [
                    [ "uri": "spotify:track:\(track.id)" ],
                ],
            ]
            
            var request = baseRequest
            request.httpBody = try? JSONSerialization.data(
                withJSONObject: bodyData,
                options: .fragmentsAllowed
            )
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    
                    if let response = result as? [String: Any],
                       let _ = response["snapshot_id"] as? String {
                        
                        completion(true)
                    } else {
                        print("ERROR - createPlaylist: Failed to get snapshot_id")
                        completion(false)
                    }
                    
                } catch {
                    print("ERROR - addTrackToPlaylist: \(error.localizedDescription)")
                    completion(false)
                }
            }
            
            task.resume()
        }
    }
    
    
    // MARK: - Profile
    
    public func getCurrentUserProfile(
        completion: @escaping (Result<UserProfile, Error>) -> Void
    ) {
        
        makeRequest(
            with: URL(string: "\(Constants.baseAPIURL)/me"),
            type: .GET
        ) { request in
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    }
    
    
    // MARK: - Browse
    
    public func getNewReleases(
        completion: @escaping (Result<NewReleasesResponse, Error>) -> Void
    ) {
        
        makeRequest(
            with: URL(string: "\(Constants.baseAPIURL)/browse/new-releases?limit=50"),
            type: .GET
        ) { request in
        
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(NewReleasesResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    }
    
    public func getFeaturedPlaylists(
        completion: @escaping (Result<FeaturedPlaylistsResponse, Error>) -> Void
    ) {
        
        makeRequest(
            with: URL(string: "\(Constants.baseAPIURL)/browse/featured-playlists?limit=20"),
            type: .GET
        ) { request in
        
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(
                        FeaturedPlaylistsResponse.self,
                        from: data
                    )
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    }
    
    public func getRecommendations(
        genres: Set<String>,
        completion: @escaping (Result<RecommendationsResponse, Error>) -> Void
    ) {

        let seedGenres = genres.joined(separator: ",")
        
        makeRequest(
            with: URL(
                string: "\(Constants.baseAPIURL)/recommendations?seed_genres=\(seedGenres)&limit=20"
            ),
            type: .GET
        ) { request in

            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(RecommendationsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }

            task.resume()
        }
    }
    
    public func getAvailableGenreSeeds(
        completion: @escaping (Result<AvailableGenreSeedsResponse, Error>) -> Void
    ) {
        
        makeRequest(
            with: URL(string: "\(Constants.baseAPIURL)/recommendations/available-genre-seeds"),
            type: .GET
        ) { request in
        
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(
                        AvailableGenreSeedsResponse.self,
                        from: data
                    )
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    }
    
    
    // MARK: - Categories
    
    public func getAllCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        let url = URL(string: "\(Constants.baseAPIURL)/browse/categories?limit=50")
        
        makeRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(AllCategoriesResponse.self, from: data)
                    completion(.success(result.categories.items))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    }
    
    public func getCategoryPlaylists(
        category: Category,
        completion: @escaping (Result<[Playlist], Error>) -> Void
    ) {
        
        let url = URL(
            string: "\(Constants.baseAPIURL)/browse/categories/\(category.id)/playlists?limit=50"
        )
        
        makeRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(CategoryPlaylistsResponse.self, from: data)
                    completion(.success(result.playlists.items))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    }
    
    
    // MARK: - Search
    
    public func search(with query: String, completion: @escaping (Result<[SearchResult], Error>) -> Void) {
        
        let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let type = "album,artist,playlist,track"
        let url = URL(string: "\(Constants.baseAPIURL)/search?q=\(queryEncoded)&type=\(type)&limit=10")
        
        makeRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(SearchResultsResponse.self, from: data)
                    
                    var searchResults = [SearchResult]()
                    searchResults.append(contentsOf: result.albums.items.compactMap({ .album(model: $0) }))
                    searchResults.append(contentsOf: result.artists.items.compactMap({ .artist(model: $0) }))
                    searchResults.append(contentsOf: result.playlists.items.compactMap({ .playlist(model: $0) }))
                    searchResults.append(contentsOf: result.tracks.items.compactMap({ .track(model: $0) }))
                    
                    completion(.success(searchResults))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    }
    
    
    // MARK: - Private
    
    private enum HTTPMethod: String {
        case GET
        case POST
        case DELETE
    }
    
    private func makeRequest(
        with url: URL?,
        type: HTTPMethod,
        completion: @escaping (URLRequest) -> Void
    ) {
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else {
                return
            }
            
            var request = URLRequest(url: apiURL)
            request.httpMethod = type.rawValue
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            completion(request)
        }
    }
    
}
