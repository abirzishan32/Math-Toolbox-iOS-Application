//
//  GraphPlotterView.swift
//  Graph Plotter
//
//  Created by Abir Rahman on 10/11/24.
//

import SwiftUI
import Foundation

// EquationParser and CoordinateSystem structs remain the same
struct EquationParser {
    // Previous implementation remains unchanged
    private static func evaluateMathFunction(_ name: String, _ x: Double) -> Double? {
        switch name {
            case "sin": return Darwin.sin(x)
            case "cos": return Darwin.cos(x)
            case "tan": return Darwin.tan(x)
            case "asin", "arcsin": return (x >= -1 && x <= 1) ? Darwin.asin(x) : nil
            case "acos", "arccos": return (x >= -1 && x <= 1) ? Darwin.acos(x) : nil
            case "atan", "arctan": return Darwin.atan(x)
            default: return nil
        }
    }

    private func preprocessEquation(_ equation: String) -> String {
        var processed = equation.lowercased()
        processed = processed.replacingOccurrences(of: "sin^(-1)", with: "asin")
        processed = processed.replacingOccurrences(of: "cos^(-1)", with: "arccos")
        processed = processed.replacingOccurrences(of: "tan^(-1)", with: "arctan")
        return processed
    }

    func evaluate(equation: String, x: Double) -> Double? {
            // Existing evaluate implementation...
            let processedEquation = preprocessEquation(equation)
            let patterns = ["sin\\((.*?)\\)", "cos\\((.*?)\\)", "tan\\((.*?)\\)"]
            var evaluatedEquation = processedEquation

            for pattern in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    let nsRange = NSRange(evaluatedEquation.startIndex..<evaluatedEquation.endIndex, in: evaluatedEquation)
                    let matches = regex.matches(in: evaluatedEquation, options: [], range: nsRange)
                    for match in matches.reversed() {
                        guard let functionRange = Range(match.range, in: evaluatedEquation),
                              let argumentRange = Range(match.range(at: 1), in: evaluatedEquation) else {
                            continue
                        }

                        let functionName = evaluatedEquation[functionRange.lowerBound..<argumentRange.lowerBound]
                            .trimmingCharacters(in: CharacterSet(charactersIn: "("))
                        let argument = evaluatedEquation[argumentRange]

                        if let argValue = evaluateSimpleExpression(String(argument), x: x),
                           let result = EquationParser.evaluateMathFunction(String(functionName), argValue) {
                            evaluatedEquation.replaceSubrange(functionRange, with: String(result))
                        }
                    }
                }
            }
            return evaluateSimpleExpression(evaluatedEquation, x: x)
    }


    private func evaluateSimpleExpression(_ expr: String, x: Double) -> Double? {
        let withX = expr.replacingOccurrences(of: "x", with: String(x))
        let expression = NSExpression(format: withX)
        return expression.expressionValue(with: nil, context: nil) as? Double
    }
}

struct CoordinateSystem {
    let gridSpacing: CGFloat = 50
    let unitSpacing: CGFloat = 50

    func valueToPoint(value: Double, scale: CGFloat) -> CGFloat {
        return CGFloat(value) * unitSpacing * scale
    }

    func pointToValue(point: CGFloat, scale: CGFloat) -> Double {
        return Double(point) / (Double(unitSpacing) * Double(scale))
    }
}

struct ZoomControl: View {
    let scale: Binding<CGFloat>
    let minScale: CGFloat
    let maxScale: CGFloat

