//
//  AddressFormView.swift
//  BoltMedusaCart
//
//  Created by Ricardo Bento on 28/06/2025.
//

import SwiftUI

struct AddressFormView: View {
    @EnvironmentObject var checkoutService: CheckoutService
    @Environment(\.dismiss) private var dismiss
    
    let isEditing: Bool
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var company = ""
    @State private var address1 = ""
    @State private var address2 = ""
    @State private var city = ""
    @State private var province = ""
    @State private var postalCode = ""
    @State private var countryCode = "US"
    @State private var phone = ""
    
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    HStack {
                        TextField("First Name", text: $firstName)
                        TextField("Last Name", text: $lastName)
                    }
                    
                    TextField("Company (Optional)", text: $company)
                    
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }
                
                Section("Address") {
                    TextField("Address Line 1", text: $address1)
                    
                    TextField("Address Line 2 (Optional)", text: $address2)
                    
                    HStack {
                        TextField("City", text: $city)
                        TextField("State/Province", text: $province)
                    }
                    
                    HStack {
                        TextField("Postal Code", text: $postalCode)
                        
                        Picker("Country", selection: $countryCode) {
                            Text("United States").tag("US")
                            Text("Canada").tag("CA")
                            Text("United Kingdom").tag("GB")
                            Text("Germany").tag("DE")
                            Text("France").tag("FR")
                            Text("Australia").tag("AU")
                            Text("Japan").tag("JP")
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Shipping Address" : "Billing Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAddress()
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .onAppear {
                loadExistingAddress()
            }
        }
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !address1.isEmpty &&
        !city.isEmpty &&
        !province.isEmpty &&
        !postalCode.isEmpty
    }
    
    private func loadExistingAddress() {
        guard let existingAddress = isEditing ? 
            checkoutService.currentCart?.shippingAddress : 
            checkoutService.currentCart?.billingAddress else { return }
        
        firstName = existingAddress.firstName ?? ""
        lastName = existingAddress.lastName ?? ""
        company = existingAddress.company ?? ""
        address1 = existingAddress.address1 ?? ""
        address2 = existingAddress.address2 ?? ""
        city = existingAddress.city ?? ""
        province = existingAddress.province ?? ""
        postalCode = existingAddress.postalCode ?? ""
        countryCode = existingAddress.countryCode ?? "US"
        phone = existingAddress.phone ?? ""
    }
    
    private func saveAddress() {
        isLoading = true
        
        let address = Address(
            id: nil,
            customerId: checkoutService.currentCart?.customerId,
            company: company.isEmpty ? nil : company,
            firstName: firstName,
            lastName: lastName,
            address1: address1,
            address2: address2.isEmpty ? nil : address2,
            city: city,
            countryCode: countryCode,
            province: province,
            postalCode: postalCode,
            phone: phone.isEmpty ? nil : phone,
            createdAt: nil,
            updatedAt: nil,
            deletedAt: nil,
            metadata: nil
        )
        
        Task {
            if isEditing {
                await checkoutService.updateShippingAddress(address)
            } else {
                await checkoutService.updateBillingAddress(address)
            }
            
            isLoading = false
            dismiss()
        }
    }
}

#Preview {
    AddressFormView(isEditing: true)
        .environmentObject(CheckoutService())
}