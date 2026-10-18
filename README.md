# Pixel-Level Video Encryption for Privacy Protection

## Overview

This project explores a MATLAB-based preprocessing pipeline for video analysis as an initial stage of a pixel-level video encryption and privacy protection system.

The current implementation focuses on video frame extraction, color-space analysis, image reconstruction, luminance statistics, threshold-mask experimentation, and frame-to-frame variation analysis.

**Project status:** Preprocessing baseline completed. Person segmentation, encryption/decryption, and security evaluation are future stages.

## Objectives

- Extract and inspect video frames using MATLAB.
- Study RGB and YCbCr color representations.
- Measure reconstruction error using MSE and PSNR.
- Analyze luminance and grayscale intensity distributions.
- Examine frame-to-frame variation.
- Prepare a baseline for future privacy-mask generation and pixel-level encryption.

## Technologies

- MATLAB
- Digital image and video processing
- Image quality metrics and statistical analysis
- Git and GitHub for version control

## Input Video

| Property | Value |
|---|---|
| Resolution | 1920 × 1080 |
| Frame rate | 24 FPS |
| Duration | Approximately 11.54 seconds |
| Frames analyzed | 277 |

The original video is not included in this public repository. Use a video you own or have permission to process when reproducing the experiments.

## Preprocessing Results

| Experiment | Result |
|---|---|
| Frames analyzed | 277 |
| Average luminance | 112.3382 on a 0–255 scale |
| Average within-frame luminance standard deviation | 46.3106 |
| RGB → YCbCr → RGB round-trip MSE | 0.0000063627 |
| RGB → YCbCr → RGB round-trip PSNR | 51.9636 dB |
| Maximum channel-value difference after round trip | 2 |
| Average frame-to-frame mean absolute difference | 15.3137 |

These measurements describe the preprocessing experiments on the input video used during development. Results may vary with a different video, MATLAB version, or processing configuration.

## Current Workflow

1. Read the input video.
2. Extract and inspect video frames.
3. Convert RGB images to YCbCr and inspect the component channels.
4. Reconstruct RGB images and evaluate reconstruction error.
5. Analyze luminance and grayscale statistics.
6. Examine frame-to-frame variation.
7. Save metrics and visualization figures.

## Important Limitations

- The threshold-mask experiment is a basic intensity-threshold demonstration, not person segmentation.
- Preprocessing alone does not provide privacy protection.
- The project does not yet implement the complete encryption/decryption pipeline.
- Encryption strength, decryption correctness, and security against attacks have not yet been evaluated.

## Planned Work

- Implement person segmentation.
- Generate and validate privacy masks.
- Apply pixel-level encryption to the selected regions.
- Implement authorized decryption and reconstruction.
- Evaluate visual quality, processing time, and security-related metrics.

## Reproducibility

1. Install MATLAB with the required video and image-processing functionality for the scripts used.
2. Clone or download this repository.
3. Obtain a suitable input video that you have permission to process.
4. Update the input-video path in the MATLAB scripts to match your local setup.
5. Run the preprocessing scripts and compare the resulting metrics and figures.

Exact script execution order and toolbox requirements will be documented as the workflow is finalized.

## Author

Balu
