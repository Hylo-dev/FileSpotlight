//
//  FileSearchView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/08/25.
//

import SwiftUI

/// Vista principale dello Spotlight generica con Glass Effect
public struct SpotlightView<Item: SpotlightItem>: View {
	
	@ObservedObject private var viewModel: SpotlightViewModel<Item>
	
	private let width: CGFloat
	
	public init(
		viewModel: SpotlightViewModel<Item>,
		width: CGFloat = 600
	) {
		self.viewModel = viewModel
		self.width = width
	}
	
	public var body: some View {
		VStack(spacing: 0) {
			searchBar
				.padding()
			
			if viewModel.state == .showingResults {
				if viewModel.configuration.showDividers {
					Divider()
				}
				
				resultsView
			}
		}
		.frame(width: width)
		.glassEffect(.clear, in: .rect(cornerRadius: viewModel.configuration.cornerRadius))
		.onKeyPress { keyPress in
			viewModel.handleKeyPress(keyPress)
		}
	}
	
	// MARK: - Search Bar
	
	private var searchBar: some View {
		let item  = viewModel.sections[viewModel.selectedSection]
		let icon  = item.icon ?? "gearshape"
		let title = item.title ?? "nil"
		
		return HStack(spacing: 12) {
			Image(systemName: icon)
				.foregroundColor(.secondary)
				.font(.title2)
			
			TextField(
				title,
				text: $viewModel.searchText
			)
			.textFieldStyle(.plain)
			.font(.title2)
			.onSubmit {
				viewModel.selectCurrent()
			}
			
			Button(action: { viewModel.reset() }) {
				Image(systemName: "xmark.circle.fill")
					.foregroundColor(.secondary)
			}
			.buttonStyle(.plain)
		}
	}
	
	// MARK: - Results View
	
	private var resultsView: some View {
		ScrollViewReader { proxy in
			ScrollView {
				LazyVStack(spacing: 8) {
					ForEach(viewModel.searchResults.indices, id: \.self) { index in
						let item = viewModel.searchResults[index]
						let isSelected = index == viewModel.selectedIndex
						
						DefaultSpotlightRowView(
							item: item,
							isSelected: isSelected,
							style: viewModel.rowStyle,
							onTap: {
								viewModel.selectedIndex = index
								viewModel.selectCurrent()
							}
						)
						.id(index)
					}
				}
				.padding()
				.background(
					GeometryReader { geo in
						Color.clear.preference(
							key: ContentHeightKey.self,
							value: geo.size.height
						)
					}
				)
			}
			.frame(maxHeight: viewModel.configuration.maxHeight)
			.onChange(of: viewModel.selectedIndex) { _, newIndex in
				withAnimation(.easeInOut(duration: 0.3)) {
					proxy.scrollTo(newIndex, anchor: .center)
				}
			}
		}
		.transition(
			.asymmetric(
				insertion: .scale(scale: 0.95, anchor: .top)
					.combined(with: .opacity),
				removal: .scale(scale: 0.95, anchor: .top)
					.combined(with: .opacity)
			)
		)
	}
}

// MARK: - Custom Row View Spotlight

public struct CustomSpotlightView<Item: SpotlightItem, RowView: SpotlightRowViewProtocol>: View where RowView.Item == Item {
	
	@ObservedObject private var viewModel: SpotlightViewModel<Item>
	
	private let width: CGFloat
	private let rowViewType: RowView.Type
	
	public init(
		viewModel: SpotlightViewModel<Item>,
		width: CGFloat = 600,
		rowView: RowView.Type
	) {
		self.viewModel = viewModel
		self.width = width
		self.rowViewType = rowView
	}
	
	public var body: some View {
		VStack(spacing: 0) {
			searchBar
				.padding()
			
			if viewModel.state == .showingResults {
				if viewModel.configuration.showDividers {
					Divider()
				}
				
				resultsView
			}
		}
		.frame(width: width)
		.glassEffect(.clear, in: .rect(cornerRadius: viewModel.configuration.cornerRadius))
		.onKeyPress { keyPress in
			viewModel.handleKeyPress(keyPress)
		}
	}
	
