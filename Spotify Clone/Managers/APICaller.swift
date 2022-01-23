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
