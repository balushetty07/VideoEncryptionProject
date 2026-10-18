clear; clc; close all;

%% 1. Paths and output folder
inputFile = "input_video.mp4";
outputFolder = "preprocessing_results";

if ~isfile(inputFile)
    error("Cannot find %s. Set MATLAB Current Folder to the project folder.", inputFile);
end
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

%% 2. Read video metadata
video = VideoReader(inputFile);
durationSeconds = video.Duration;
frameWidth = video.Width;
frameHeight = video.Height;
frameRate = video.FrameRate;

% Count all readable frames without assuming duration*FPS is exact.
frameCounter = 0;
while hasFrame(video)
    readFrame(video);
    frameCounter = frameCounter + 1;
end

fprintf("\n========== ORIGINAL VIDEO METADATA ==========\n");
fprintf("Input file: %s\n", inputFile);
fprintf("Duration: %.3f seconds\n", durationSeconds);
fprintf("Width: %d pixels\n", frameWidth);
fprintf("Height: %d pixels\n", frameHeight);
fprintf("Frame rate: %.2f FPS\n", frameRate);
fprintf("Readable frames: %d\n", frameCounter);

%% 3. Read the first frame from the beginning
video = VideoReader(inputFile);
video.CurrentTime = 0;
frame = readFrame(video);

% Save/display the original frame.
fig = figure('Name','Original Frame');
imshow(frame);
title("Original Video Frame");
saveas(fig, fullfile(outputFolder, "01_original_frame.png"));

%% 4. RGB to YCbCr channel extraction
ycbcrFrame = rgb2ycbcr(frame);
Y = ycbcrFrame(:,:,1);
Cb = ycbcrFrame(:,:,2);
Cr = ycbcrFrame(:,:,3);

fig = figure('Name','YCbCr Channels');
tiledlayout(2,2);
nexttile; imshow(frame); title("Original RGB Frame");
nexttile; imshow(Y); title("Y: Luminance");
nexttile; imshow(Cb); title("Cb: Blue-difference chrominance");
nexttile; imshow(Cr); title("Cr: Red-difference chrominance");
saveas(fig, fullfile(outputFolder, "02_ycbcr_channels.png"));

%% 5. Identical-image baseline: MSE, PSNR, SNR
originalGray = im2double(rgb2gray(frame));
sameGray = originalGray;
mseIdentical = mean((originalGray(:) - sameGray(:)).^2);
signalPower = sum(originalGray(:).^2);
errorPower = sum((originalGray(:) - sameGray(:)).^2);

if mseIdentical == 0
    psnrIdentical = Inf;
else
    psnrIdentical = 10*log10(1/mseIdentical);
end
if errorPower == 0
    snrIdentical = Inf;
else
    snrIdentical = 10*log10(signalPower/errorPower);
end

fprintf("\n========== IDENTICAL-IMAGE BASELINE ==========\n");
fprintf("MSE: %g\n", mseIdentical);
fprintf("PSNR: %g dB\n", psnrIdentical);
fprintf("SNR: %g dB\n", snrIdentical);

%% 6. RGB -> YCbCr -> RGB round-trip fidelity test
% This is a color-conversion test, not encryption.
reconstructedFrame = ycbcr2rgb(ycbcrFrame);

originalImageDouble = im2double(frame);
reconstructedImageDouble = im2double(reconstructedFrame);
mseRoundTrip = mean((originalImageDouble(:) - reconstructedImageDouble(:)).^2);

if mseRoundTrip == 0
    psnrRoundTrip = Inf;
else
    psnrRoundTrip = 10*log10(1/mseRoundTrip);
end

differenceImage = imabsdiff(frame, reconstructedFrame);
maxDifference = max(differenceImage(:));
changedValues = nnz(differenceImage);
totalValues = numel(differenceImage);
percentageChanged = 100*changedValues/totalValues;

fprintf("\n========== RGB-YCbCr-RGB ROUND-TRIP ==========\n");
fprintf("MSE: %.10f\n", mseRoundTrip);
fprintf("PSNR: %.4f dB\n", psnrRoundTrip);
fprintf("Maximum channel-value difference: %d\n", maxDifference);
fprintf("Changed channel values: %d\n", changedValues);
fprintf("Total channel values: %d\n", totalValues);
fprintf("Percentage of changed channel values: %.6f%%\n", percentageChanged);

fig = figure('Name','Round-trip comparison');
tiledlayout(1,3);
nexttile; imshow(frame); title("Original");
nexttile; imshow(reconstructedFrame); title("RGB Reconstructed");
nexttile; imshow(differenceImage); title("Absolute Difference");
saveas(fig, fullfile(outputFolder, "03_roundtrip_comparison.png"));

