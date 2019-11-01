import XCTest
@testable import PackageResourcer

final class PackageResourcerTests: XCTestCase {
    
    var resourcer: PackageResourcer!
    
    let fileManager = FileManager()
    
    var searchPath: FileManager.SearchPathDirectory!
    
    var pathUrl: URL! {
        return fileManager.urls(for: searchPath, in: .userDomainMask).first
    }
    
    var exp: XCTestExpectation!
    
    var filesCreated: [String] = []
    
    override func setUp() {
        super.setUp()
        searchPath = .downloadsDirectory
    }
    
    override func tearDown() {
        super.tearDown()
        let manager = FileManager()
        
        filesCreated.forEach { (fileName) in
            let url = pathUrl.appendingPathComponent(fileName)
            
            try? manager.removeItem(at: url)
        }
    }
    
    func testAssetDownload() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let url: URL! = Mocks.assetURLs.first?.value
        exp = expectation(description: "N/A")
        var results: [Data] = []
        resourcer = PackageResourcer(urls: [:])
        resourcer.getAsset(url) { (result) in
            switch result {
            case .success(let data):
                results.append(data.0)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            self.exp.fulfill()
        }
        wait(for: [exp], timeout: 30)
        XCTAssertEqual(results.count, 1)
    }
    
    func testResourceExists() {
        do {
            let randomData = UUID().uuidString.data(using: .utf8)
            let resourceName = "text.txt"
            let resourcer = PackageResourcer(urls: [:])
            XCTAssertFalse(resourcer.resourceExists(with: resourceName))
            let url = pathUrl.appendingPathComponent(resourceName)
            try randomData!.write(to: url)
            filesCreated.append(resourceName)
            XCTAssertTrue(resourcer.resourceExists(with: resourceName))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests = [
        ("testAssetDownload", testAssetDownload),
        ("testResourceExists", testResourceExists),
    ]
}

extension PackageResourcerTests: PackageResourcerDelegate {
    func finishedResourcing(_ resourcer: PackageResourcer) {
        exp.fulfill()
    }
    
    func packageResourcer(_ resourcer: PackageResourcer, finishedResourcingWithErrors: [String : Error]) {
        exp.fulfill()
    }
    
    
}
