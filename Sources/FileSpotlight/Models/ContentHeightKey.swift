//
//  ContentHeightKey.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 29/10/25.
//

import SwiftUI

struct ContentHeightKey: PreferenceKey {
	static let defaultValue: CGFloat = 0
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = max(value, nextValue())
	}
}
