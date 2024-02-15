# Payments Vocal Assistant

This is the repository containing all code used for the Master's Thesis of the author: *Developing an AI-Powered Voice Assistant for an iOS Payment App*. 
It consists of a Voice Assistant for an iOS Payment App utilizing advanced AI models to convert user speech into in-app P2P payment operations, prioritizing user privacy through local processing, and enhancing app accessibility via an intuitive UI/UX design with SwiftUI framework.

## Repository Structure
- `/PaymentsVocalAssistant` contains a Swift framework with most of the Swift code core of the Voice Assistant
- `/PaymentsVocalAssistant_testApp` contains an iOS app project to test the Voice Assistant, which has also been released on TestFlight
- `/dataset` contains the Python scripts used to generate the artificial dataset which has been used to train the Machine Learning model behind the Voice Assistant
- `/customLMscripts` contains the Python scripts used to generate the sentence templates useful to create a custom Language Model for the iOS 17 Speech Recognizer class, fine-tuning the iOS Speech Recognition model
- `/vocalAssistant_info.txt` contains some notes useful for the design of the model


## Voice Assistant details
My Voice Assistant can help you perform the following tasks:
-  send money to another user
-  request money from another user
-  check a bank account's balance
-  check the last transactions (eventually involving a specific user or bank account)
    
The assistant works *entirely* on the user device, from voice recognition to answer generation, without sending any data over the network

### Components
- UI/UX implemented in SwiftUI
- Speech-to-Text performed with the iOS SpeechRecognizer class
- Custom Language Model created to fine-tune the iOS SpeechRecognizer class for the specific task, using the new iOS 17 APIs
- BERT preprocessor implementation in Swift
- Custom NLP model created and fine-tuned in Tensorflow (Python) to classify user transcript into actual inent and extract relevant entities (intent classification + entity extraction)
- Quantized classification model integrated into iOS using TensorflowLite SDK
- Dialogue State Tracker (DST) implemented in Swift to manage the conversation as a State Machine (application of the State Pattern)
- Text-to-Speech performed with the iOS Speech Synthesizer class

### Integration
The Voice Assistant is embedded in an independent Swift framework which can be easily integrated into any iOS app (iOS >13). The assistant is also customizable injecting some config properties, an AppContext describing the contacts and the bank accounts of the user, and a Delegate which performs the actual operations in the parent application.

### Machine Learning model
The underlying Machine Learning model has been created using the Tensorflow framework in Python, trained on Google Colab and selected after a validation phase where different configurations and hyperparameters have been taken into consideration.
The model perform two simultaneous tasks: intent recognition and entity extraction, receiving a sentence as input. The final model is made of a Small BERT encoder, and two Linear Layers (one for each task), separated by a Dropout layer.
The model has been then converted on a TensorflowLite Lite quantizized model. It occupies ~30MB and has an average inference time of ~200ms on device.
