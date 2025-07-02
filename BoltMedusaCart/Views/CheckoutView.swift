//
//  CheckoutView.swift
//  BoltMedusaCart
//
//  Created by Ricardo Bento on 28/06/2025.
//

import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject var checkoutService: CheckoutService
    @StateObject private var paymentProvidersService = PaymentProvidersService()
    @State private var showingOrderComplete = false
    @State private var completedOrder: Order?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let cart = checkoutService.currentCart {
                    // Progress Indicator
                    CheckoutProgressView(currentStep: checkoutService.checkoutStep)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    
                    Divider()
                    
                    // Content based on current step
                    ScrollView {
                        VStack(spacing: 24) {
                            switch checkoutService.checkoutStep {
                            case .cart:
                                CartStepView(cart: cart)
                            case .shipping:
                                ShippingStepView()
                            case .payment:
                                PaymentStepView()
                                    .environmentObject(paymentProvidersService)
                            case .confirmation:
                                ConfirmationStepView(cart: cart)
                            case .complete:
                                OrderCompleteView(order: completedOrder)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                    }
                    
                    // Bottom Action Button
                    if checkoutService.checkoutStep != .complete {
                        VStack(spacing: 16) {
                            Divider()
                            
                            CheckoutActionButton(
                                cart: cart,
                                onComplete: { order in
                                    completedOrder = order
                                    showingOrderComplete = true
                                }
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                        }
                        .background(Color(.systemBackground))
                    }
                } else {
                    // Empty Cart State
                    VStack(spacing: 24) {
                        Image(systemName: "cart")
                            .font(.system(size: 64))
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 8) {
                            Text("Your cart is empty")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Add some products to get started")
                                .foregroundStyle(.secondary)
                        }
                        
                        Button("Start Shopping") {
                            // Navigate to products
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                // Initialize checkout if needed
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
        HStack(spacing: 8) {
            ForEach(Array(CheckoutService.CheckoutStep.allCases.enumerated()), id: \.offset) { index, step in
                let isActive = step == currentStep
                let isCompleted = CheckoutService.CheckoutStep.allCases.firstIndex(of: currentStep)! > index
                
                HStack(spacing: 8) {
                    // Step Circle
                    ZStack {
                        Circle()
                            .fill(isActive ? Color.blue : (isCompleted ? Color.green : Color(.systemGray4)))
                            .frame(width: 24, height: 24)
                        
                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        } else {
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(isActive ? .white : .secondary)
                        }
                    }
                    
                    // Step Title
                    Text(step.title)
                        .font(.caption)
                        .fontWeight(isActive ? .semibold : .medium)
                        .foregroundStyle(isActive ? .primary : .secondary)
                    
                    // Connector Line
                    if index < CheckoutService.CheckoutStep.allCases.count - 1 {
                        Rectangle()
                            .fill(isCompleted ? Color.green : Color(.systemGray4))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

struct CartStepView: View {
    let cart: Cart
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Review Your Items")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                ForEach(cart.items) { item in
                    CartItemRow(item: item)
                }
            }
            
            // Cart Summary
            CartSummaryView(cart: cart)
        }
    }
}

struct CartItemRow: View {
    let item: LineItem
    @EnvironmentObject var checkoutService: CheckoutService
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            AsyncImage(url: URL(string: item.thumbnail ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    )
            }
            .frame(width: 60, height: 60)
            .clipped()
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                if let description = item.description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Text("Qty: \(item.quantity)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(checkoutService.formatPrice(item.total))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Button("Remove") {
                    Task {
                        await checkoutService.removeLineItem(lineItemId: item.id)
                    }
                }
                .font(.caption)
                .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 8)
    }
}

struct CartSummaryView: View {
    let cart: Cart
    @EnvironmentObject var checkoutService: CheckoutService
    
    var body: some View {
        VStack(spacing: 12) {
            Divider()
            
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
                
                HStack {
                    Text("Tax")
                    Spacer()
                    Text(checkoutService.formatPrice(cart.taxTotal))
                }
                
                if cart.discountTotal > 0 {
                    HStack {
                        Text("Discount")
                        Spacer()
                        Text("-\(checkoutService.formatPrice(cart.discountTotal))")
                            .foregroundStyle(.green)
                    }
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            Divider()
            
            HStack {
                Text("Total")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(checkoutService.formatPrice(cart.total))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ShippingStepView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Shipping Information")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Shipping options will be implemented here")
                .foregroundStyle(.secondary)
        }
    }
}

struct PaymentStepView: View {
    @EnvironmentObject var paymentProvidersService: PaymentProvidersService
    @EnvironmentObject var checkoutService: CheckoutService

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Payment Information")
                .font(.title2)
                .fontWeight(.semibold)
            
            if paymentProvidersService.isLoading {
                ProgressView()
            } else if let error = paymentProvidersService.error {
                Text(error)
                    .foregroundStyle(.red)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(paymentProvidersService.paymentProviders) { provider in
                        Text(provider.id)
                    }
                }
            }
        }
        .task {
            if let cartId = checkoutService.currentCart?.id {
                await paymentProvidersService.retrievePaymentProviders(cartId: cartId)
            }
        }
    }
}

struct ConfirmationStepView: View {
    let cart: Cart
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Order Confirmation")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Please review your order before completing the purchase")
                .foregroundStyle(.secondary)
            
            CartSummaryView(cart: cart)
        }
    }
}

struct OrderCompleteView: View {
    let order: Order?
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
            
            VStack(spacing: 8) {
                Text("Order Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                
                if let order = order {
                    Text("Order #\(order.displayId)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Text("Thank you for your purchase")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CheckoutActionButton: View {
    let cart: Cart
    let onComplete: (Order?) -> Void
    @EnvironmentObject var checkoutService: CheckoutService
    
    var body: some View {
        Button(action: handleAction) {
            HStack {
                if checkoutService.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text(buttonTitle)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(canProceed ? Color.blue : Color.gray)
            .cornerRadius(16)
        }
        .disabled(!canProceed || checkoutService.isLoading)
    }
    
    private var buttonTitle: String {
        switch checkoutService.checkoutStep {
        case .cart:
            return "Continue to Shipping"
        case .shipping:
            return "Continue to Payment"
        case .payment:
            return "Review Order"
        case .confirmation:
            return "Complete Order"
        case .complete:
            return "Order Complete"
        }
    }
    
    private var canProceed: Bool {
        switch checkoutService.checkoutStep {
        case .cart:
            return checkoutService.canProceedFromCart
        case .shipping:
            return checkoutService.canProceedFromShipping
        case .payment:
            return checkoutService.canProceedFromPayment
        case .confirmation:
            return checkoutService.canCompleteOrder
        case .complete:
            return false
        }
    }
    
    private func handleAction() {
        Task {
            switch checkoutService.checkoutStep {
            case .cart, .shipping, .payment:
                checkoutService.proceedToNextStep()
            case .confirmation:
                let order = await checkoutService.completeCart()
                onComplete(order)
            case .complete:
                break
            }
        }
    }
}

#Preview {
    CheckoutView()
        .environmentObject(CheckoutService())
}