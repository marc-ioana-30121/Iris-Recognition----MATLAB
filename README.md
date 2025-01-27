
# Iris Recognition System in MATLAB

This repository implements an advanced iris recognition system using MATLAB. The project focuses on processing, analyzing, and comparing iris images with a database, ensuring precise and efficient recognition through image preprocessing and feature extraction techniques.

## Features

- **Interactive User Interface**:
  - Load and view iris images for testing.
  - Recognize and match iris images from a pre-defined database.
  - Add or delete images from the database directly through the interface.

- **Image Preprocessing**:
  - Convert input images to grayscale for standardization.
  - Apply Gaussian filters for noise reduction and image smoothing.
  - Perform gamma correction to enhance image contrast.
  - Use Fourier transform-based low-pass filtering for noise suppression.

- **Feature Extraction**:
  - Detect iris contours using combined Canny and Sobel edge detection.
  - Normalize iris regions and extract unique features using Gabor filters.
  - Represent iris features as a vector for comparison.

- **Matching Algorithm**:
  - Compare feature vectors using the Euclidean distance metric.
  - Identify the closest match or indicate no match if the distance exceeds a defined threshold.

## Algorithm Workflow

1. **Image Acquisition**:
   - Test images are loaded via the interactive interface.
   - Database images are stored in the `iris_database` directory.

2. **Preprocessing**:
   - Input images are processed through a sequence of steps:
     - Grayscale conversion.
     - Gaussian smoothing and gamma correction.
     - Fourier transform for noise filtering.
     - Edge detection (Canny + Sobel) to isolate iris regions.
     - Hough Transform for iris localization.

3. **Normalization and Feature Extraction**:
   - The detected iris region is normalized to a standard size.
   - Unique features are extracted using Gabor filters.

4. **Matching and Recognition**:
   - The extracted features of the test image are compared with features of database images.
   - The system identifies the closest match or reports no match if no suitable candidate is found.

5. **Database Management**:
   - Add new iris images to expand the database.
   - Delete unwanted images directly from the GUI.

## Installation and Requirements

### **Software Requirements**
- MATLAB R2020a or newer.
- Image Processing Toolbox for MATLAB.

### **Steps to Run**
1. Clone the repository:
   ```bash
   git clone (https://github.com/marc-ioana-30121/Iris-Recognition----MATLAB)

## Future Enhancements
- Add machine learning models to enhance feature extraction and classification.
- Support real-time iris acquisition from camera feeds.
- Expand the database to handle more diverse conditions (e.g., occlusion, lighting changes).

## Acknowledgments
- IIT Delhi Iris Database: This project uses iris images from the IIT Delhi database for testing and validation.(- **IIT Delhi Iris Database**: The dataset used in this project can be accessed [here](https://www4.comp.polyu.edu.hk/~csajaykr/IITD/Database_Iris.htm).
)
- MATLAB Image Processing Toolbox: Leveraging advanced image processing tools for accurate recognition.
