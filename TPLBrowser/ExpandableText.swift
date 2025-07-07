
//
//  ExpandableText.swift
//  TPLBrowser
//
//  Created by Gemini on 2025-07-07.
//
//  This file defines a custom SwiftUI view that allows text to be truncated
//  and expanded with a "Read More" button.

import SwiftUI

// Custom ViewModifier to measure the height of a view
private struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private extension View {
    func measureHeight(completion: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear.preference(key: ViewHeightKey.self, value: geometry.size.height)
            }
        )
        .onPreferenceChange(ViewHeightKey.self) { height in
            completion(height)
        }
    }
}

struct ExpandableText: View {
    @State private var expanded: Bool = false
    @State private var truncated: Bool = false
    @State private var fullTextHeight: CGFloat = 0
    @State private var limitedTextHeight: CGFloat = 0

    private var text: String
    private var lineLimit: Int

    init(_ text: String, lineLimit: Int) {
        self.text = text
        self.lineLimit = lineLimit
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .lineLimit(expanded ? nil : lineLimit)
                .measureHeight { height in
                    limitedTextHeight = height
                    checkTruncation()
                }
                .background(
                    // Invisible text to measure full height
                    Text(text)
                        .lineLimit(nil) // No line limit to get full height
                        .fixedSize(horizontal: false, vertical: true)
                        .measureHeight { height in
                            fullTextHeight = height
                            checkTruncation()
                        }
                        .hidden() // Hide this text from view
                )

            if truncated {
                Button(action: {
                    expanded.toggle()
                }) {
                    Text(expanded ? "Read Less" : "Read More")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
    }

    private func checkTruncation() {
        // Only set truncated if both heights have been measured
        if fullTextHeight > 0 && limitedTextHeight > 0 {
            truncated = fullTextHeight > limitedTextHeight
        }
    }
}

// MARK: - Previews
struct ExpandableText_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 20) {
            ExpandableText("This is a short text that should not be truncated.", lineLimit: 3)

            ExpandableText("This is a very long text that should be truncated. It contains multiple lines of content to demonstrate the truncation and expansion functionality. Users can click 'Read More' to see the full text and 'Read Less' to collapse it again.", lineLimit: 3)
        }
        .padding()
    }
}
