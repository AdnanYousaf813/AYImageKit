//
//  AYImageDownloader.swift
//  AYImageKit
//
//  Created by Adnan Yousaf on 16/09/2021.
//

import UIKit

public class AYImageDownloader {
    
    public enum DownloadImageError: Error {
        case invalidRequestData
        case invalidResponseData
    }
    
    public typealias FetchImageHandler = (Result<UIImage>) -> Void
    
    private let memoryImageCache = MemoryImageCache(capacity: .megaBytes(4))
    private let diskImageCache = DiskImageCache(capacity: .megaBytes(50))
    private let memoryCache = NSCache<NSURL, UIImage>()
    private let diskCache: URLCache
    
    private let urlSession: URLSession
    private let queue: DispatchQueue
    private var completionHandlers: [URL: [FetchImageHandler]] = [:]
    
    public static let shared = AYImageDownloader()
    
    public init() {
        self.diskCache = URLCache(memoryCapacity: 0, diskCapacity: 20 * 1024 * 1024, diskPath: nil) // 20MB on disk
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.urlSession = URLSession(configuration: configuration)
        self.memoryCache.totalCostLimit = 4 * 1024 * 1024 // 4MB on memory
        self.queue = DispatchQueue(label: "ImageDownloader.Queue", qos: .utility)
    }
    
    /**
     Retrieves an image from a URL. Handles 2 level caching (memory and disk).
     A cached image is retrieved for urls with the same host and path as the original, ignoring the query.
     Each download cached on disk is invalidated after 24h.
        - parameter url: The address of the image
        - parameter forceRemoteFetching: If `true` the function retrieves a cached image and makes a request at the same time.
                                        The completion handler is called twice. Defaults to `false`.
        
        - parameter cacheInMemory: If `true` image cache will save in Memory. Defaults to `false`.
        - parameter cacheInDisk: If `true` image cache will save in Disk. Defaults to `true`.
        - parameter completionQueue: The queue from which the completion handler should be called.
        - parameter completion: The completion handler that receives the fetch result.
     */
    public func fetchImage(from url: URL?, forceRemoteFetching: Bool = false, cacheInMemory: Bool = false, cacheInDisk:Bool = true, completionQueue: DispatchQueue = .main, completion: @escaping FetchImageHandler) {
        
        let dispatchCompletion: FetchImageHandler = { result in
            completionQueue.async { completion(result) }
        }
        
        guard let url = url else {
            dispatchCompletion(.failure(DownloadImageError.invalidRequestData))
            return
        }
        
        let referenceURL = self.referenceURL(for: url)
        
        // Check memory cache in main queue
        var imageFetched = false
        if let imageOnMemory = memoryImageCache.image(for: referenceURL) {
            dispatchCompletion(.success(imageOnMemory))
            guard forceRemoteFetching else { return }
            imageFetched = true
        }
        
        // Check disk cache in background queue
        self.queue.async {
            
            if imageFetched == false, let imageOnDisk = self.diskImageCache.image(for: referenceURL) {
                self.memoryImageCache.store(imageOnDisk, for: referenceURL)
                dispatchCompletion(.success(imageOnDisk))
                guard forceRemoteFetching else { return }
                imageFetched = true
            }
            
            // If not found on any cache, append to the ongoing request or make a new one
            if var handlers = self.completionHandlers[referenceURL] {
                handlers.append(dispatchCompletion)
                self.completionHandlers[referenceURL] = handlers
                
            } else {
                
                self.completionHandlers[referenceURL] = [dispatchCompletion]
                self.downloadImage(from: url) { [weak self] result in
                    
                    guard let self = self else { return }
                    
                    self.queue.async {
                        
                        let completionHandlers = self.completionHandlers[referenceURL] ?? []
                        self.completionHandlers[referenceURL] = nil
                        
                        if let (image, data) = result.value {
                            
                            if cacheInDisk {
                                self.diskImageCache.store(image, data: data, for: referenceURL)
                            }
                            if cacheInMemory {
                                self.memoryImageCache.store(image, for: referenceURL)
                            }
                        }
                        
                        let result: Result<UIImage> = result.map { $0.0 }
                        completionHandlers.forEach { $0(result) }
                    }
                }
            }
        }
    }
    
    
    /// Truncates url to remove tokens and other temp values
    private func referenceURL(for url: URL) -> URL {
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.query = nil
        guard let truncatedURL = urlComponents?.url else {
            print("Unable to truncate \(url) for image caching")
            return url
        }
        return truncatedURL
    }
    
