//
//  File.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import Foundation

/// Defines the source for a spotlight item's icon.
///
/// This enumeration provides different ways to specify an icon, such as using a system symbol name
/// or deriving it from a file URL. It conforms to `Sendable` to ensure it can be safely
/// used in concurrent contexts.
public enum SpotlightIconProvider: Sendable {
	/// An icon represented by a system image name, typically from the SF Symbols collection.
	/// The associated value is the `String` name of the symbol (e.g., "folder").
	case systemImage(String)
	
	/// An icon derived from a file URL. The system will typically resolve this to the default
	/// icon associated with the file type or a Quick Look thumbnail.
	case url(URL)
}
