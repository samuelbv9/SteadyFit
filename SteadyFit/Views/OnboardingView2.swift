//
//  HealthKitManager.swift
//  SteadyFit
//
//  Created by Austin Jordan on 12/2/24
//

import SwiftUI
import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        let vo2MaxType = HKQuantityType.quantityType(forIdentifier: .vo2Max)!
        let restingHeartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
        let readTypes: Set<HKObjectType> = [vo2MaxType, restingHeartRateType]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes, completion: completion)
    }
    
    func fetchHealthData(completion: @escaping (Double?, Double?) -> Void) {
        let vo2MaxType = HKQuantityType.quantityType(forIdentifier: .vo2Max)!
        let restingHeartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
        
        let vo2MaxUnit = HKUnit.literUnit(with: .milli)
            .unitDivided(by: HKUnit.gramUnit(with: .kilo))
            .unitDivided(by: HKUnit.minute())
        
        var vo2Max: Double?
        var restingHeartRate: Double?
        let group = DispatchGroup()
        
        // Fetch VO2 Max
        group.enter()
        let vo2MaxQuery = HKSampleQuery(
            sampleType: vo2MaxType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
        ) { _, results, _ in
            if let sample = results?.first as? HKQuantitySample {
                vo2Max = sample.quantity.doubleValue(for: vo2MaxUnit)
            }
            group.leave()
        }
        healthStore.execute(vo2MaxQuery)
        
        // Fetch Resting Heart Rate
        group.enter()
        let restingHeartRateQuery = HKSampleQuery(
            sampleType: restingHeartRateType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
        ) { _, results, _ in
            if let sample = results?.first as? HKQuantitySample {
                restingHeartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            }
            group.leave()
        }
        healthStore.execute(restingHeartRateQuery)
        
        group.notify(queue: .main) {
            completion(vo2Max, restingHeartRate)
        }
    }
}

// MARK: - Preview Test View
struct HealthKitPreviewView: View {
    @State private var vo2Max: Double? = nil
    @State private var restingHeartRate: Double? = nil
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack {
            Text("HealthKit Preview")
                .font(.headline)
                .padding()
            
            if let vo2Max = vo2Max {
                Text("VO2 Max: \(vo2Max, specifier: "%.2f") mL/kg/min")
            } else {
                Text("VO2 Max: Not Available")
            }
            
            if let restingHeartRate = restingHeartRate {
                Text("Resting Heart Rate: \(restingHeartRate, specifier: "%.0f") bpm")
            } else {
                Text("Resting Heart Rate: Not Available")
            }
            
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
            
            Button("Fetch Health Data") {
                fetchHealthData()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    private func fetchHealthData() {
        HealthKitManager.shared.requestAuthorization { success, error in
            if success {
                HealthKitManager.shared.fetchHealthData { vo2MaxResult, restingHeartRateResult in
                    DispatchQueue.main.async {
                        self.vo2Max = vo2MaxResult
                        self.restingHeartRate = restingHeartRateResult
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = error?.localizedDescription ?? "Authorization failed"
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    HealthKitPreviewView()
}
