//
//  TextField+Extension.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 03/11/25.
//

import SwiftUI

extension TextField {
	/// Applied the modifier, if the condition is true
	@ViewBuilder
	func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
		if condition { transform(self) } else { self }
	}
}
