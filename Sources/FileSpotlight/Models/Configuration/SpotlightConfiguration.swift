//
//  SpotlightConfiguration.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import SwiftUI

/// A structure to hold all configuration settings for a spotlight view.
///
/// This object allows for extensive customization of the spotlight's appearance, behavior, and animations.
/// It is `Sendable` to ensure it can be safely passed across concurrent contexts.
public struct SpotlightConfiguration: Sendable {
	
	// MARK: - Properties
	
	/// The default title or placeholder text displayed in the search bar.
	public var title: String
	
	/// The name of the system icon (e.g., from SF Symbols) displayed in the search bar.
	public var icon: String
	
	/// The delay in milliseconds after the user stops typing before a search is triggered. This helps prevent excessive searches.
	public var debounceInterval: Int
	
	/// The maximum height that the scrollable results list can expand to.
	public var maxHeight: CGFloat
	
	/// A boolean value that determines whether to show dividers in the UI, such as between the search bar and the results.
	public var showDividers: Bool
	
	/// The duration for standard view animations.
	public var animationDuration: Double
	
	/// The `response` parameter for spring animations, affecting how quickly the animation settles.
	public var animationResponse: Double
	
	/// The `dampingFraction` parameter for spring animations, controlling the bounciness.
	public var animationDamping: Double
	
	/// A closure that is executed when a `SpotlightFileItem` is selected. It runs on the main actor to ensure UI safety.
	public var onSelect: @MainActor (SpotlightFileItem) -> Void
	
	// MARK: - Initializer
	
	/// Creates a new spotlight configuration.
	///
	/// All parameters have default values, allowing you to create a configuration by only specifying the properties you want to change.
	///
	/// - Parameters:
	///   - title: The search bar's placeholder text. Defaults to "Search".
	///   - icon: The search bar's icon name. Defaults to "doc.text".
	///   - debounceInterval: The search debounce interval in milliseconds. Defaults to 150.
	///   - maxHeight: The maximum height for the results list. Defaults to 300.
	///   - showDividers: Whether to show UI dividers. Defaults to `true`.
	///   - animationDuration: The duration for animations. Defaults to 0.15.
	///   - animationResponse: The response for spring animations. Defaults to 0.6.
	///   - animationDamping: The damping for spring animations. Defaults to 0.8.
	///   - onSelect: The action to perform on item selection. Defaults to an empty closure.
	public init(
		title			 : String  = "Search",
		icon		 	 : String  = "doc.text",
		debounceInterval : Int	   = 150,
		maxHeight		 : CGFloat = 300,
		showDividers	 : Bool    = true,
		animationDuration: Double  = 0.15,
		animationResponse: Double  = 0.6,
		animationDamping : Double  = 0.8,
		
		onSelect		 : @escaping @MainActor (SpotlightFileItem) -> Void = { _ in }
	) {
		self.title = title
		self.icon 			   = icon
		self.debounceInterval  = debounceInterval
		self.maxHeight 		   = maxHeight
		self.showDividers	   = showDividers
		self.animationDuration = animationDuration
		self.animationResponse = animationResponse
		self.animationDamping  = animationDamping
		self.onSelect 		   = onSelect
		
	}
	
	// MARK: - Static Properties
	
	/// A shared instance of `SpotlightConfiguration` with all default values.
	public static let `default` = SpotlightConfiguration()
}
