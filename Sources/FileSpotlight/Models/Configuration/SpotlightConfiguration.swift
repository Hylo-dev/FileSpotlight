//
//  SpotlightConfiguration.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import SwiftUI

/// Configurazione completa dello spotlight
public struct SpotlightConfiguration: Sendable {
	public var title		   : String
	public var icon			   : String
	public var debounceInterval: Int
	public var maxHeight: CGFloat
	public var showDividers: Bool
	public var animationDuration: Double
	public var animationResponse: Double
	public var animationDamping: Double
	public var onSelect		   : @MainActor (SpotlightFileItem) -> Void
	
	public init(
		title			: String = "Search",
		icon			: String = "doc.text",
		debounceInterval: Int = 150,
		maxHeight: CGFloat = 300,
		showDividers: Bool = true,
		animationDuration: Double = 0.15,
		animationResponse: Double = 0.6,
		animationDamping: Double = 0.8,
		onSelect		: @escaping @MainActor (SpotlightFileItem) -> Void = { _ in }
	) {
		
		self.title			   = title
		self.icon			   = icon
		self.debounceInterval  = debounceInterval
		self.maxHeight         = maxHeight
		self.showDividers      = showDividers
		self.animationDuration = animationDuration
		self.animationResponse = animationResponse
		self.animationDamping  = animationDamping
		self.onSelect 		   = onSelect
	}
	
	public static let `default` = SpotlightConfiguration()
}
