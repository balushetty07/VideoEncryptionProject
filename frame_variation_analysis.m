clc;
clear;
close all;

% 1. Open the original video
videoPath = fullfile(pwd, "input_video.mp4");
videoReader = VideoReader(videoPath);

% 2. Initialize variables
previousGray = [];
frameNumber = 0;
madValues = [];

% 3. Read the video frame by frame
while hasFrame(videoReader)

    % Read the next RGB frame
    rgbFrame = readFrame(videoReader);

    % Convert it to grayscale
    grayFrame = rgb2gray(rgbFrame);

    % Convert to double for safe subtraction
    grayFrame = double(grayFrame);

    frameNumber = frameNumber + 1;

    % Compare with the previous frame
    if ~isempty(previousGray)

        difference = abs(grayFrame - previousGray);

        % Mean absolute difference for this pair
        currentMAD = mean(difference, "all");

        madValues(end + 1, 1) = currentMAD;
    end

    % Keep the current frame for the next comparison
    previousGray = grayFrame;
end

% 4. Display the results
fprintf("Frames analyzed: %d\n", frameNumber);
fprintf("Consecutive frame pairs: %d\n", numel(madValues));
fprintf("Average frame-to-frame MAD: %.4f\n", mean(madValues));
fprintf("Minimum MAD: %.4f\n", min(madValues));
fprintf("Maximum MAD: %.4f\n", max(madValues));

% 5. Plot the variation over time
figure;
plot(1:numel(madValues), madValues, "b-");
xlabel("Consecutive Frame Pair");
ylabel("Mean Absolute Difference");
title("Frame-to-Frame Grayscale Variation");
grid on;

% 6. Save the results
outputFolder = fullfile(pwd, "preprocessing_results");

if ~exist(outputFolder, "dir")
    mkdir(outputFolder);
end

save(fullfile(outputFolder, "frame_variation_data.mat"), ...
    "madValues", "frameNumber");

exportgraphics(gcf, ...
    fullfile(outputFolder, "frame_variation_plot.png"), ...
    "Resolution", 300);

fprintf("Results saved in: %s\n", outputFolder);