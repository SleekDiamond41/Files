import XCTest
@testable import Files

@available(OSX 10.11, iOS 1, *)
final class FilesTests: XCTestCase {
	
	let dir = Directory.appSupport.TestData
	let filename = "Stuff"
	var file: File { dir.file(filename, .txt) }
	
	override func tearDown() {
		super.tearDown()
		
		dir.delete()
		XCTAssertFalse(dir.exists)
		XCTAssertFalse(file.exists)
	}
    
	func testSaveData() throws {
		
		print(dir)
		
		XCTAssertFalse(dir.exists)
		XCTAssertFalse(file.exists)
		try file.append(filename.data(using: .utf8)!)
		XCTAssertTrue(dir.exists)
		XCTAssertTrue(file.exists)
		
		let contents = try file.read()
		if let s = String(data: contents, encoding: .utf8) {
			XCTAssertEqual(s, filename)
		}
    }
	
	func testBuildDirectory() {
		XCTAssertNotNil(Directory.cache)
		XCTAssertNotNil(Directory.documents)
		XCTAssertNotNil(Directory.library)
		XCTAssertTrue(Directory.appSupport.exists)
		
		// temp not yet implemented
		if #available(OSX 10.12, *) {
			XCTAssertTrue(Directory.temp.exists)
		}
	}
	
	@available(iOS 9.0, *)
	func testGetDirectoryContents() throws {
		// configure directories with contents
		
		let alpha = dir.alpha
		let bravo = alpha.bravo
		
		// write stuff so directories and files will be made
		try alpha.file("one", .txt).write("1111111111".data(using: .utf8)!)
		try alpha.file("two", .txt).write("2222222222".data(using: .utf8)!)
		try alpha.file("three", .txt).write("3333333333".data(using: .utf8)!)
		
		try bravo.file("one", .txt).write("1111111111".data(using: .utf8)!)
		try bravo.file("two", .txt).write("2222222222".data(using: .utf8)!)
		
		// make assertions
		XCTAssertEqual(alpha.files.count, 3)
		XCTAssertEqual(bravo.files.count, 2)
		
		XCTAssertEqual(alpha.directories.count, 1)
		XCTAssertEqual(bravo.directories.count, 0)
		
		XCTAssertEqual(alpha.files[0].size, 10)
		
		// clean up
		alpha.delete()
	}
	
	func testDeletingFile() throws {
		let file = dir.file("testDeletingFile", .txt)
		
		// create the file
		try file.write("1234567890".data(using: .utf8)!)
		XCTAssertTrue(file.exists)
		
		// get rid of the file
		file.delete()
		XCTAssertFalse(file.exists)
	}
	
	func test_deleting_file_thatDoesntExist() {
		let file = dir.file("test_deleting_file_thatDoesntExist", .txt)
		
		// this test would currently crash if there's a problem
		file.delete()
	}
	
	func test_deleting_directory_thatDoesntExist() {
		
		let dir = self.dir.appending("test_deleting_directory_thatDoesntExist")
		
		// this test would currently crash if there's a problem
		dir.delete()
	}
	
	func testReadFileThatExists() throws {
		let message = "Hello, World"
		let data = message.data(using: .utf8)!
		
		try file.write(data)
		
		let resultData = try file.read()
		
		guard let resultString = String(data: resultData, encoding: .utf8) else {
			XCTFail()
			return
		}
		
		XCTAssertEqual(message, resultString)
	}
	
	func testReadFileThatDoesntExist() {
		
		XCTAssertThrowsError(try file.read())
		
		do {
			_ = try file.read()
		} catch ReadError.noSuchFile {
			// this is expected
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
}
