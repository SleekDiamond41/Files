//
//  Directory.swift
//  Files
//
//  Created by Michael Arrington on 10/28/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation

@dynamicMemberLookup
public struct Directory: IOItem, Equatable, CustomStringConvertible {
	
	internal enum IOError {
		case noSuchItem
		case unknown(NSError)
		
		init(_ error: NSError) {
			switch error.code {
			case NSFileNoSuchFileError:
				self = .noSuchItem
			default:
				self = .unknown(error)
			}
		}
	}
	
	// MARK: - Properties
	
	public let url: URL
	
	
	// MARK: - Computed Properties
	
	public var description: String {
		return url.absoluteString
	}
	
	public var exists: Bool {
		var isDir = ObjCBool(false)
		if (FileManager.local.fileExists(atPath: url.path, isDirectory: &isDir)) {
			return isDir.boolValue
		}
		return false
	}
	
	// MARK: - Initializers
	
	init(url: URL) {
		self.url = url
	}
	
	
	// MARK: - Methods
	
	public subscript(dynamicMember name: String) -> Directory {
		return appending(name)
	}
	
	public func appending(_ dir: String) -> Directory {
		return Directory(url: url.appendingPathComponent(dir))
	}
	
	func create() throws {
		try FileManager.local.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
		
	}
	
	public func file(_ name: String, _ ext: FileExtension) -> File {
		return _File(dir: self, url: url
						.appendingPathComponent(name)
						.appendingPathExtension(ext.text))
	}
	
	public func delete() {
		do {
			try FileManager.local.removeItem(atPath: url.path)
		} catch let error as NSError {
			switch IOError(error) {
			case .noSuchItem:
				// that's all good
				break
			case .unknown:
				preconditionFailure(String(reflecting: error))
			}
		}
	}
	
	@available(OSX 10.11, iOS 9.0, *)
	public var files: [File] {
		do {
			return try FileManager.local.contentsOfDirectory(at: url,
															 includingPropertiesForKeys: nil,
															 options: [])
				.filter { !$0.hasDirectoryPath }	// don't include directories
				.map { _File(dir: self, url: $0) }
		} catch {
			preconditionFailure("currently no handling for: \(String(describing: error))")
		}
	}
	
	@available(OSX 10.11, iOS 9.0, *)
	public var directories: [Directory] {
		do {
			return try FileManager.local.contentsOfDirectory(at: url,
															 includingPropertiesForKeys: nil,
															 options: [])
				.filter { $0.hasDirectoryPath }	// don't include directories
				.map { Directory(url: $0) }
		} catch {
			preconditionFailure("currently no handling for: \(String(describing: error))")
		}
	}
}

// MARK: - Default Directories
extension Directory {
	
	public static var library: Directory? {
		guard let url = FileManager.local.urls(for: .libraryDirectory, in: .userDomainMask).first else {
			return nil
		}
		
		return Directory(url: url)
	}
	
	public static var documents: Directory? {
		guard let url = FileManager.local.urls(for: .documentDirectory, in: .userDomainMask).first else {
			return nil
		}
		
		return Directory(url: url)
	}
	
	public static var appSupport: Directory {
		guard let url = FileManager.local.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
			preconditionFailure("application support directory should always be available... :/")
		}
		
		return Directory(url: url)
	}
	
	@available(OSX 10.12, iOS 10.0, watchOS 3.0, *)
	public static var temp: Directory {
		
		return Directory(url: FileManager.local.temporaryDirectory)
	}
	
	public static var cache: Directory? {
		guard let url = FileManager.local.urls(for: .cachesDirectory, in: .userDomainMask).first else {
			return nil
		}
		
		return Directory(url: url)
	}
}

// can't Trash things on the 🍎 Watch apparently
@available(watchOS, introduced: 1.0, unavailable)
@available(OSX 10.12, iOS 11.0, *)
extension Directory {
	
	/// Moves the item to the trash. Crashes if unsuccessful. (I should probably change that at some point)
	///
	/// - Note: Only available in OSX 10+
	/// - Returns: the new URL of the item in the trash
	@discardableResult
	public func moveToTrash() -> URL {
		var url: NSURL?
		
		do {
			try FileManager.local.trashItem(at: self.url, resultingItemURL: &url)
			
			return (url ?? NSURL()) as URL
		} catch {
			preconditionFailure(String(reflecting: error))
		}
	}
}