	private var searchBar: some View {
		let item  = viewModel.sections[viewModel.selectedSection]
		let icon  = item.icon ?? "gearshape"
		let title = item.title ?? "nil"
		
		return HStack(spacing: 12) {
			Image(systemName: icon)
				.foregroundColor(.secondary)
				.font(.title2)
			
			TextField(
				title,
				text: $viewModel.searchText
			)
			.textFieldStyle(.plain)
			.font(.title2)
			.onSubmit {
				viewModel.selectCurrent()
			}
			
			if viewModel.isLoading {
				ProgressView()
					.scaleEffect(0.7)
			} else if !viewModel.searchText.isEmpty {
				Button(action: { viewModel.reset() }) {
					Image(systemName: "xmark.circle.fill")
						.foregroundColor(.secondary)
				}
				.buttonStyle(.plain)
			}
		}
	}
	
	private var resultsView: some View {
		ScrollViewReader { proxy in
			ScrollView {
				LazyVStack(spacing: 8) {
					ForEach(viewModel.searchResults.indices, id: \.self) { index in
						let item = viewModel.searchResults[index]
						let isSelected = index == viewModel.selectedIndex
						
						rowViewType.init(
							item: item,
							isSelected: isSelected,
							style: viewModel.rowStyle,
							onTap: {
								viewModel.selectedIndex = index
								viewModel.selectCurrent()
							}
						)
						.id(index)
					}
				}
				.padding()
				.background(
					GeometryReader { geo in
						Color.clear.preference(
							key: ContentHeightKey.self,
							value: geo.size.height
						)
					}
				)
			}
			.frame(maxHeight: viewModel.configuration.maxHeight)
			.onChange(of: viewModel.selectedIndex) { _, newIndex in
				withAnimation(.easeInOut(duration: 0.3)) {
					proxy.scrollTo(newIndex, anchor: .center)
				}
			}
		}
		.transition(
			.asymmetric(
				insertion: .scale(scale: 0.95, anchor: .top)
					.combined(with: .opacity),
				removal: .scale(scale: 0.95, anchor: .top)
					.combined(with: .opacity)
			)
		)
	}
}

// MARK: - Convenience View for Files

public struct FileSpotlightView: View {
	@StateObject private var viewModel: SpotlightViewModel<SpotlightFileItem>
	
	public init(
		directory: URL,
		fileExtensions: [String]? = nil,
		configuration: SpotlightConfiguration = .default,
	) {
		_viewModel = StateObject(wrappedValue: .fileSearch(
			directory: directory,
			fileExtensions: fileExtensions,
			configuration: configuration
		))
	}
	
	public var body: some View {
		SpotlightView(viewModel: viewModel)
	}
}

// MARK: - Multi-Section Spotlight View with Glass Effect

public struct MultiSectionSpotlightView<Item: SpotlightItem>: View {
	@ObservedObject private var viewModel: SpotlightViewModel<Item>
	
	private let width: CGFloat
	
	public init(viewModel: SpotlightViewModel<Item>, width: CGFloat = 600) {
		self.viewModel = viewModel
		self.width = width
	}
	
	public var body: some View {
		VStack(spacing: 0) {
			
			GlassEffectContainer {
				
				HStack {
					let textAreaWidth  = viewModel.selectedSection > 0 &&
										 viewModel.state == .idle ?
										 width - 65 : width
					
					VStack {
						searchBar
							.padding()
						
						if viewModel.state == .showingResults {
							if viewModel.configuration.showDividers {
								Divider()
							}
							
							resultsView
						}
					}
					.frame(width: textAreaWidth)
					.glassEffect(.clear, in: .rect(cornerRadius: viewModel.configuration.cornerRadius))
					.onKeyPress { keyPress in
						viewModel.handleKeyPress(keyPress)
					}
					
					if viewModel.state == .idle &&
						!viewModel.visibleSections().isEmpty &&
						viewModel.selectedSection != 0
					{
						sectionsView
					}
				}
			}
			
		}
	}
	
