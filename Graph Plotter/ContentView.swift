//
//  ContentView.swift
//  Graph Plotter
//
//  Created by Abir Rahman on 9/11/24.
//
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                
                
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Text("Math Toolbox")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    // Decorative Mathematical Symbols
                    HStack {
                        Spacer()
                        Text("∑").font(.system(size: 100)).opacity(0.05)
                        Spacer()
                        Text("π").font(.system(size: 100)).opacity(0.05)
                        Spacer()
                    }
                    
                    VStack(spacing: 30) {
                        // Top Row
                        HStack(spacing: 20) {
                            NavigationLink(destination: GraphPlotterView()) {
                                CardView(title: "Graph Plotter", description: "Visualize equations", icon: "chart.line.uptrend.xyaxis", color: .blue)
                            }
                            NavigationLink(destination: CalculatorView()) {
                                CardView(title: "Calculator", description: "Basic calculations", icon: "function", color: .green)
                            }
                        }
                        
                        // Bottom Row
                        HStack(spacing: 20) {
                            NavigationLink(destination: EquationSolverView()) {
                                CardView(title: "Equation Solver", description: "Solve equations", icon: "sum", color: .orange)
                            }
                            NavigationLink(destination: MatrixView()) {
                                CardView(title: "Matrix Operation", description: "Matrix calculations", icon: "square.grid.3x3", color: .purple)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
}

struct CardView: View {
    var title: String
    var description: String
    var icon: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.white)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.white)
                .opacity(0.8)
            
        }
        .frame(width: 160, height: 160)
        .background(color)
        .cornerRadius(15)
        .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.4), lineWidth: 1)
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
