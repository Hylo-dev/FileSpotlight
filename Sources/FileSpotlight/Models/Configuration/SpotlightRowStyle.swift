//
//  SpotlightRowStyle.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import SwiftUI

/// Stile personalizzabile per le row
public struct SpotlightRowStyle: Sendable {
	public var backgroundColor: @Sendable (Bool) -> Color
	public var textColor: Color
	public var subtitleColor: Color
	public var cornerRadius: CGFloat
	public var padding: EdgeInsets
	public var spacing: CGFloat
	public var iconSize: CGFloat
	
	public init(
		backgroundColor: @escaping @Sendable (Bool) -> Color = { selected in
			selected ? Color.accentColor.opacity(0.15) : Color.clear
		},
		textColor: Color = .primary,
		subtitleColor: Color = .secondary,
		cornerRadius: CGFloat = 8,
		padding: EdgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10),
		spacing: CGFloat = 12,
		iconSize: CGFloat = 26
	) {
		self.backgroundColor = backgroundColor
		self.textColor = textColor
		self.subtitleColor = subtitleColor
		self.cornerRadius = cornerRadius
		self.padding = padding
		self.spacing = spacing
		self.iconSize = iconSize
	}
	
	public static let `default` = SpotlightRowStyle()
}
