clc;
clear;
close all;

% 1. Define the input video
videoPath = fullfile(pwd, "input_video.mp4");

% 2. Create a video reader
videoReader = VideoReader(videoPath);

% 3. Create an output folder for extracted frames
outputFolder = fullfile(pwd, "extracted_frames");

if ~exist(outputFolder, "dir")
    mkdir(outputFolder);
end

% 4. Initialize the frame counter
frameNumber = 0;

% 5. Read and save every available frame
while hasFrame(videoReader)

    % Read one frame from the video
    currentFrame = readFrame(videoReader);

    % Increase the frame counter
    frameNumber = frameNumber + 1;

    % Create a filename, e.g. frame_0001.png
    frameName = sprintf("frame_%04d.png", frameNumber);

    % Build the full output path
    framePath = fullfile(outputFolder, frameName);

    % Save the frame as a PNG image
    imwrite(currentFrame, framePath);

end

% 6. Display the extraction summary
fprintf("Frame extraction completed.\n");
fprintf("Frames saved: %d\n", frameNumber);
fprintf("Output folder: %s\n", outputFolder);