    /// Performs the network request for downloading an image
    private func downloadImage(from url: URL, completion: @escaping (Result<(UIImage, Data)>) -> Void) {
        
        let dataTask = urlSession.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            self.queue.async {
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data,
                    let image = UIImage(data: data) else {
                        completion(.failure(DownloadImageError.invalidResponseData))
                        return
                }
                completion(.success((image, data)))
            }
        }
        
        dataTask.resume()
    }
    
    public func clearCache(for url: URL) {
        let referenceURL = self.referenceURL(for: url)
        
        // Clear memory cache in main queue
        memoryImageCache.clearCache(for: referenceURL)
        
        // Clear disk cache in background queue
        self.queue.async {
            self.diskImageCache.clearCache(for: referenceURL)
        }
    }
    
}

// MARK: - Image Caching

struct ByteCount {
    
    var value: Int
    
    public static func bytes(_ value: Int) -> ByteCount {
        return ByteCount(value: value)
    }
    
    public static func kiloBytes(_ value: Int) -> ByteCount {
        return .bytes(value * 1_000)
    }
    
    public static func megaBytes(_ value: Int) -> ByteCount {
        return .kiloBytes(value * 1_000)
    }
    
    public static func gigaBytes(_ value: Int) -> ByteCount {
        return .megaBytes(value * 1_000)
    }
}

// MARK:- ImageCache Protocol

protocol ImageCache: AnyObject {
    
    init(capacity: ByteCount)
    func image(for url: URL) -> UIImage?
    func clearCache(for url: URL)
}

// Mark:- MemoryImageCache Class

final class MemoryImageCache: ImageCache {
    
    private let cache: NSCache<NSURL, UIImage>
    
    init(capacity: ByteCount) {
        self.cache = NSCache<NSURL, UIImage>()
        self.cache.totalCostLimit = capacity.value
    }
    
    func image(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    func store(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
    
    func clearCache(for url: URL) {
        cache.removeObject(forKey: url as NSURL)
    }
    
}


// MARK:- DisImageCache Class

final class DiskImageCache: ImageCache {
    
    private let urlCache: URLCache
    
    init(capacity: ByteCount) {
        self.urlCache = URLCache(memoryCapacity: 0, diskCapacity: capacity.value, diskPath: nil) // 20MB on disk
    }
    
    func image(for url: URL) -> UIImage? {
        let urlRequest = URLRequest(url: url)
        guard let cachedResponse = urlCache.cachedResponse(for: urlRequest) else {
            return nil
        }
        return UIImage(data: cachedResponse.data)
    }
    
    func store(_ image: UIImage, data: Data, for url: URL) {
        
        let urlRequest = URLRequest(url: url)
        var headers = [String: String]()
        let numberOfDays = 1  // By default Store for 1 day
        headers["Cache-Control"] = "private, max-age=\(60 * 60 * 24 * numberOfDays)"
        guard let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headers) else { return }
        let cachedURLResponse = CachedURLResponse(response: response, data: data, userInfo: nil, storagePolicy: .allowed)
        urlCache.storeCachedResponse(cachedURLResponse, for: urlRequest)
        
    }
    
    func clearCache(for url: URL) {
        
        let urlRequest = URLRequest(url: url)
        guard let newResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Cache-Control": "max-age=0"]) else { return }
        let cachedResponse = CachedURLResponse(response: newResponse, data: Data())
        URLCache.shared.storeCachedResponse(cachedResponse, for: urlRequest)
    }
    
}



