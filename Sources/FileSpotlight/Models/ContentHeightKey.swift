//
//  ContentHeightKey.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 29/10/25.
//

import SwiftUI

/// A `PreferenceKey` used to measure and communicate the height of a view's content up the view hierarchy.
///
/// This key is particularly useful for determining the dynamic height of content within a container like a `ScrollView`.
/// A child view can use `GeometryReader` to measure its size and set this preference. A parent view can then
/// listen for changes to this preference using the `.onPreferenceChange()` modifier to react accordingly,
/// such as adjusting its own layout.
struct ContentHeightKey: PreferenceKey {
	/// The default value for the height, used when no view sets a value for this key.
	static let defaultValue: CGFloat = 0

	/// A function that combines values from multiple child views.
	///
	/// It uses `max` to ensure that the final value reported is the largest height found among all contributing views.
	/// This is effective for finding the total height of vertically stacked content.
	/// - Parameters:
	///   - value: The current accumulated height.
	///   - nextValue: The height from the next child view being considered.
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = max(value, nextValue())
	}
}
