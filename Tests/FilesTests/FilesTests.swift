import XCTest
@testable import Files

final class FilesTests: XCTestCase {
	
	let dir = Directory.appSupport.TestData
	let filename = "Stuff"
	var file: File { dir.file(filename, ext: "txt") }
	
	override func tearDown() {
		super.tearDown()
		
		dir.delete()
		XCTAssertFalse(dir.exists)
		XCTAssertFalse(file.exists)
	}
    
	func testSaveData() {
		
		print(dir)
		
		do {
			XCTAssertFalse(dir.exists)
			XCTAssertFalse(file.exists)
			try file.append(filename.data(using: .utf8)!)
			XCTAssertTrue(dir.exists)
			XCTAssertTrue(file.exists)
			
			let contents = try file.read()
			if let s = String(data: contents, encoding: .utf8) {
				XCTAssertEqual(s, filename)
			}
			
		} catch {
			XCTFail(String(reflecting: error))
		}
    }
	
	func testBuildDirectory() {
		XCTAssertNotNil(Directory.cache)
		XCTAssertNotNil(Directory.documents)
		XCTAssertNotNil(Directory.library)
		XCTAssertTrue(Directory.appSupport.exists)
		
		// temp not yet implemented
//		XCTAssertTrue(Directory.temp.exists)
	}
	
	@available(iOS 9.0, *)
	func testGetDirectoryContents() {
		// configure directories with contents
		let root = Directory.appSupport
		
		print(root)
		
		let alpha = root.alpha
		let bravo = alpha.bravo
		
		do {
			// write stuff so directories and files will be made
			try alpha.file("one", ext: "txt").write("1111111111".data(using: .utf8)!)
			try alpha.file("two", ext: "txt").write("2222222222".data(using: .utf8)!)
			try alpha.file("three", ext: "txt").write("3333333333".data(using: .utf8)!)
			
			try bravo.file("one", ext: "txt").write("1111111111".data(using: .utf8)!)
			try bravo.file("two", ext: "txt").write("2222222222".data(using: .utf8)!)
			
			// make assertions
			XCTAssertEqual(alpha.files.count, 3)
			XCTAssertEqual(bravo.files.count, 2)
			
			XCTAssertEqual(alpha.directories.count, 1)
			XCTAssertEqual(bravo.directories.count, 0)
			
			XCTAssertEqual(alpha.files[0].size, 10)
			
		} catch {
			// failures here fall outside the scope of this test,
			// and should be comvered elsewhere
			XCTFail(String(describing: error))
		}
		
		// clean up
		alpha.delete()
	}
}
