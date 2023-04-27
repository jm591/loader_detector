[![Gem Version](https://badge.fury.io/rb/loader_detector.svg)](https://badge.fury.io/rb/loader_detector)

# loader_detector

## Introduction
loader_detector is a tool developed to increase the efficiency of automated test processes. It can be used when some form of loader is used to bypass some loaders that need to be finished so that testing can continue. The aim is to determine whether the loader is still running by counting the pixel changes on the screen. For that to work, it needs a loader that constantly changes some pixels or at least a loader that changes some pixels at constant time intervals.

### Methodology
The idea behind loader_detector is to quickly take screenshots of a given window and compare these screenshots pixel by pixel to detect changes. This must be done very efficiently so that it is still faster than using timeouts.

The screenshot comparison part of the algorithm is contained in loader_detector. It requires paths to two images in the [pam](https://netpbm.sourceforge.net/doc/pam.html) image format. Pam is an uncompressed binary image format mainly used to bypass a time-consuming decoding part within the comparison algorithm.\
For efficiency reasons, the actual comparison part is written in C. It compares the red, green and blue values for each pixel of the two images and adds up any difference. This means that the total number of differences can be up to 3x as large as the total number of pixels of the source images.

For the screenshot part, a driver is needed that takes the screenshots and returns the path to them. By default, loader_detector includes a driver that works for Linux and uses [shotgun_ruby](https://github.com/jm591/shotgun_ruby) as the screenshot tool.

## Usage

### Initialisation
To use loader_detector, we need an instance of the Detector class. The initialisation function requires several parameters. The first one that needs to be set is the driver that is responsible for taking the screenshots.
The other parameters, threshold, frame counter and timeout, have a default value that can be overwritten.

2. Threshold: The threshold sets the number of detected differences required before the algorithm determines that there is a large enough change between two images. The default value is 0

3. Frame Count: The frame count determines how many times in a row the comparison algorithm must detect a change between the images (meaning differences > threshold) before it detects that the loader is no longer running, so the loading process must be completed. The default value is 10.

4. Timeout: The timeout sets the maximum number of seconds the algorithm will try to detect if the loader stops running. The default value is 10.

### Driver
The driver is the part of the programme that provides the screenshot functionality. It is used by the comparison algorithm to take a screenshot at each iteration of the comparison loop, which is then used for comparison. Currently there is one driver, the RubyShotgunDriver, that can take screenshots on Linux systems that use X11.

Custom drivers can be implemented. They must inherit from the ScreenshotDriver. In addition, a method "pam_screenshot_file( file_path )" must be implemented that takes the path to the designated screenshot file as a parameter, creates a screenshot and saves it under the specified path.

### Methods
After initialisation, you can call the wait_until_content_loaded() method. First, 2 temporary files are created in which the screenshots can be stored and a first screenshot is taken with the driver before the comparison loop begins. The loop takes a second screenshot, tries to detect differences between the screenshots and keeps the newer screenshot at each iteration.


## Installation

### Requirements
The build in Screenshot driver works for Linux systems that use X11.\
The following libraries are required:



### RubyGems
loader_detector can be installed with RubyGems:

```
gem install loader_detector
```

### Rake
The second possibility is to install it manually with the help of the Rakefile:
```
rake compile build install 
```
