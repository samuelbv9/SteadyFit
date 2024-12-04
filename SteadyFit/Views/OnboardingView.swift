////
////  OnboardingView.swift
////  SteadyFit
////
////  Created by Debbie Shih on 11/20/24.
////
//
//import SwiftUI
//import HealthKit
//
//// MARK: - FitnessSurveyData
//@MainActor
//class FitnessSurveyData: ObservableObject {
//    @Published var physicalActivityPerWeek: String = "Choose frequency"
//    @Published var workRelatedActivity: String = "Choose option"
//    @Published var transportationRelatedActivity: String = "Choose option"
//    @Published var recreationalRelatedActivity: String = "Choose frequency"
//    @Published var sedentaryRelatedActivity: String = "Choose hours"
//    @Published var physicalActivityIntensity: String = "Choose intensity"
//}
//
//// MARK: - HealthKitManager
//class HealthKitManager {
//    static let shared = HealthKitManager()
//    private let healthStore = HKHealthStore()
//    
//    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
//        guard HKHealthStore.isHealthDataAvailable() else {
//            completion(false, nil)
//            return
//        }
//        
//        let vo2MaxType = HKQuantityType.quantityType(forIdentifier: .vo2Max)!
//        let restingHeartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
//        let readTypes: Set<HKObjectType> = [vo2MaxType, restingHeartRateType]
//        
//        healthStore.requestAuthorization(toShare: nil, read: readTypes, completion: completion)
//    }
//    
//    func fetchHealthData(completion: @escaping (Double?, Double?) -> Void) {
//        let vo2MaxType = HKQuantityType.quantityType(forIdentifier: .vo2Max)!
//        let restingHeartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
//        
//        let vo2MaxUnit = HKUnit.literUnit(with: .milli)
//            .unitDivided(by: HKUnit.gramUnit(with: .kilo))
//            .unitDivided(by: HKUnit.minute())
//        
//        var vo2Max: Double?
//        var restingHeartRate: Double?
//        let group = DispatchGroup()
//        
//        // Fetch VO2 Max
//        group.enter()
//        let vo2MaxQuery = HKSampleQuery(
//            sampleType: vo2MaxType,
//            predicate: nil,
//            limit: 1,
//            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
//        ) { _, results, _ in
//            if let sample = results?.first as? HKQuantitySample {
//                vo2Max = sample.quantity.doubleValue(for: vo2MaxUnit)
//            }
//            group.leave()
//        }
//        healthStore.execute(vo2MaxQuery)
//        
//        // Fetch Resting Heart Rate
//        group.enter()
//        let restingHeartRateQuery = HKSampleQuery(
//            sampleType: restingHeartRateType,
//            predicate: nil,
//            limit: 1,
//            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
//        ) { _, results, _ in
//            if let sample = results?.first as? HKQuantitySample {
//                restingHeartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
//            }
//            group.leave()
//        }
//        healthStore.execute(restingHeartRateQuery)
//        
//        group.notify(queue: .main) {
//            completion(vo2Max, restingHeartRate)
//        }
//    }
//}
//
//// MARK: - OnboardingHealthSetupView
//struct OnboardingHealthSetupView: View {
//    @State private var navigateToSurvey = false
//    @State private var healthKitError = false
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Text("Connect to Apple Health")
//                    .font(.custom("Poppins-Bold", size: 30))
//                    .padding(.top, 80)
//                
//                Text("To personalize your experience, connect to Apple Health to automatically retrieve your VO2 max and resting heart rate.")
//                    .font(.custom("Poppins", size: 20))
//                    .padding(.top, 20)
//                
//                Spacer()
//                
//                Button(action: setupAppleHealth) {
//                    Text("Set Up Apple Health")
//                        .fontWeight(.medium)
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue) // Replace with custom color if needed
//                        .cornerRadius(10)
//                }
//                .padding()
//                
//                if healthKitError {
//                    Text("Unable to retrieve data from Apple Health. Please complete the survey.")
//                        .font(.custom("Poppins", size: 16))
//                        .foregroundColor(.red)
//                        .padding(.top, 10)
//                }
//                
//                NavigationLink(destination: OnboardingSurveyView(), isActive: $navigateToSurvey) {
//                    EmptyView()
//                }
//            }
//            .padding()
//            .navigationBarBackButtonHidden(true)
//        }
//    }
//    
//    private func setupAppleHealth() {
//        HealthKitManager.shared.requestAuthorization { success, error in
//            if success {
//                HealthKitManager.shared.fetchHealthData { vo2Max, restingHeartRate in
//                    if let vo2Max = vo2Max, let restingHeartRate = restingHeartRate {
//                        sendHealthDataToBackend(vo2Max: vo2Max, restingHeartRate: restingHeartRate)
//                    } else {
//                        DispatchQueue.main.async {
//                            healthKitError = true
//                            navigateToSurvey = true
//                        }
//                    }
//                }
//            } else {
//                DispatchQueue.main.async {
//                    healthKitError = true
//                    navigateToSurvey = true
//                }
//            }
//        }
//    }
////    FIXME: SEND TO BACKEND
//    private func sendHealthDataToBackend(vo2Max: Double, restingHeartRate: Double) {
//        // Replace with your backend API call logic
//        print("Sending data to backend: VO2 Max: \(vo2Max), Resting Heart Rate: \(restingHeartRate)")
//        
//        // After sending, navigate to the survey
//        DispatchQueue.main.async {
//            navigateToSurvey = true
//        }
//    }
//}
//
//// MARK: - OnboardingSurveyView
//struct OnboardingSurveyView: View {
//    @StateObject var fitnessSurveyData = FitnessSurveyData()
//    let physicalActivityPerWeekOptions = ["Choose frequency", "0 days", "1-2 days", "3-4 days", "5-6 days", "7 days"]
//    let workRelatedActivityOptions = ["Choose option", "Yes, mostly sedentary with little physical activity", "Yes, moderately active (some walking or standing)", "Yes, very active (heavy physical labor)", "No"]
//    let transportationRelatedActivityOptions = ["Choose option", "Mostly by car or public transportation", "Often walk or bike", "Mix of walking/biking and car/public transportation"]
//    let sedentaryRelatedActivityOptions = ["Choose hours", "Less than 2 hours", "2-4 hours", "4-6 hours", "6-8 hours", "More than 8 hours"]
//    let physicalActivityIntensityOptions = ["Choose intensity", "Mostly light (e.g., walking at a casual pace)", "Mostly moderate (e.g., brisk walking, biking)", "Mostly vigorous (e.g., running, heavy lifting)", "N/a"]
//    var body: some View {
//        ZStack { // Wrap in ZStack to detect taps outside of text fields
//            VStack {
//                HeaderView()
//                ScrollView {
//                    VStack(alignment: .leading) {
//                        Text("Fitness Level Survey")
//                            .font(.custom("Poppins-Bold", size: 30))
//                            .padding(.bottom, 20)
//                        
//                        Text("How many days per week do you engage in physical activity for at least 30 minutes?")
//                            .font(.custom("Poppins", size: 20))
//                        DropdownPicker(selection: $fitnessSurveyData.physicalActivityPerWeek, options: physicalActivityPerWeekOptions)
//                        
//                        Text("Does your job require you to be physically active (e.g., walking, standing, lifting)?")
//                            .font(.custom("Poppins", size: 20))
//                        DropdownPicker(selection: $fitnessSurveyData.workRelatedActivity, options: workRelatedActivityOptions)
//                        
//                        Text("How do you usually travel to and from work or school?")
//                            .font(.custom("Poppins", size: 20))
//                        DropdownPicker(selection: $fitnessSurveyData.transportationRelatedActivity, options: transportationRelatedActivityOptions)
//                        
//                        Text("How many days per week do you engage in recreational physical activities (e.g., sports, exercise, gardening)?")
//                            .font(.custom("Poppins", size: 20))
//                        DropdownPicker(selection: $fitnessSurveyData.recreationalRelatedActivity, options: physicalActivityPerWeekOptions)
//                        
//                        Text("On average, how many hours per day do you spend sitting (e.g., working, watching TV, using a computer)?")
//                            .font(.custom("Poppins", size: 20))
//                        DropdownPicker(selection: $fitnessSurveyData.sedentaryRelatedActivity, options: sedentaryRelatedActivityOptions)
//                        Text("When you engage in physical activity, how would you describe the intensity?")
//                            .font(.custom("Poppins", size: 20))
//                        DropdownPicker(selection: $fitnessSurveyData.physicalActivityIntensity, options: physicalActivityIntensityOptions)
//                    }
//                }
//                .padding(.top, 20)
//                Spacer()
//                
//                VStack(spacing: 0) {
//                    HStack {
//                        HStack {
//                            Button(action: {
//                                GamesStore.shared.postFitnessSurvey(fitnessSurveyData)
//                                // navigateToHome = true
//                                // Trigger navigation
//                            }) {
//                                HStack {
//                                    Text("Publish")
//                                        .fontWeight(.medium)
//                                        .foregroundColor(.white)
//                                    Spacer()
//                                    Image(systemName: "arrow.right")
//                                        .resizable()
//                                        .frame(width: 25, height: 25)
//                                        .foregroundColor(.white)
//                                        .padding()
//                                }
//                            }
//                        }
//                            .padding(40)
//                            .frame(width: 410, height: 80)
//                            .background(Color.deepBlue)
//                    }
//                    .padding(20)
//                    .frame(width: 400, height: 80)
//                    .background(Color.deepBlue)
//                    NavBarView(viewIndex: 1)
//                }
//            }
//            .frame(width: 350)
//            .ignoresSafeArea()
//        }
//        .contentShape(Rectangle())
//        .onTapGesture {
//            hideKeyboard()
//        }
//        .navigationBarBackButtonHidden(true)
//    }
//}
//
//
//// MARK: - Preview
//#Preview {
//    OnboardingHealthSetupView()
//}
//
