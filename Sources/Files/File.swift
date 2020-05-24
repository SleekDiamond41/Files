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
	
	var url: URL { get }
	
	var size: UInt64 { get }
	
	/// Writes the data to the file. If the file exists, it will be overwritten. If it does not exist, it will be created, along with any necessary directories.
	/// - Parameter data: the Data to be written
	func write(_ data: Data) throws
	
	/// Appends data to the end of a file. If the file does not exist, it will be created and written to.
	/// - Parameter data: the Data to be appended
	func append(_ data: Data) throws
	
	/// Retreives all content from the file.
	func read() throws -> Data
}

extension File {
	public var description: String { url.absoluteString }
}

public struct _File: File {
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
	
	public enum FileError: Error {
		case noDirectory
		case unknown
		case noSuchFile
	}
	
	public enum WriteError: Error {
		case generic(underlying: Error)
	}
	
	/// The size of this File in Bytes
	public var size: UInt64 {
		do {
			let attributes = try FileManager.local.attributesOfItem(atPath: url.path)
			return attributes[.size] as? UInt64 ?? 0
		} catch {
			return 0
		}
	}
	
	public func write(_ data: Data) throws {
		
		if !dir.exists {
			do {
				try dir.create()
			} catch {
				// TODO: throw better errors
				throw WriteError.generic(underlying: error)
			}
		}
		
		if exists {
			do {
				try data.write(to: url)
			} catch {
				// TODO: throw better errors
				throw WriteError.generic(underlying: error)
			}
		} else {
			FileManager.local.createFile(atPath: url.path, contents: data, attributes: nil)
		}
	}
	
	public func append(_ data: Data) throws {
		
		do {
			let handle = try FileHandle(forUpdating: url)
			handle.seekToEndOfFile()
			handle.write(data)
			handle.closeFile()
			
		} catch let error as FileError {
			switch error {
			case .noSuchFile:
				try write(data)
			default:
				preconditionFailure("UNEXPECTED ERROR WAS THROWN")
			}
		} catch let error as NSError {
			guard error.code == NSFileNoSuchFileError else {
				// can't recover from other stuff
				throw error
			}
			// potentially can recover by just writing instead of appending
			try write(data)
		}
	}
	
	public func delete() {
		guard exists else {
			return
		}
		
		do {
			try FileManager.local.removeItem(atPath: url.absoluteString)
		} catch {
			// TODO: throw a useful error
				// or at least don't fail
			preconditionFailure(String(reflecting: error))
		}
	}
	
	public func read() throws -> Data {
		// TODO: throw error if file does not exist
		guard exists else {
			throw FileError.noSuchFile
		}
		
		return try Data(contentsOf: url)
	}
}