fig = figure('Name','Amplified difference');
imshow(differenceImage * 10);
title("Amplified Difference (10x)");
saveas(fig, fullfile(outputFolder, "04_amplified_difference.png"));

%% 7. Full-video luminance statistics
video = VideoReader(inputFile);
meanLuminance = zeros(frameCounter,1);
stdLuminance = zeros(frameCounter,1);

tic;
idx = 0;
while hasFrame(video)
    currentFrame = readFrame(video);
    idx = idx + 1;
    ycbcrCurrent = rgb2ycbcr(currentFrame);
    luminance = double(ycbcrCurrent(:,:,1));
    meanLuminance(idx) = mean(luminance(:));
    stdLuminance(idx) = std(luminance(:));
end
analysisSeconds = toc;

% Defensive trim if frame count changes between passes.
meanLuminance = meanLuminance(1:idx);
stdLuminance = stdLuminance(1:idx);

overallMeanLuminance = mean(meanLuminance);
averageFrameLuminanceStd = mean(stdLuminance);

fprintf("\n========== FULL-VIDEO LUMINANCE ==========\n");
fprintf("Frames analyzed: %d\n", idx);
fprintf("Average luminance across frames: %.4f (0-255 scale)\n", overallMeanLuminance);
fprintf("Average within-frame luminance standard deviation: %.4f\n", averageFrameLuminanceStd);
fprintf("Analysis time: %.4f seconds\n", analysisSeconds);

fig = figure('Name','Mean luminance per frame');
plot(1:idx, meanLuminance, 'LineWidth', 1);
xlabel("Frame Number");
ylabel("Mean Luminance (0-255)");
title("Original Video: Mean Luminance per Frame");
grid on;
saveas(fig, fullfile(outputFolder, "05_mean_luminance_plot.png"));

%% 8. Demonstration threshold mask on the first frame
% This selects bright pixels only; it does not identify a person.
gray8 = rgb2gray(frame);
threshold = 150;
mask = gray8 > threshold;
whitePercentage = 100*nnz(mask)/numel(mask);

fprintf("\n========== DEMONSTRATION THRESHOLD MASK ==========\n");
fprintf("Threshold: %d (grayscale intensity 0-255)\n", threshold);
fprintf("White pixels: %.2f%%\n", whitePercentage);
fprintf("NOTE: This is not a valid person/privacy mask.\n");

fig = figure('Name','Threshold mask demonstration');
tiledlayout(1,3);
nexttile; imshow(frame); title("Original Frame");
nexttile; imshow(gray8); title("Grayscale");
nexttile; imshow(mask); title("Threshold Mask (threshold = 150)");
saveas(fig, fullfile(outputFolder, "06_threshold_mask_demo.png"));

%% 9. Save numeric results in a CSV file
Metric = [
    "Duration_seconds"
    "Width_pixels"
    "Height_pixels"
    "Frame_rate_FPS"
    "Readable_frames"
    "Identical_image_MSE"
    "Identical_image_PSNR_dB"
    "Identical_image_SNR_dB"
    "RGB_YCbCr_RGB_MSE"
    "RGB_YCbCr_RGB_PSNR_dB"
    "Max_channel_difference"
    "Changed_channel_values"
    "Total_channel_values"
    "Percentage_changed_channel_values"
    "Average_video_luminance"
    "Average_frame_luminance_std"
    "Luminance_analysis_time_seconds"
    "Threshold_value"
    "Threshold_mask_white_percentage"
];
Value = [
    durationSeconds
    frameWidth
    frameHeight
    frameRate
    idx
    mseIdentical
    psnrIdentical
    snrIdentical
    mseRoundTrip
    psnrRoundTrip
    maxDifference
    changedValues
    totalValues
    percentageChanged
    overallMeanLuminance
    averageFrameLuminanceStd
    analysisSeconds
    threshold
    whitePercentage
];
resultsTable = table(Metric, Value);
writetable(resultsTable, fullfile(outputFolder, "preprocessing_metrics.csv"));

%% 10. Save a MAT file with the main measurements and arrays
save(fullfile(outputFolder, "preprocessing_data.mat"), ...
    "durationSeconds","frameWidth","frameHeight","frameRate","idx", ...
    "mseIdentical","psnrIdentical","snrIdentical","mseRoundTrip", ...
    "psnrRoundTrip","maxDifference","changedValues","totalValues", ...
    "percentageChanged","overallMeanLuminance","averageFrameLuminanceStd", ...
    "analysisSeconds","threshold","whitePercentage","meanLuminance","stdLuminance");

fprintf("\nSaved results in folder: %s\n", outputFolder);
fprintf("Main files: preprocessing_metrics.csv, preprocessing_data.mat, and PNG figures.\n");
fprintf("This script performs preprocessing/baseline analysis only; no encryption is performed.\n");
