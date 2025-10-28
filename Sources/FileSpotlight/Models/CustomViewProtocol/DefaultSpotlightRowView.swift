//
//  DefaultSpotlightRowView.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import SwiftUI

/// Default row implementation
public struct DefaultSpotlightRowView<Item: SpotlightItem>: SpotlightRowViewProtocol {
	let item: Item
	let isSelected: Bool
	let style: SpotlightRowStyle
	let onTap: () -> Void
	
	public init(
		item: Item,
		isSelected: Bool,
		style: SpotlightRowStyle,
		onTap: @escaping () -> Void
	) {
		self.item = item
		self.isSelected = isSelected
		self.style = style
		self.onTap = onTap
	}
	
	public var body: some View {
		HStack(alignment: .center, spacing: style.spacing) {
			iconView
			
			VStack(alignment: .leading, spacing: 4) {
				Text(item.displayName)
					.font(.headline)
					.foregroundColor(style.textColor)
				
				if let subtitle = item.subtitle {
					Text(subtitle)
						.font(.caption)
						.foregroundColor(style.subtitleColor)
				}
			}
			
			Spacer()
		}
		.padding(style.padding)
		.background(style.backgroundColor(isSelected))
		.cornerRadius(style.cornerRadius)
		.onTapGesture(perform: onTap)
	}
	
	@ViewBuilder
	private var iconView: some View {
		switch item.iconProvider {
		case .systemImage(let name):
			Image(systemName: name)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: style.iconSize, height: style.iconSize)
				
		case .url(let url):
			Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: style.iconSize, height: style.iconSize)
		}
	}
}
