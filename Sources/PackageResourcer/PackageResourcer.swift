import Foundation

typealias DownloadResult = Result<(Data, HTTPURLResponse), Error>

protocol PackageResourcerDelegate: AnyObject {
    func finishedResourcing(_ resourcer: PackageResourcer)
    func packageResourcer(_ resourcer: PackageResourcer, finishedResourcingWithErrors: [String: Error])
}

class PackageResourcer {
    
    enum ResourcerError: Error {
        case dataTaskError(Error, URLResponse?)
        case noData(URLResponse?)
        case alreadyExists(String)
        case saveFailed(String, Error)
        
        var localizedDescription: String {
            switch self {
            case .dataTaskError(let error, _):
                return error.localizedDescription
            case .noData:
                return "No Data in response"
            case .alreadyExists:
                return "Not an error"
            case .saveFailed(let name, _):
                return "Couldn't save \(name)"
            }
        }
        
        var id: String? {
            switch self {
            case .saveFailed(let name, _):
                return name
            default:
                return nil
            }
        }
    }
    
    let assetURLs: [String: URL]
    
    var errors: [String: Error] = [:]
    
    private let fileManager: FileManager
    
    var bundleURL: URL {
        return bundle.bundleURL
    }
    
    public let bundle: Bundle
    
    var delegate: PackageResourcerDelegate?
    
    var downloadResults: [DownloadResult] = [] {
        didSet {
            guard downloadResults.count == assetURLs.count else {
                return
            }
            
        }
    }
    
    public init(urls: [String: URL]) throws {
        self.assetURLs = urls
        let fileManager = FileManager()
        self.fileManager = fileManager
        self.bundle = try fileManager.createBundle()
    }
    
    public func process() {
        assetURLs
            .forEach({ (key, url) in
                guard !resourceExists(with: key) else {
                    downloadResults
                        .append(.failure(ResourcerError.alreadyExists(key)))
                    return
                }
                getAsset(url) {[weak self] (result) in
                    self?.downloadResults.append(result)
                }
        })
        
    }
    
    public func reprocess() {
        // TODO: implement
    }
    
    func resourceExists(with name: String) -> Bool {
        do {
            return try bundleURL
                .appendingPathComponent(name)
                .checkResourceIsReachable()
        } catch {
            return false
        }
    }
    
    func getAsset(_ url: URL, completion: @escaping (DownloadResult) -> Void) {
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                let httpResponse = response as? HTTPURLResponse else {
                    var resourcerError = ResourcerError.noData(response)
                    if let error = error {
                        resourcerError = .dataTaskError(error, response)
                    }
                    completion(.failure(resourcerError))
                    return
            }
            
            completion(.success((data, httpResponse)))
        }
        
        task.resume()
    }
    
    func processDownloads(_ downloads: [DownloadResult]) {
        var errors: [Error] = []
        downloads
        .compactMap { (result) -> (Data, HTTPURLResponse)? in
            switch result {
            case .failure(let error):
                errors.append(error)
                return nil
            case .success(let data):
                return data
            }
        }
        .forEach({ (data, response) in
            let fileName = assetURLs.filter({ $0.value == response.url }).first!.key
            do {
                let url = bundleURL.appendingPathComponent(fileName)
                try data.write(to: url)
            } catch {
                errors.append(error)
            }
        })
        
        errors
            .forEach { (error) in
                guard let (name, error) = idError(error) else {
                    return
                }
                self.errors[name] = error
        }
    }
    
    private func idError(_ error: Error) -> (String, Error)? {
        if case ResourcerError.alreadyExists = error {
            return nil
        }
        return (UUID().uuidString,error)
    }
    
}

extension FileManager {
    enum BundleError: Error {
        case rootPathNotFound
        case bundleError
        
        var localizedDescription: String {
            switch self {
            case .rootPathNotFound:
                return "Root Path Not Found"
            case .bundleError:
                return "Couldn't create Bundle"
            }
        }
    }
    
    func createBundle() throws -> Bundle {
        guard let rootURL = urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            throw BundleError.rootPathNotFound
        }
        let bundleURL = rootURL.appendingPathComponent("Resources.bundle")
        try createDirectory(at: bundleURL, withIntermediateDirectories: true)
        
        guard let bundle = Bundle(url: bundleURL) else {
            throw BundleError.bundleError
        }
        
        return bundle
    }
}
