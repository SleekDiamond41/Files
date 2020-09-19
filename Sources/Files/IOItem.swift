//
//  Item.swift
//  Files
//
//  Created by Michael Arrington on 2/26/20.
//

import Foundation

public protocol IOItem {
	
	/// The URL of this item
	@inlinable var url: URL { get }
	
	/// Returns true if the item exists, else returns false
	@inlinable var exists: Bool { get }
}

extension IOItem {
	
	public func delete() {
		guard exists else {
			return
		}
		
		do {
			try FileManager.local.removeItem(at: url)
		} catch let error as NSError {
			
			if error.code == NSFileReadNoSuchFileError {
				// file already doesn't exist, our work is done
				return
			}
			
			// TODO: throw a useful error
			// or at least don't fail
			preconditionFailure(String(reflecting: error))
		}
	}
}