    var body: some View {
        HStack(spacing: 20) {
            Button(action: {
                withAnimation {
                    scale.wrappedValue = max(scale.wrappedValue * 0.8, minScale)
                }
            }) {
                Image(systemName: "minus.magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.blue)
            }

            Text(String(format: "%.1fx", scale.wrappedValue))
                .font(.caption)
                .frame(width: 50)

            Button(action: {
                withAnimation {
                    scale.wrappedValue = min(scale.wrappedValue * 1.2, maxScale)
                }
            }) {
                Image(systemName: "plus.magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.9))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}


struct EquationData: Identifiable {
    let id = UUID()
    var equation: String
    var points: [CGPoint]
    var color: Color
    var isEnabled: Bool
}

struct GraphPlotterView: View {
    @State private var equations: [EquationData] = [
        EquationData(equation: "sin(x)", points: [], color: .blue, isEnabled: true),
        EquationData(equation: "cos(x)", points: [], color: .red, isEnabled: true)
    ]
    @State private var scale: CGFloat = 1.0
    @State private var errorMessage: String? = nil
    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    private let parser = EquationParser()
    private let coordSystem = CoordinateSystem()

    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 5.0

    var body: some View {
        VStack {
            Text("iGraph")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(Color.black)
                .shadow(color: .gray, radius: 3, x: 0, y: 3)
                .padding(.top, 40)

            Text("Play With Graphs")
                .font(.body)
                .foregroundColor(.black)
                .padding(.horizontal)

            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundColor(.black)
                .padding()

            // Equation inputs with color indicators
            VStack(spacing: 10) {
                ForEach(equations.indices, id: \.self) { index in
                    HStack {
                        Circle()
                            .fill(equations[index].color)
                            .frame(width: 20, height: 20)

                        TextField("Enter equation \(index + 1)", text: $equations[index].equation)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Toggle("", isOn: $equations[index].isEnabled)
                            .labelsHidden()
                    }
                    .padding(.horizontal)
                }
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            ZStack {
                GeometryReader { geo in
                    Canvas { context, size in
                        let midX = size.width / 2
                        let midY = size.height / 2

                        context.translateBy(x: midX, y: midY)

                        // Draw grid and axes
                        drawGridAndAxes(context: context, size: size, scale: scale)
                        drawCoordinateLabels(context: context, size: size, scale: scale)

                        // Draw all enabled graphs
                        for equationData in equations where equationData.isEnabled {
                            drawGraph(points: equationData.points, color: equationData.color, context: context)
                        }
                    }
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let newScale = finalScale * value.magnitude
                                if newScale >= minScale && newScale <= maxScale {
                                    currentScale = value.magnitude
                                    scale = newScale
                                }
                            }
                            .onEnded { value in
                                finalScale = scale
                            }
                    )
                }
                .border(Color.black)

                VStack {
                    Spacer()
                    ZoomControl(scale: $scale, minScale: minScale, maxScale: maxScale)
                        .padding(.bottom, 10)
                }
            }
            .frame(height: 400)
            .padding()

            HStack(spacing: 20) {
                Button("Reset Zoom") {
                    withAnimation {
                        scale = 1.0
                        finalScale = 1.0
                        currentScale = 1.0
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

                Button("Plot Graphs") {
                    plotAllGraphs()
                }
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
            }

            // Legend
            HStack(spacing: 20) {
                ForEach(equations.indices, id: \.self) { index in
                    if equations[index].isEnabled {
                        HStack {
                            Circle()
                                .fill(equations[index].color)
                                .frame(width: 10, height: 10)
                            Text("f\(index + 1)(x) = \(equations[index].equation)")
                                .font(.caption)
                        }
                    }
                }
            }
            .padding()
        }
        .padding()
        .onAppear {
            plotAllGraphs()
        }
    }

    private func drawGraph(points: [CGPoint], color: Color, context: GraphicsContext) {
        if !points.isEmpty {
            var graphPath = Path()
            var isFirst = true

            for point in points {
                let scaledPoint = CGPoint(x: point.x * scale, y: -point.y * scale)
                if isFirst {
                    graphPath.move(to: scaledPoint)
                    isFirst = false
                } else {
                    let prevPoint = points[points.firstIndex(of: point)! - 1]
                    let distance = hypot(point.x - prevPoint.x, point.y - prevPoint.y)
                    if distance < 50 {
                        graphPath.addLine(to: scaledPoint)
                    } else {
                        graphPath.move(to: scaledPoint)
                    }
                }
            }
            context.stroke(graphPath, with: .color(color), lineWidth: 2)
        }
    }

    private func plotAllGraphs() {
        errorMessage = nil

        for index in equations.indices {
            var points: [CGPoint] = []

            for x in stride(from: -10.0, through: 10.0, by: 0.05) {
                if let y = parser.evaluate(equation: equations[index].equation, x: x) {
                    if equations[index].equation.contains("^(-1)") {
                        if equations[index].equation.contains("sin^(-1)") && (x < -1 || x > 1) { continue }
                        if equations[index].equation.contains("cos^(-1)") && (x < -1 || x > 1) { continue }
                    }
                    points.append(CGPoint(x: x * 20, y: y * 20))
                }
            }

            equations[index].points = points
        }

        if equations.allSatisfy({ $0.points.isEmpty }) {
            errorMessage = "Invalid equation(s) or no points to plot"
        }
    }

    // Existing helper functions remain the same
    private func drawGridAndAxes(context: GraphicsContext, size: CGSize, scale: CGFloat) {
        // Existing implementation...
        let midX = size.width / 2
        let midY = size.height / 2

        var path = Path()
        path.move(to: CGPoint(x: -midX, y: 0))
        path.addLine(to: CGPoint(x: midX, y: 0))
        path.move(to: CGPoint(x: 0, y: -midY))
        path.addLine(to: CGPoint(x: 0, y: midY))
        context.stroke(path, with: .color(.gray), lineWidth: 1)

        let gridPath = Path { path in
            let spacing = coordSystem.gridSpacing * scale
            stride(from: -midX, through: midX, by: spacing).forEach { x in
                path.move(to: CGPoint(x: x, y: -midY))
                path.addLine(to: CGPoint(x: x, y: midY))
            }
            stride(from: -midY, through: midY, by: spacing).forEach { y in
                path.move(to: CGPoint(x: -midX, y: y))
                path.addLine(to: CGPoint(x: midX, y: y))
            }
        }
        context.stroke(gridPath, with: .color(.gray.opacity(0.3)), lineWidth: 0.5)
    }

    private func drawCoordinateLabels(context: GraphicsContext, size: CGSize, scale: CGFloat) {
        // Existing implementation...
        let midX = size.width / 2
        let midY = size.height / 2
        let spacing = coordSystem.gridSpacing * scale

        stride(from: -midX, through: midX, by: spacing).forEach { x in
            let value = coordSystem.pointToValue(point: x, scale: scale)
            if abs(value) > 0.1 {
                let text = Text("\(Int(round(value)))")
                    .font(.system(size: 10))
                    .foregroundColor(.black)
                context.draw(text, at: CGPoint(x: x, y: 10))
            }
        }

        stride(from: -midY, through: midY, by: spacing).forEach { y in
            let value = -coordSystem.pointToValue(point: y, scale: scale)
            if abs(value) > 0.1 {
                let text = Text("\(Int(round(value)))")
                    .font(.system(size: 10))
                    .foregroundColor(.black)
                context.draw(text, at: CGPoint(x: -20, y: y))
            }
        }
    }
}

//struct GraphPlotterView: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}

#Preview {
    GraphPlotterView()
}
