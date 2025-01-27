function [normalizedIris, gaborFeatures, success, steps] = preprocessAndExtractIrisWithGabor(image, showSteps)
    steps = {}; 
    try
        % Step 1: Convert to grayscale
        if size(image, 3) == 3
            grayImage = rgb2gray(image);
        else
            grayImage = image;
        end
        steps{end+1} = grayImage; % Save step
        if showSteps
            figure; imshow(grayImage); title('Step 1: Grayscale Image');
        end

        % Step 2: Gaussian smoothing
        gaussianKernel = fspecial('gaussian', [5 5], 2);
        smoothedImage = imfilter(grayImage, gaussianKernel, 'symmetric');
        steps{end+1} = smoothedImage; % Save step
        if showSteps
            figure; imshow(smoothedImage, []); title('Step 2: Gaussian Smoothing');
        end

        % Step 3: Gamma Correction
        gammaCorrectedImage = imadjust(smoothedImage, [], [], 0.8);
        steps{end+1} = gammaCorrectedImage;
        if showSteps
            figure; imshow(gammaCorrectedImage, []); title('Step 3: Gamma Correction');
        end

        % Step 4: Fourier Transform for Low-Pass Filtering
        fftImage = fft2(double(gammaCorrectedImage));
        fftShifted = fftshift(fftImage);
        [rows, cols] = size(fftShifted);
        cutoff = 50; % Low-pass filter cutoff
        [X, Y] = meshgrid(1:cols, 1:rows);
        centerX = cols / 2;
        centerY = rows / 2;
        lowPassMask = sqrt((X - centerX).^2 + (Y - centerY).^2) <= cutoff;
        filteredFFT = fftShifted .* lowPassMask;
        filteredImage = abs(ifft2(ifftshift(filteredFFT)));
        steps{end+1} = filteredImage;
        if showSteps
            figure; imshow(filteredImage, []); title('Step 4: Fourier Low-Pass Filtering');
        end

        % Step 5: Edge Detection (Canny + Sobel)
        edgesCanny = edge(filteredImage, 'canny', [0.04, 0.12]);
        edgesSobel = edge(filteredImage, 'sobel');
        combinedEdges = edgesCanny | edgesSobel;
        steps{end+1} = double(combinedEdges);
        if showSteps
            figure; imshow(combinedEdges); title('Step 5: Combined Edges (Canny + Sobel)');
        end

        % Step 6: Hough Transform for Iris Detection
        minRadius = 60;
        maxRadius = 120;
        [centers, radii, ~] = imfindcircles(combinedEdges, [minRadius maxRadius], ...
            'ObjectPolarity', 'dark', 'Sensitivity', 0.95, 'EdgeThreshold', 0.01);

        if isempty(centers)
            success = false;
            normalizedIris = [];
            gaborFeatures = [];
            return;
        end

        if showSteps
            figure; imshow(grayImage);
            viscircles(centers(1, :), radii(1), 'EdgeColor', 'b');
            title('Step 6: Iris Detected with Hough Transform');
        end

        % Step 7: Extract and Normalize the Iris Region
        irisCenter = centers(1, :);
        irisRadius = radii(1);
        [rows, cols] = size(grayImage);
        [X, Y] = meshgrid(1:cols, 1:rows);
        mask = sqrt((X - irisCenter(1)).^2 + (Y - irisCenter(2)).^2) <= irisRadius;
        irisRegion = grayImage;
        irisRegion(~mask) = 0;
        normalizedIris = imresize(irisRegion, [256, 256]);
        normalizedIris = mat2gray(normalizedIris);
        steps{end+1} = normalizedIris;
        if showSteps
            figure; imshow(normalizedIris); title('Step 7: Normalized Iris Region');
        end

        % Step 8: Gabor Filter Feature Extraction
        wavelength = 4; 
        orientation = 0:45:135; 
        gaborArray = gabor(wavelength, orientation);
        gaborMag = imgaborfilt(normalizedIris, gaborArray);

        gaborFeatures = [];
        for j = 1:length(gaborArray)
            gaborFeatures = [gaborFeatures; mean2(gaborMag(:, :, j))];
        end
        steps{end+1} = gaborFeatures;

        success = true;
    catch
        success = false;
        normalizedIris = [];
        gaborFeatures = [];
        steps = {}; % Clear steps on failure
    end
end
