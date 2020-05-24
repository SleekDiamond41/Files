//
//  Item.swift
//  Files
//
//  Created by Michael Arrington on 2/26/20.
//

public protocol IOItem {
	
	/// Returns true if the item exists, else returns false
	var exists: Bool { get }
	
	/// Deletes the item
	func delete()
}
