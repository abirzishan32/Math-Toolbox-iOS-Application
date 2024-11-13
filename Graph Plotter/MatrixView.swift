//
//  MatrixView.swift
//  Graph Plotter
//
//  Created by Abir Rahman on 10/11/24.
//

import SwiftUI

import SwiftUI

struct MatrixView: View {
    @State private var matrixA: [[Double]] = []
    @State private var matrixB: [[Double]] = []
    @State private var result: [[Double]] = []
    @State private var operation: String = "Add"
    @State private var rowsA: String = "2"
    @State private var columnsA: String = "2"
    @State private var rowsB: String = "2"
    @State private var columnsB: String = "2"
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack {
            Text("Matrix Operations")
                .font(.largeTitle)
                .padding(.top, 20)
            
            VStack {
                Text("Matrix A Size")
                HStack {
                    TextField("Rows", text: $rowsA)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 60)
                    TextField("Columns", text: $columnsA)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 60)
                }
            }
            .padding()
            
            VStack {
                Text("Matrix B Size")
                HStack {
                    TextField("Rows", text: $rowsB)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 60)
                    TextField("Columns", text: $columnsB)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 60)
                }
            }
            .padding()

            Button(action: {
                initializeMatrices()
            }) {
                Text("Initialize Matrices")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            if matrixA.isEmpty || matrixB.isEmpty {
                Text("Please initialize the matrices first.")
                    .foregroundColor(.red)
                    .padding()
            } else {
                HStack {
                    VStack {
                        Text("Matrix A")
                        MatrixInputView(matrix: $matrixA)
                    }
                    VStack {
                        Text("Matrix B")
                        MatrixInputView(matrix: $matrixB)
                    }
                }
                .padding()

                Picker("Operation", selection: $operation) {
                    Text("Add").tag("Add")
                    Text("Subtract").tag("Subtract")
                    Text("Multiply").tag("Multiply")
                    Text("Inverse A").tag("Inverse A")
                    Text("Inverse B").tag("Inverse B")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Button(action: performOperation) {
                    Text("Perform Operation")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("Result")
                        .font(.title2)
                        .padding(.top)
                    MatrixResultView(matrix: result)
                        .padding()
                }
            }
        }
        .padding()
    }
    
    func initializeMatrices() {
        guard let rowsA = Int(rowsA), let columnsA = Int(columnsA),
              let rowsB = Int(rowsB), let columnsB = Int(columnsB) else {
            errorMessage = "Invalid matrix size."
            return
        }
        
        matrixA = Array(repeating: Array(repeating: 0.0, count: columnsA), count: rowsA)
        matrixB = Array(repeating: Array(repeating: 0.0, count: columnsB), count: rowsB)
        result = []
        errorMessage = nil
    }

    func performOperation() {
        switch operation {
        case "Add":
            if matrixA.count == matrixB.count && matrixA[0].count == matrixB[0].count {
                result = addMatrices(matrixA, matrixB)
                errorMessage = nil
            } else {
                errorMessage = "Matrix dimensions must match for addition."
            }
        case "Subtract":
            if matrixA.count == matrixB.count && matrixA[0].count == matrixB[0].count {
                result = subtractMatrices(matrixA, matrixB)
                errorMessage = nil
            } else {
                errorMessage = "Matrix dimensions must match for subtraction."
            }
        case "Multiply":
            if matrixA[0].count == matrixB.count {
                result = multiplyMatrices(matrixA, matrixB)
                errorMessage = nil
            } else {
                errorMessage = "Matrix multiplication dimensions do not match."
            }
        case "Inverse A":
            if matrixA.count == matrixA[0].count {
                result = invertMatrix(matrixA)
                errorMessage = nil
            } else {
                errorMessage = "Matrix A must be square for inversion."
            }
        case "Inverse B":
            if matrixB.count == matrixB[0].count {
                result = invertMatrix(matrixB)
                errorMessage = nil
            } else {
                errorMessage = "Matrix B must be square for inversion."
            }
        default:
            break
        }
    }

    func addMatrices(_ a: [[Double]], _ b: [[Double]]) -> [[Double]] {
        var result = a
        for i in 0..<a.count {
            for j in 0..<a[i].count {
                result[i][j] = a[i][j] + b[i][j]
            }
        }
        return result
    }
    
    func subtractMatrices(_ a: [[Double]], _ b: [[Double]]) -> [[Double]] {
        var result = a
        for i in 0..<a.count {
            for j in 0..<a[i].count {
                result[i][j] = a[i][j] - b[i][j]
            }
        }
        return result
    }
    
    func multiplyMatrices(_ a: [[Double]], _ b: [[Double]]) -> [[Double]] {
        var result = a
        for i in 0..<a.count {
            for j in 0..<b[0].count {
                result[i][j] = 0
                for k in 0..<b.count {
                    result[i][j] += a[i][k] * b[k][j]
                }
            }
        }
        return result
    }
    
    func invertMatrix(_ matrix: [[Double]]) -> [[Double]] {
        let n = matrix.count
        var augmentedMatrix = matrix
        for i in 0..<n {
            augmentedMatrix[i].append(i == 0 ? 1.0 : 0.0)
        }
        
        for i in 0..<n {
            var maxRow = i
            for j in i+1..<n {
                if abs(augmentedMatrix[j][i]) > abs(augmentedMatrix[maxRow][i]) {
                    maxRow = j
                }
            }
            augmentedMatrix.swapAt(i, maxRow)
            
            let pivot = augmentedMatrix[i][i]
            for j in i..<augmentedMatrix[i].count {
                augmentedMatrix[i][j] /= pivot
            }
            
            for j in 0..<n {
                if i != j {
                    let factor = augmentedMatrix[j][i]
                    for k in i..<augmentedMatrix[j].count {
                        augmentedMatrix[j][k] -= factor * augmentedMatrix[i][k]
                    }
                }
            }
        }
        
        var inverseMatrix: [[Double]] = []
        for i in 0..<n {
            var row: [Double] = []
            for j in n..<augmentedMatrix[i].count {
                row.append(augmentedMatrix[i][j])
            }
            inverseMatrix.append(row)
        }
        return inverseMatrix
    }
}

struct MatrixInputView: View {
    @Binding var matrix: [[Double]]
    
    var body: some View {
        VStack {
            ForEach(0..<matrix.count, id: \.self) { i in
                HStack {
                    ForEach(0..<matrix[i].count, id: \.self) { j in
                        TextField("\(matrix[i][j])", value: $matrix[i][j], format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 60)
                            .keyboardType(.decimalPad)
                    }
                }
            }
        }
    }
}

struct MatrixResultView: View {
    var matrix: [[Double]]
    
    var body: some View {
        VStack {
            ForEach(0..<matrix.count, id: \.self) { i in
                HStack {
                    ForEach(0..<matrix[i].count, id: \.self) { j in
                        Text("\(String(format: "%.2f", matrix[i][j]))")
                            .frame(width: 60)
                            .padding(5)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                    }
                }
            }
        }
    }
}

struct MatrixView_Previews: PreviewProvider {
    static var previews: some View {
        MatrixView()
    }
}
