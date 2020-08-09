//
//  FileExtension.swift
//  Files
//
//  Created by Michael Arrington on 8/9/20.
//

import Foundation

public struct FileExtension: Equatable {
	let text: String
	
	init(_ text: String) {
		self.text = text
	}
}

extension FileExtension {
	
	public static let txt = FileExtension("txt")
	public static let json = FileExtension("json")
	public static let sqlite = FileExtension("sqlite")
	
	
	public static func custom(_ text: String) -> FileExtension {
		return FileExtension(text)
	}
}