	private var searchBar: some View {
		HStack(spacing: 12) {
			let item = viewModel.sections[viewModel.selectedSection]
			let icon = item.icon ?? "gearshape"
			Image(systemName: icon) // viewModel.configuration.searchIcon
				.foregroundColor(.secondary)
				.font(.title2)
			
			let placeholder = item.title ?? "nil"
			TextField(
				placeholder,
				text: $viewModel.searchText
			)
			.textFieldStyle(.plain)
			.font(.title2)
			
			if viewModel.isLoading {
				ProgressView()
					.scaleEffect(0.7)
			}
		}
	}
	
	private var sectionsView: some View {
		ForEach(viewModel.visibleSections().enumerated(), id: \.element.id) { index, section in
			if index != 0 { sectionView(section, index) }
		}
		
//		ScrollView {
//			LazyVStack(alignment: .leading, spacing: 16) {
//				
//			}
//			.padding()
//		}
//		.frame(maxHeight: viewModel.configuration.maxHeight)
	}
	
	private func sectionView(_ section: SpotlightSection<Item>, _ index: Int) -> some View {
		return Button {
			
			
		} label: {
			Image(systemName: section.icon ?? "gearshape")
				.font(.system(size: 19))
				.frame(width: 55, height: 55)
				.contentShape(Circle())
			
		}
		.buttonStyle(.plain)
		.glassEffect(
			.regular.tint(
					viewModel.selectedSection == index ?
					Color.accentColor :
					Color.clear
				),
			in: .circle
		)
		.clipShape(Circle())
		.transition(.move(edge: .leading).combined(with: .opacity))
		
//		VStack(alignment: .leading, spacing: 8) {
//			if let title = section.title {
//				HStack(spacing: 8) {
//					if let icon = section.icon {
//						Image(systemName: icon)
//							.foregroundColor(.secondary)
//					}
//					
//					Text(title)
//						.font(.headline)
//						.foregroundColor(.secondary)
//				}
//				.padding(.horizontal, 4)
//			}
//			
//			ForEach(section.items()) { item in
//				DefaultSpotlightRowView(
//					item: item,
//					isSelected: false,
//					style: viewModel.rowStyle,
//					onTap: {
//						Task { @MainActor in
//							section.onSelect(item)
//						}
//					}
//				)
//			}
//		}
	}
	
	private var resultsView: some View {
		ScrollViewReader { proxy in
			ScrollView {
				LazyVStack(spacing: 8) {
					ForEach(viewModel.searchResults.indices, id: \.self) { index in
						let item = viewModel.searchResults[index]
						let isSelected = index == viewModel.selectedIndex
						
						DefaultSpotlightRowView(
							item: item,
							isSelected: isSelected,
							style: viewModel.rowStyle,
							onTap: {
								viewModel.selectedIndex = index
								viewModel.selectCurrent()
							}
						)
						.id(index)
					}
				}
				.padding()
			}
			.frame(maxHeight: viewModel.configuration.maxHeight)
			.onChange(of: viewModel.selectedIndex) { _, newIndex in
				withAnimation(.easeInOut(duration: 0.3)) {
					proxy.scrollTo(newIndex, anchor: .center)
				}
			}
		}
		.transition(
			.asymmetric(
				insertion: .scale(scale: 0.95, anchor: .top)
					.combined(with: .opacity),
				removal: .scale(scale: 0.95, anchor: .top)
					.combined(with: .opacity)
			)
		)
	}
}

// MARK: - Preference Key
struct ContentHeightKey: PreferenceKey {
	static let defaultValue: CGFloat = 0
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = max(value, nextValue())
	}
}
