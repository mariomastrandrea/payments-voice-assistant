# Payments Vocal Assistant

This is the repository containing all code used for the Master's Thesis of the author. It consists in the integration of an AI-powered Vocal Assistant into an iOS app dealing with P2P payments, to convert user speech into actual in-app operations, leveraging local processing to enhance user privacy and create an intuitive UI/UX in SwiftUI

## Repository Structure
- `/dataset` contains the Python scripts used to generate the artificial dataset which has been used to train the Machine Learning model behind the Vocal Assistant
- `/model` contains the TF Lite models generated during the model selection phase
- `/AaniVocalAssistant` contains the Swift Package with most of the Swift code core of the Vocal Assistant
- `/AaniVocalAssistant_testApp` contains an iOS app project to test the VA Swift Package
- `/vocalAssistant_info.txt` contains some notes useful for the design of the model

