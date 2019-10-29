//
//  Directory.swift
//  Files
//
//  Created by Michael Arrington on 10/28/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation

@dynamicMemberLookup
public struct Directory: Equatable, CustomStringConvertible {
	
	// MARK: - Properties
	
	public let url: URL
	
	
	// MARK: - Computed Properties
	
	public var description: String {
		return url.description
	}
	
	public var exists: Bool {
		var isDir = ObjCBool(false)
		return FileManager.local.fileExists(atPath: url.absoluteString, isDirectory: &isDir) && isDir.boolValue
	}
	
	// MARK: - Initializers
	
	init(url: URL) {
		self.url = url
	}
	
	
	// MARK: - Methods
	
	public subscript(dynamicMember name: String) -> Directory {
		return appending(name)
	}
	
	func appending(_ dir: String) -> Directory {
		return Directory(url: url.appendingPathComponent(dir))
	}
	
	public func file(named name: String, ext: String) -> File {
		return File(dir: self, name: name, ext: ext)
	}
}

// MARK: - Default Directories
extension Directory {
	
	public static var library: Directory? {
		guard let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
			return nil
		}
		
		return Directory(url: url)
	}
	
	public static var documents: Directory? {
		guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			return nil
		}
		
		return Directory(url: url)
	}
	
	public static var appSupport: Directory {
		guard let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
			preconditionFailure("application support directory should always be available... :/")
		}
		
		return Directory(url: url)
	}
	
	public static var temp: Directory {
		preconditionFailure("temp directory is not yet implemented")
		// TODO: return a default directory pointing to the tmp folder
	}
	
	public static var cache: Directory? {
		guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
			return nil
		}
		
		return Directory(url: url)
	}
}
