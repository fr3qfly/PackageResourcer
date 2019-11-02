import XCTest
@testable import PackageResourcer

final class PackageResourcerTests: XCTestCase {
    
    var resourcer: PackageResourcer!
    var bundle: Bundle!
    
    var exp: XCTestExpectation!
    
    var filesCreated: [String] = []
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        let manager = FileManager()
        
        filesCreated.forEach { (fileName) in
            try? deleteFile(fileName, with: manager)
        }
    }
    
    private func deleteFile(_ name: String, with manager: FileManager = FileManager()) throws {
        let url = bundle
            .bundleURL
            .appendingPathComponent(name)
        
        try manager.removeItem(at: url)
    }
    
    func testAssetDownload() {
        do {
            let url: URL! = Mocks.assetURLs.first?.value
            exp = expectation(description: "N/A")
            var results: [Data] = []
            resourcer = try PackageResourcer(urls: [:])
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
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testResourceExists() {
        do {
            let randomData = UUID().uuidString.data(using: .utf8)
            let resourceName = "text.txt"
            let resourcer = try PackageResourcer(urls: [:])
            XCTAssertFalse(resourcer.resourceExists(with: resourceName))
            self.bundle = resourcer.bundle
            let url = bundle
                .bundleURL
                .appendingPathComponent(resourceName)
            try randomData!.write(to: url)
            filesCreated.append(resourceName)
            XCTAssertTrue(resourcer.resourceExists(with: resourceName))
            try deleteFile(resourceName)
            XCTAssertFalse(resourcer.resourceExists(with: resourceName))
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
