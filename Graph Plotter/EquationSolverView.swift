//
//  EquationSolverView.swift
//  Graph Plotter
//
//  Created by Abir Rahman on 10/11/24.
//

import SwiftUI

import SwiftUI

struct EquationSolverView: View {
    @State private var selectedSolver = "Polynomial Degree 2"
    private let solvers = ["Polynomial Degree 2", "Polynomial Degree 3", "2 Unknowns System", "3 Unknowns System"]
    
    // Polynomial coefficients
    @State private var a: Double = 0
    @State private var b: Double = 0
    @State private var c: Double = 0
    @State private var d: Double = 0
    
    // System equation coefficients
    @State private var a1: Double = 0
    @State private var b1: Double = 0
    @State private var c1: Double = 0
    @State private var a2: Double = 0
    @State private var b2: Double = 0
    @State private var c2: Double = 0
    @State private var a3: Double = 0
    @State private var b3: Double = 0
    @State private var c3: Double = 0
    @State private var d3: Double = 0
    
    // Solution
    @State private var solution: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Equation Solver")
                .font(.largeTitle)
                .bold()
            
            Picker("Select Solver", selection: $selectedSolver) {
                ForEach(solvers, id: \.self) { solver in
                    Text(solver)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedSolver == "Polynomial Degree 2" {
                PolynomialDegree2InputView(a: $a, b: $b, c: $c)
            } else if selectedSolver == "Polynomial Degree 3" {
                PolynomialDegree3InputView(a: $a, b: $b, c: $c, d: $d)
            } else if selectedSolver == "2 Unknowns System" {
                System2UnknownsInputView(a1: $a1, b1: $b1, c1: $c1, a2: $a2, b2: $b2, c2: $c2)
            } else if selectedSolver == "3 Unknowns System" {
                System3UnknownsInputView(a1: $a1, b1: $b1, c1: $c1, a2: $a2, b2: $b2, c2: $c2, a3: $a3, b3: $b3, c3: $c3, d3: $d3)
            }
            
            Button(action: solveEquation) {
                Text("Solve")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Text("Solution: \(solution)")
                .font(.title2)
                .padding()
            
            Spacer()
        }
        .padding()
    }
    
    func solveEquation() {
        switch selectedSolver {
        case "Polynomial Degree 2":
            solution = solveQuadratic(a: a, b: b, c: c)
        case "Polynomial Degree 3":
            solution = solveCubic(a: a, b: b, c: c, d: d)
        case "2 Unknowns System":
            solution = solveSystem2Unknowns(a1: a1, b1: b1, c1: c1, a2: a2, b2: b2, c2: c2)
        case "3 Unknowns System":
            solution = solveSystem3Unknowns(a1: a1, b1: b1, c1: c1, a2: a2, b2: b2, c2: c2, a3: a3, b3: b3, c3: c3, d3: d3)
        default:
            solution = "Select an equation type to solve."
        }
    }
    
    // Solving functions for each equation type
    
    func solveQuadratic(a: Double, b: Double, c: Double) -> String {
        let discriminant = b * b - 4 * a * c
        if discriminant < 0 {
            return "No real solutions."
        } else if discriminant == 0 {
            let root = -b / (2 * a)
            return "One solution: x = \(root)"
        } else {
            let root1 = (-b + sqrt(discriminant)) / (2 * a)
            let root2 = (-b - sqrt(discriminant)) / (2 * a)
            return "Two solutions: x1 = \(root1), x2 = \(root2)"
        }
    }
    
    func solveCubic(a: Double, b: Double, c: Double, d: Double) -> String {
        // Placeholder - solving cubic equations analytically is complex and usually requires numerical methods
        return "Cubic equation solution not implemented."
    }
    
    func solveSystem2Unknowns(a1: Double, b1: Double, c1: Double, a2: Double, b2: Double, c2: Double) -> String {
        let determinant = a1 * b2 - b1 * a2
        if determinant == 0 {
            return "No unique solution."
        } else {
            let x = (c1 * b2 - b1 * c2) / determinant
            let y = (a1 * c2 - c1 * a2) / determinant
            return "Solution: x = \(x), y = \(y)"
        }
    }
    
    func solveSystem3Unknowns(a1: Double, b1: Double, c1: Double, a2: Double, b2: Double, c2: Double, a3: Double, b3: Double, c3: Double, d3: Double) -> String {
        // Placeholder - solving 3x3 systems manually here can be complex
        return "3x3 system solution not implemented."
    }
}

// Separate input views for each solver

struct PolynomialDegree2InputView: View {
    @Binding var a: Double
    @Binding var b: Double
    @Binding var c: Double
    
    var body: some View {
        VStack {
            TextField("Coefficient a", value: $a, format: .number)
            TextField("Coefficient b", value: $b, format: .number)
            TextField("Coefficient c", value: $c, format: .number)
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()
    }
}

struct PolynomialDegree3InputView: View {
    @Binding var a: Double
    @Binding var b: Double
    @Binding var c: Double
    @Binding var d: Double
    
    var body: some View {
        VStack {
            TextField("Coefficient a", value: $a, format: .number)
            TextField("Coefficient b", value: $b, format: .number)
            TextField("Coefficient c", value: $c, format: .number)
            TextField("Coefficient d", value: $d, format: .number)
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()
    }
}

struct System2UnknownsInputView: View {
    @Binding var a1: Double
    @Binding var b1: Double
    @Binding var c1: Double
    @Binding var a2: Double
    @Binding var b2: Double
    @Binding var c2: Double
    
    var body: some View {
        VStack {
            TextField("a1", value: $a1, format: .number)
            TextField("b1", value: $b1, format: .number)
            TextField("c1", value: $c1, format: .number)
            TextField("a2", value: $a2, format: .number)
            TextField("b2", value: $b2, format: .number)
            TextField("c2", value: $c2, format: .number)
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()
    }
}

struct System3UnknownsInputView: View {
    @Binding var a1: Double
    @Binding var b1: Double
    @Binding var c1: Double
    @Binding var a2: Double
    @Binding var b2: Double
    @Binding var c2: Double
    @Binding var a3: Double
    @Binding var b3: Double
    @Binding var c3: Double
    @Binding var d3: Double
    
    var body: some View {
        VStack {
            TextField("a1", value: $a1, format: .number)
            TextField("b1", value: $b1, format: .number)
            TextField("c1", value: $c1, format: .number)
            TextField("a2", value: $a2, format: .number)
            TextField("b2", value: $b2, format: .number)
            TextField("c2", value: $c2, format: .number)
            TextField("a3", value: $a3, format: .number)
            TextField("b3", value: $b3, format: .number)
            TextField("c3", value: $c3, format: .number)
            TextField("d3", value: $d3, format: .number)
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()
    }
}

struct EquationSolverView_Previews: PreviewProvider {
    static var previews: some View {
        EquationSolverView()
    }
}
#Preview {
    EquationSolverView()
}
