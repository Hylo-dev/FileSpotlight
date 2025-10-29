//
//  SpotlightState.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 29/10/25.
//

/// Stati dello spotlight
public enum SpotlightState: Sendable {
	case idle
	case searching
	case showingResults
	case showingSections
	case focusSection
}
