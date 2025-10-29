//
//  SpotlightState.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 29/10/25.
//

/// Defines the possible states of the spotlight view.
public enum SpotlightState: Sendable {
	/// The spotlight is inactive and waiting for user input.
	case idle
	
	/// The spotlight is actively performing a search operation.
	case searching
	
	/// The spotlight has finished searching and is displaying the results.
	case showingResults
	
	/// The spotlight is displaying the available search sections or categories.
	case showingSections
	
	/// The spotlight is focused on a specific section, displaying its custom content.
	case focusSection
}
