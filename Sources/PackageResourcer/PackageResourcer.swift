import Foundation

typealias DownloadResult = Result<(Data, HTTPURLResponse), Error>

class PackageResourcer {
    
    let assetURLs: [URL]
    
    var assetCompletion: ((Result<[Data], Error>) -> Void)
    
    var downloadResults: [DownloadResult] = [] {
        didSet {
            guard downloadResults.count == assetURLs.count else {
                return
            }
            assetCompletion(mapDownloadResults(downloadResults))
        }
    }
    
    public init(urls: [URL], completion: @escaping (Result<[Data], Error>) -> Void) {
        self.assetURLs = urls
        self.assetCompletion = completion
        
        assets()
    }
    
    public func assets() {
        assetURLs.forEach { (url) in
            getAsset(url) {[weak self] (result) in
                self?.downloadResults.append(result)
            }
        }
        
    }
    
    func getAsset(_ url: URL, completion: (DownloadResult) -> Void) {
        //TODO: Implement
        
        let data = Data()
        let response = HTTPURLResponse()
        completion(.success((data, response)))
    }
    
    func mapDownloadResults(_ results: [DownloadResult]) -> Result<[Data], Error> {
        //TODO: implement
        do {
            let sorted = try results
                .map { (result) -> Data in
                    switch result {
                    case .failure(let error):
                        throw error
                    case .success((let data, _)):
                        return data
                    }
                }
                .sorted { (first, second) -> Bool in
                    first.count < second.count
                }
            return .success(sorted)
        } catch {
            return .failure(error)
        }
    }
}

public extension URL {
    static var mock: [URL] {
        return [
            "https://raw.githubusercontent.com/BalazsSzamody/Eureka/master/Source/Resources/Eureka.bundle/forward-chevron%401x.png",
            "https://raw.githubusercontent.com/BalazsSzamody/Eureka/master/Source/Resources/Eureka.bundle/forward-chevron%402x.png",
            "https://raw.githubusercontent.com/BalazsSzamody/Eureka/master/Source/Resources/Eureka.bundle/forward-chevron%403x.png",
            "https://raw.githubusercontent.com/BalazsSzamody/Eureka/master/Source/Resources/Eureka.bundle/back-chevron%401x.png",
            "https://raw.githubusercontent.com/BalazsSzamody/Eureka/master/Source/Resources/Eureka.bundle/back-chevron%402x.png",
            "https://raw.githubusercontent.com/BalazsSzamody/Eureka/master/Source/Resources/Eureka.bundle/back-chevron%403x.png",
        ]
        .compactMap({ URL(string: $0) })
    }
}
