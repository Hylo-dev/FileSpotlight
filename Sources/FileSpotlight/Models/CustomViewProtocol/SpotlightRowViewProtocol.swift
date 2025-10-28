//
//  SpotlightRowViewProtocol.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import SwiftUI

/// Protocollo per custom row views
public protocol SpotlightRowViewProtocol: View {
	associatedtype Item: SpotlightItem
	
	init(
		item: Item,
		isSelected: Bool,
		style: SpotlightRowStyle,
		onTap: @escaping () -> Void
	)
}
