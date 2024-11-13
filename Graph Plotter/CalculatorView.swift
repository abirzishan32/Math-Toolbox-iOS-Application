//
//  CalculatorView.swift
//  Graph Plotter
//
//  Created by Abir Rahman on 10/11/24.
//

import SwiftUI

struct CalculatorView: View {
    @State private var display = "0"
    @State private var currentNumber = ""
    @State private var previousNumber = ""
    @State private var operation: String?
    @State private var isInScientificMode = false
    @State private var memory: Double = 0
    @Environment(\.dismiss) private var dismiss
    
    private let buttons: [[CalculatorButton]] = [
        [.clear, .negative, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .subtract],
        [.one, .two, .three, .add],
        [.zero, .decimal, .equals]
    ]
    
    private let scientificButtons: [[CalculatorButton]] = [
        [.sin, .cos, .tan],
        [.ln, .log, .pi],
        [.square, .cube, .power],
        [.leftParenthesis, .rightParenthesis, .euler],
        [.memoryClear, .memoryRecall, .memoryAdd]
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HStack {
                    Spacer()
                    Text(display)
                        .font(.system(size: 64))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding()
                }
                
                Toggle("Scientific Mode", isOn: $isInScientificMode)
                    .padding(.horizontal)
                
                if isInScientificMode {
                    ForEach(scientificButtons, id: \.self) { row in
                        HStack(spacing: 12) {
                            ForEach(row, id: \.self) { button in
                                CalculatorButtonView(button: button) {
                                    self.buttonTapped(button)
                                }
                            }
                        }
                    }
                }
                
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { button in
                            CalculatorButtonView(button: button) {
                                self.buttonTapped(button)
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func buttonTapped(_ button: CalculatorButton) {
        switch button {
        case .number(let value):
            if operation == nil {
                currentNumber = currentNumber == "0" ? "\(value)" : currentNumber + "\(value)"
                display = currentNumber
            } else {
                previousNumber = previousNumber == "0" ? "\(value)" : previousNumber + "\(value)"
                display = previousNumber
            }
            
        case .clear:
            display = "0"
            currentNumber = ""
            previousNumber = ""
            operation = nil
            
        case .decimal:
            if operation == nil {
                if !currentNumber.contains(".") {
                    currentNumber += currentNumber.isEmpty ? "0." : "."
                    display = currentNumber
                }
            } else {
                if !previousNumber.contains(".") {
                    previousNumber += previousNumber.isEmpty ? "0." : "."
                    display = previousNumber
                }
            }
            
        case .equals:
            calculateResult()
            
        case .add, .subtract, .multiply, .divide:
            if let current = Double(currentNumber), let previous = Double(previousNumber) {
                calculateResult()
            }
            operation = button.title
            
        case .sin, .cos, .tan:
            if let value = Double(currentNumber) {
                let radians = value * .pi / 180
                let result: Double
                switch button {
                case .sin: result = sin(radians)
                case .cos: result = cos(radians)
                case .tan: result = tan(radians)
                default: result = 0
                }
                display = formatResult(result)
                currentNumber = display
            }
            
        case .square:
            if let value = Double(currentNumber) {
                let result = pow(value, 2)
                display = formatResult(result)
                currentNumber = display
            }
            
        case .memoryClear:
            memory = 0
            
        case .memoryRecall:
            display = formatResult(memory)
            currentNumber = display
            
        case .memoryAdd:
            if let value = Double(display) {
                memory += value
            }
            
        default:
            break
        }
    }
    
    private func calculateResult() {
        guard let current = Double(currentNumber),
              let operationSymbol = operation else { return }
        
        let previous = Double(previousNumber) ?? current
        
        let result: Double
        switch operationSymbol {
        case "+": result = previous + current
        case "-": result = previous - current
        case "×": result = previous * current
        case "÷": result = previous / current
        default: result = current
        }
        
        display = formatResult(result)
        currentNumber = display
        previousNumber = ""
        operation = nil
    }
    
    private func formatResult(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        return formatter.string(from: NSNumber(value: number)) ?? "Error"
    }
}

enum CalculatorButton: Hashable {
    case number(Int)
    case clear, negative, percent, decimal
    case add, subtract, multiply, divide, equals
    case sin, cos, tan
    case ln, log, pi
    case square, cube, power
    case leftParenthesis, rightParenthesis, euler
    case memoryClear, memoryRecall, memoryAdd
    
    var title: String {
        switch self {
        case .number(let value): return "\(value)"
        case .clear: return "C"
        case .negative: return "±"
        case .percent: return "%"
        case .decimal: return "."
        case .add: return "+"
        case .subtract: return "-"
        case .multiply: return "×"
        case .divide: return "÷"
        case .equals: return "="
        case .sin: return "sin"
        case .cos: return "cos"
        case .tan: return "tan"
        case .ln: return "ln"
        case .log: return "log"
        case .pi: return "π"
        case .square: return "x²"
        case .cube: return "x³"
        case .power: return "xʸ"
        case .leftParenthesis: return "("
        case .rightParenthesis: return ")"
        case .euler: return "e"
        case .memoryClear: return "MC"
        case .memoryRecall: return "MR"
        case .memoryAdd: return "M+"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .clear, .negative, .percent:
            return .gray.opacity(0.3)
        case .add, .subtract, .multiply, .divide, .equals:
            return .orange
        case .sin, .cos, .tan, .ln, .log, .pi, .square, .cube, .power,
             .leftParenthesis, .rightParenthesis, .euler,
             .memoryClear, .memoryRecall, .memoryAdd:
            return .blue.opacity(0.7)
        default:
            return .gray.opacity(0.2)
        }
    }
}

struct CalculatorButtonView: View {
    let button: CalculatorButton
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(button.title)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(button.backgroundColor)
                .cornerRadius(12)
        }
        .frame(height: 60)
    }
}

extension CalculatorButton {
    static let zero = CalculatorButton.number(0)
    static let one = CalculatorButton.number(1)
    static let two = CalculatorButton.number(2)
    static let three = CalculatorButton.number(3)
    static let four = CalculatorButton.number(4)
    static let five = CalculatorButton.number(5)
    static let six = CalculatorButton.number(6)
    static let seven = CalculatorButton.number(7)
    static let eight = CalculatorButton.number(8)
    static let nine = CalculatorButton.number(9)
}

#Preview {
    CalculatorView()
}
