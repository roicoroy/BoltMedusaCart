//
//  CheckoutView.swift
//  BoltMedusaCart
//
//  Created by Ricardo Bento on 28/06/2025.
//

import SwiftUI

struct CheckoutView: View {
    @StateObject private var checkoutService = CheckoutService()
    @State private var showingAddressForm = false
    @State private var isEditingShipping = false
    @State private var completedOrder: Order?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Indicator
                CheckoutProgressView(currentStep: checkoutService.checkoutStep)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        switch checkoutService.checkoutStep {
                        case .cart:
                            CartStepView()
                        case .shipping:
                            ShippingStepView(showingAddressForm: $showingAddressForm, isEditingShipping: $isEditingShipping)
                        case .payment:
                            PaymentStepView()
                        case .confirmation:
                            ConfirmationStepView()
                        case .complete:
                            OrderCompleteView(order: completedOrder)
                        }
                    }
                    .padding()
                }
                
                // Bottom Action Bar
                if checkoutService.checkoutStep != .complete {
                    CheckoutBottomBar()
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(checkoutService)
            .sheet(isPresented: $showingAddressForm) {
                AddressFormView(isEditing: isEditingShipping)
                    .environmentObject(checkoutService)
            }
            .task {
                // Initialize cart if needed
                if checkoutService.currentCart == nil {
                    await checkoutService.createCart()
                }
            }
        }
    }
}

struct CheckoutProgressView: View {
    let currentStep: CheckoutService.CheckoutStep
    
