//
//  SpotlightConfiguration.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import SwiftUI

/// Configurazione completa dello spotlight
public struct SpotlightConfiguration: Sendable {
	public var placeholder: String
	public var searchIcon: String
	public var debounceInterval: Int
	public var maxHeight: CGFloat
	public var cornerRadius: CGFloat
	public var showDividers: Bool
	public var animationDuration: Double
	public var animationResponse: Double
	public var animationDamping: Double
	
	public init(
		placeholder: String = "Search...",
		searchIcon: String = "magnifyingglass",
		debounceInterval: Int = 150,
		maxHeight: CGFloat = 300,
		cornerRadius: CGFloat = 36,
		showDividers: Bool = true,
		animationDuration: Double = 0.15,
		animationResponse: Double = 0.6,
		animationDamping: Double = 0.8
	) {
		self.placeholder = placeholder
		self.searchIcon = searchIcon
		self.debounceInterval = debounceInterval
		self.maxHeight = maxHeight
		self.cornerRadius = cornerRadius
		self.showDividers = showDividers
		self.animationDuration = animationDuration
		self.animationResponse = animationResponse
		self.animationDamping = animationDamping
	}
	
	public static let `default` = SpotlightConfiguration()
}
