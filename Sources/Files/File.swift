//
//  File.swift
//  Files
//
//  Created by Michael Arrington on 10/28/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


// TODO: log errors that may be thrown
public protocol File: IOItem, CustomStringConvertible {
	
	@inlinable var size: UInt64 { get }
	
	/// Writes the data to the file. If the file exists, it will be overwritten. If it does not exist, it will be created, along with any necessary directories.
	/// - Parameter data: the Data to be written
	@inlinable func write(_ data: Data) throws
	
	/// Appends data to the end of a file. If the file does not exist, it will be created and written to.
	/// - Parameter data: the Data to be appended
	@inlinable func append(_ data: Data) throws
	
	/// Retreives all content from the file.
	@inlinable func read() throws -> Data
}

extension File {
	
	@inlinable
	public var description: String { url.absoluteString }
}


public enum ReadError: Error {
	case unknown(Error)
	case noSuchFile
}

public enum WriteError: Error {
	case generic(underlying: Error)
}


internal struct _File: File {
	let dir: Directory
	public let url: URL
	
	
	public var exists: Bool {
		var isDir = ObjCBool(true)
		
		if (FileManager.local.fileExists(atPath: url.path, isDirectory: &isDir)) {
			return !isDir.boolValue
		}
		return false
	}
	
	init(dir: Directory, url: URL) {
		self.dir = dir
		self.url = url
	}
	
	/// The size of this File in Bytes
	var size: UInt64 {
		do {
			let attributes = try FileManager.local.attributesOfItem(atPath: url.path)
			return attributes[.size] as? UInt64 ?? 0
		} catch {
			return 0
		}
	}
	
	func write(_ data: Data) throws {
		
		do {
			try data.write(to: url)
			
		} catch let error as NSError {
			guard error.code == NSFileNoSuchFileError else {
				// unknown error
				throw error
			}
			
			// directory didn't exist. Create it and try writing again
			try dir.create()
			try data.write(to: url)
		}
	}
	
	func append(_ data: Data) throws {
		
		do {
			let handle = try FileHandle(forUpdating: url)
			handle.seekToEndOfFile()
			handle.write(data)
			handle.closeFile()
			
		} catch let error as NSError {
			guard error.code == NSFileNoSuchFileError else {
				// can't recover from other stuff
				throw error
			}
			// potentially can recover by just writing instead of appending
			try write(data)
		}
	}
	
	func read() throws -> Data {
		
		do {
			return try Data(contentsOf: url)
			
		} catch let error as NSError {
			if error.code == NSFileReadNoSuchFileError {
				throw ReadError.noSuchFile
			}
			
			throw ReadError.unknown(error)
		}
	}
}