    var body: some View {
        HStack {
            ForEach(Array(CheckoutService.CheckoutStep.allCases.enumerated()), id: \.offset) { index, step in
                HStack {
                    // Step Circle
                    Circle()
                        .fill(stepColor(for: step))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text("\(index + 1)")
                                .font(.caption.bold())
                                .foregroundColor(stepTextColor(for: step))
                        )
                    
                    // Step Title
                    Text(step.title)
                        .font(.caption)
                        .foregroundColor(stepTextColor(for: step))
                    
                    // Connector Line
                    if index < CheckoutService.CheckoutStep.allCases.count - 1 {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func stepColor(for step: CheckoutService.CheckoutStep) -> Color {
        let currentIndex = CheckoutService.CheckoutStep.allCases.firstIndex(of: currentStep) ?? 0
        let stepIndex = CheckoutService.CheckoutStep.allCases.firstIndex(of: step) ?? 0
        
        if stepIndex <= currentIndex {
            return .blue
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private func stepTextColor(for step: CheckoutService.CheckoutStep) -> Color {
        let currentIndex = CheckoutService.CheckoutStep.allCases.firstIndex(of: currentStep) ?? 0
        let stepIndex = CheckoutService.CheckoutStep.allCases.firstIndex(of: step) ?? 0
        
        if stepIndex <= currentIndex {
            return .white
        } else {
            return .gray
        }
    }
}

struct CartStepView: View {
    @EnvironmentObject var checkoutService: CheckoutService
    @State private var email = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Email Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Contact Information")
                    .font(.headline)
                
                TextField("Email address", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .onChange(of: email) { newValue in
                        Task {
                            await checkoutService.updateCart(email: newValue)
                        }
                    }
            }
            
            // Cart Items
            if let cart = checkoutService.currentCart {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Order Summary")
                        .font(.headline)
                    
                    ForEach(cart.items) { item in
                        CartItemRow(item: item)
                    }
                    
                    Divider()
                    
                    // Totals
                    VStack(spacing: 8) {
                        HStack {
                            Text("Subtotal")
                            Spacer()
                            Text(checkoutService.formatPrice(cart.subtotal))
                        }
                        
                        if cart.discountTotal > 0 {
                            HStack {
                                Text("Discount")
                                Spacer()
                                Text("-\(checkoutService.formatPrice(cart.discountTotal))")
                                    .foregroundColor(.green)
                            }
                        }
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text(checkoutService.formatPrice(cart.total))
                                .font(.headline)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
}

struct CartItemRow: View {
    let item: LineItem
    @EnvironmentObject var checkoutService: CheckoutService
    
    var body: some View {
        HStack {
            // Product Image
            AsyncImage(url: URL(string: item.thumbnail ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .lineLimit(2)
                
                if let description = item.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text(checkoutService.formatPrice(item.unitPrice))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Quantity Controls
            HStack {
                Button {
                    if item.quantity > 1 {
                        Task {
                            await checkoutService.updateLineItem(lineItemId: item.id, quantity: item.quantity - 1)
                        }
                    } else {
                        Task {
                            await checkoutService.removeLineItem(lineItemId: item.id)
                        }
                    }
                } label: {
                    Image(systemName: "minus.circle")
                        .foregroundColor(.red)
                }
                
                Text("\(item.quantity)")
                    .frame(minWidth: 30)
                
                Button {
                    Task {
                        await checkoutService.updateLineItem(lineItemId: item.id, quantity: item.quantity + 1)
                    }
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct ShippingStepView: View {
    @EnvironmentObject var checkoutService: CheckoutService
    @Binding var showingAddressForm: Bool
    @Binding var isEditingShipping: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Shipping Address
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Shipping Address")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button("Edit") {
                        isEditingShipping = true
                        showingAddressForm = true
                    }
                    .foregroundColor(.blue)
                }
                
                if let address = checkoutService.currentCart?.shippingAddress {
                    AddressDisplayView(address: address)
                } else {
                    Button("Add Shipping Address") {
                        isEditingShipping = true
                        showingAddressForm = true
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            // Shipping Options
            if !checkoutService.availableShippingOptions.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Shipping Method")
                        .font(.headline)
                    
                    ForEach(checkoutService.availableShippingOptions) { option in
                        ShippingOptionRow(option: option)
                    }
                }
            }
        }
        .task {
            await checkoutService.getShippingOptions()
        }
    }
}

struct ShippingOptionRow: View {
    let option: ShippingOption
    @EnvironmentObject var checkoutService: CheckoutService
    
    var isSelected: Bool {
        checkoutService.currentCart?.shippingMethods.contains { $0.shippingOptionId == option.id } ?? false
    }
    
    var body: some View {
        Button {
            Task {
                await checkoutService.addShippingMethod(optionId: option.id)
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(option.name)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    if let amount = option.amount {
                        Text(checkoutService.formatPrice(amount))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct PaymentStepView: View {
    @EnvironmentObject var checkoutService: CheckoutService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Payment Method")
                .font(.headline)
            
            if checkoutService.availablePaymentProviders.isEmpty {
                Button("Initialize Payment") {
                    Task {
                        await checkoutService.initializePaymentSessions()
                    }
                }
                .buttonStyle(.borderedProminent)
            } else {
                ForEach(checkoutService.availablePaymentProviders, id: \.self) { provider in
                    PaymentProviderRow(providerId: provider)
                }
            }
        }
    }
}

struct PaymentProviderRow: View {
    let providerId: String
    @EnvironmentObject var checkoutService: CheckoutService
    
    var isSelected: Bool {
        checkoutService.currentCart?.paymentSession?.providerId == providerId
    }
    
    var body: some View {
        Button {
            Task {
                await checkoutService.selectPaymentSession(providerId: providerId)
            }
        } label: {
            HStack {
                Text(providerId.capitalized)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct ConfirmationStepView: View {
    @EnvironmentObject var checkoutService: CheckoutService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Order Review")
                .font(.headline)
            
            if let cart = checkoutService.currentCart {
                // Contact Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contact")
                        .font(.subheadline.bold())
                    Text(cart.email ?? "No email")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Shipping Address
                if let address = cart.shippingAddress {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Shipping Address")
                            .font(.subheadline.bold())
                        AddressDisplayView(address: address)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Shipping Method
                if let shippingMethod = cart.shippingMethods.first {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Shipping Method")
                            .font(.subheadline.bold())
                        HStack {
                            Text(shippingMethod.shippingOption?.name ?? "Standard Shipping")
                            Spacer()
                            Text(checkoutService.formatPrice(shippingMethod.price))
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Payment Method
                if let paymentSession = cart.paymentSession {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Payment Method")
                            .font(.subheadline.bold())
                        Text(paymentSession.providerId.capitalized)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Order Total
                VStack(spacing: 8) {
                    HStack {
                        Text("Subtotal")
                        Spacer()
                        Text(checkoutService.formatPrice(cart.subtotal))
                    }
                    
                    HStack {
                        Text("Shipping")
                        Spacer()
                        Text(checkoutService.formatPrice(cart.shippingTotal))
                    }
                    
                    if cart.taxTotal > 0 {
                        HStack {
                            Text("Tax")
                            Spacer()
                            Text(checkoutService.formatPrice(cart.taxTotal))
                        }
                    }
                    
                    if cart.discountTotal > 0 {
                        HStack {
                            Text("Discount")
                            Spacer()
                            Text("-\(checkoutService.formatPrice(cart.discountTotal))")
                                .foregroundColor(.green)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text(checkoutService.formatPrice(cart.total))
                            .font(.headline)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

struct OrderCompleteView: View {
    let order: Order?
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            VStack(spacing: 8) {
                Text("Order Complete!")
                    .font(.title.bold())
                
                if let order = order {
                    Text("Order #\(order.displayId)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("Thank you for your purchase. You will receive a confirmation email shortly.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Continue Shopping") {
                // Handle navigation back to store
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct CheckoutBottomBar: View {
    @EnvironmentObject var checkoutService: CheckoutService
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack {
                // Back Button
                if checkoutService.checkoutStep != .cart {
                    Button("Back") {
                        checkoutService.goToPreviousStep()
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Next/Complete Button
                Button(buttonTitle) {
                    Task {
                        if checkoutService.checkoutStep == .confirmation {
                            let order = await checkoutService.completeCart()
                            // Handle order completion
                        } else {
                            checkoutService.proceedToNextStep()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canProceed)
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private var buttonTitle: String {
        switch checkoutService.checkoutStep {
        case .cart: return "Continue to Shipping"
        case .shipping: return "Continue to Payment"
        case .payment: return "Review Order"
        case .confirmation: return "Complete Order"
        case .complete: return ""
        }
    }
    
    private var canProceed: Bool {
        switch checkoutService.checkoutStep {
        case .cart: return checkoutService.canProceedFromCart
        case .shipping: return checkoutService.canProceedFromShipping
        case .payment: return checkoutService.canProceedFromPayment
        case .confirmation: return checkoutService.canCompleteOrder
        case .complete: return false
        }
    }
}

struct AddressDisplayView: View {
    let address: Address
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let firstName = address.firstName, let lastName = address.lastName {
                Text("\(firstName) \(lastName)")
                    .font(.subheadline)
            }
            
            if let address1 = address.address1 {
                Text(address1)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let address2 = address.address2, !address2.isEmpty {
                Text(address2)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                if let city = address.city {
                    Text(city)
                }
                if let province = address.province {
                    Text(province)
                }
                if let postalCode = address.postalCode {
                    Text(postalCode)
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            if let countryCode = address.countryCode {
                Text(countryCode.uppercased())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    CheckoutView()
}