//
//  File.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import Foundation

/// Provider per le icone degli item
public enum SpotlightIconProvider: Sendable {
	case systemImage(String)
	case url(URL)
}
