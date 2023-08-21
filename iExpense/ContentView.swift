//
//  ContentView.swift
//  iExpense
//
//  Created by Vito Borghi on 17/08/2023.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var expenses = Expenses()
    @State var showingAddExpense = false
    @State var showingSettings = false
    
    @State var chosenCurrency = "GBP"
        
    func removeItems (at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // personal
                List{
                    ForEach(expenses.items) { item in
                        if item.type == "Personal" {
                            HStack {
                                VStack(alignment: .leading){
                                    Text(item.name)
                                        .font(.headline)
                                    Text(item.type)
                                }
                                Spacer()
                                Text(item.amount, format: .currency(code: item.currency))
                            }
                            .listRowBackground(item.amount < 10 ? Color(uiColor: .systemGreen) : item.amount > 100 ? Color(uiColor: .systemOrange) : Color(uiColor: .systemYellow))
                        }
                    }
                    .onDelete(perform: removeItems)
                }
                // business
                List{
                    ForEach(expenses.items) { item in
                        if item.type == "Business"{
                            HStack {
                                VStack(alignment: .leading){
                                    Text(item.name)
                                        .font(.headline)
                                    Text(item.type)
                                }
                                Spacer()
                                Text(item.amount, format: .currency(code: item.currency))
                            }
                            .listRowBackground(item.amount < 10 ? Color(uiColor: .systemGreen) : item.amount > 100 ? Color(uiColor: .systemOrange) : Color(uiColor: .systemYellow))
                        }
                    }
                    .onDelete(perform: removeItems)
                }
                
                Button("ADD Expense"){
                    showingAddExpense = true 
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("iExpense")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gear")
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: expenses, currency: chosenCurrency)
            }
            .sheet(isPresented: $showingSettings){
                Settings(selectedCurrency: $chosenCurrency)
            }
        }
    }
    
    struct Settings: View {
        @Environment(\.dismiss) var dismissView
        @Binding var selectedCurrency: String
        
        let availableCurrencies = Locale.commonISOCurrencyCodes.compactMap({$0}).sorted()
        
        var body: some View {
                VStack {
                    VStack{
                        HStack(alignment: .top){
                            Button("Cancel") {
                                dismissView()
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    Picker("Select Currency", selection: $selectedCurrency) {
                        ForEach(availableCurrencies, id: \.self) { currencyCode in
                            Text("\(currencyName(currencyCode: currencyCode)) (\(currencyCode))")
                                .tag(currencyCode)
                        }
                    }
                    .pickerStyle(.wheel)
                    
                    Text("Selected Currency: \(currencyName(currencyCode: selectedCurrency)) (\(selectedCurrency))")
                        .padding()
                    Button ("Save"){
                        print(selectedCurrency)
                        dismissView()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    Spacer()
                }
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading){
                        Button("Cancel", role: .destructive) {
                            dismissView()
                        }
                    }
                }
        }
        
        func currencyName(currencyCode: String) -> String {
            let locale = Locale(identifier: Locale.identifier(fromComponents: [NSLocale.Key.currencyCode.rawValue: currencyCode]))
            return locale.localizedString(forCurrencyCode: currencyCode) ?? currencyCode
        }
        
        func getCurrency() -> String {
            selectedCurrency
        }
    }
    
    struct AddView: View {
        @ObservedObject var expenses: Expenses
        @Environment(\.dismiss) var dismissView
        
        @State private var name = ""
        @State private var type = "Business"
        @State private var amount = 0.0
        @State var currency: String
        
        let types = ["Business", "Personal"]
        
        
        var body: some View {
            NavigationView{
                Form {
                    TextField("Name", text: $name)
                        .padding()
                    Picker("Type", selection: $type) {
                        ForEach(types, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    .padding()
                    HStack{
                        Text(currency).multilineTextAlignment(.leading)
                            
                        TextField("Amount", value: $amount, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                        .padding()
                }
                .navigationTitle("Add new expense")
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading){
                        Button("Cancel", role: .destructive) {
                            dismissView()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save"){
                            let item = ExpenseItem(name: name, type: type, amount: amount, currency: currency)
                            expenses.items.append(item)
                            dismissView()
                        }
                    }
                }
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
