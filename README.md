# Payments Vocal Assistant

This is the repository containing all code used for the Master's Thesis of the author: *Developing an AI-Powered Voice Assistant for an iOS Payment App*. 
It consists of a Voice Assistant for an iOS Payment App utilizing advanced AI models to convert user speech into in-app P2P payment operations, prioritizing user privacy through local processing, and enhancing app accessibility via an intuitive UI/UX design with SwiftUI framework.

## Repository Structure
- `/PaymentsVocalAssistant` contains a Swift framework with most of the Swift code core of the Voice Assistant
- `/PaymentsVocalAssistant_testApp` contains an iOS app project to test the Voice Assistant, which has also been released on TestFlight
- `/dataset` contains the Python scripts used to generate the artificial dataset which has been used to train the Machine Learning model behind the Voice Assistant
- `/customLMscripts` contains the Python scripts used to generate the sentence templates useful to create a custom Language Model for the iOS 17 Speech Recognizer class, fine-tuning the iOS Speech Recognition model
- `/vocalAssistant_info.txt` contains some notes useful for the design of the model


## Voice Assistant details
My Voice Assistant can help you perform the following tasks:
-  send money to another user
-  request money from another user
-  check a bank account's balance
-  check the last transactions (eventually involving a specific user or bank account)
    
The assistant works *entirely* on the user device, from voice recognition to answer generation, without sending any data over the network

