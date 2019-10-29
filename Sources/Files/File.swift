//
//  File.swift
//  Files
//
//  Created by Michael Arrington on 10/28/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation

public struct File {
	let manager = FileManager.local
	let dir: Directory
	let name: String
	let ext: String
	
	var path: String {
		return dir.url.appendingPathComponent(name).appendingPathExtension(ext).absoluteString
	}
	
	public var exists: Bool {
		var isDir = ObjCBool(false)
		return manager.fileExists(atPath: path, isDirectory: &isDir) && !isDir.boolValue
	}
	
	init(dir: Directory, name: String, ext: String) {
		self.dir = dir
		self.name = name
		self.ext = ext
	}
	
	public enum FileError: Error {
		case noDirectory
		case unknown
		case noSuchFile
	}
	
	func createDir() throws {
		do {
			try manager.createDirectory(atPath: dir.url.absoluteString, withIntermediateDirectories: true, attributes: nil)
		} catch is URLError {
			throw FileError.noDirectory
		} catch {
			throw FileError.unknown
		}
	}
	
	public func write(_ data: Data) throws {
		if !dir.exists {
			try createDir()
		}
		
		if manager.fileExists(atPath: path) {
			try data.write(to: URL(fileURLWithPath: path))
		} else {
			manager.createFile(atPath: path, contents: data, attributes: nil)
		}
	}
	
	public func append(_ data: Data) throws {
		
		do {
			var existing = try read()
			existing.append(data)
			try write(existing)
			
		} catch let error as FileError {
			switch error {
			case .noSuchFile:
				try write(data)
			default:
				preconditionFailure("UNEXPECTED ERROR WAS THROWN")
			}
		}
	}
	
	public func delete() {
		guard exists else {
			return
		}
		
		do {
			try manager.removeItem(atPath: path)
		} catch {
			preconditionFailure(String(reflecting: error))
		}
	}
	
	public func read() throws -> Data {
		// TODO: throw error if file does not exist
		guard exists else {
			throw FileError.noSuchFile
		}
		
		return try Data(contentsOf: URL(fileURLWithPath: path, isDirectory: false))
	}
}
