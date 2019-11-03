import XCTest
#if canImport(UIKIt)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
@testable import PackageResourcer

final class PackageResourcerTests: XCTestCase {
    
    var resourcer: PackageResourcer!
    var bundle: Bundle!
    
    var exp: XCTestExpectation!
    
    var filesCreated: [String] = []
    
    var errors: [String: Error] = [:]
    
    override func setUp() {
        super.setUp()
        errors = [:]
    }
    
    override func tearDown() {
        super.tearDown()
        try? resourcer.clearBundle()
//        filesCreated.forEach { (fileName) in
//            try? deleteFile(fileName)
//        }
    }
    
    private func deleteFile(_ name: String) throws {
        let url = resourcer
            .bundle
            .bundleURL
            .appendingPathComponent(name)
        
        try resourcer.fileManager.removeItem(at: url)
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
            resourcer = try PackageResourcer(urls: [:])
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
    
    func testProcessAssets() {
        do {
            exp = expectation(description: "Assets Download process")
            let assetURLs = Mocks.assetURLs
            resourcer = try PackageResourcer(urls: assetURLs)
            resourcer.delegate = self
            bundle = resourcer.bundle
            
            var imageCount = availableImageCount(assetURLs)
            XCTAssertEqual(imageCount, 0)
            
            resourcer.process()
            
            waitForExpectations(timeout: 30)
            XCTAssertEqual(errors.count, 0)
            imageCount = availableImageCount(assetURLs)
            XCTAssertEqual(imageCount, 2)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    private func availableImageCount(_ imageURLs: [String: URL]) -> Int {
         let imageNames = Set(imageURLs.compactMap({ $0.key.components(separatedBy: "@").first }))
        #if canImport(UIKit)
       
        let images = imageNames
            .compactMap({
                UIImage(named: $0, in: bundle, compatibleWith: nil)
            })
        return images.count
        #else
        XCTFail("UIKit is mandatory for this test")
        return 0
        #endif
        
    }

    static var allTests = [
        ("testAssetDownload", testAssetDownload),
        ("testResourceExists", testResourceExists),
        ("testProcessAssets", testProcessAssets),
    ]
}

extension PackageResourcerTests: PackageResourcerDelegate {
    func finishedResourcing(_ resourcer: PackageResourcer) {
        exp.fulfill()
    }
    
    func packageResourcer(_ resourcer: PackageResourcer, finishedResourcingWithErrors errors: [String : Error]) {
        exp.fulfill()
        self.errors = errors
    }
}
