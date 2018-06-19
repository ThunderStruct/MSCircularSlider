# CHANGELOG
The changelog for `MSCircularSlider`. Summarized release notes can be found in the [releases](https://github.com/ThunderStruct/MSCircularSlider/releases) section on GitHub

------------------------

## 1.2.2 - 19-06-2018
#### Added
  - An option to rotate the handle image to always point outwards

#### Changed
  - Minor structural improvement

## 1.2.1 - 09-02-2018
#### Fixed
  - A setter conflict occuring on earlier Swift versions

## 1.2.0 - 02-02-2018
#### Added
  - A handle image property to assign a `UIImage` to the handle(s)
  - Documentation for all exposed methods and members
  
#### Changed
  - Major `MSCircularSliderHandle` structural enhancement

#### Fixed
  - An issue that caused the `.doubleCircle` handle type to not highlight upon touch


## 1.1.1 - 28-12-2017
#### Fixed
  - Access control levels causing IB to crash
  - Podspec file configuration


## 1.1.0 - 27-12-2017
#### Added
  - Support for using `snapToLabels` concurrently with `snapToMarkers` (snaps to the nearest label or marker)
  - Multiple new members to `MSDoubleHandleCircularSlider` to customize each handle separately
  
#### Fixed
  - Issues and warnings risen from Swift updates, including errors caused by implicit access controls


## 1.0.0 - 06-10-2017
#### Fixed
  - Many inconsistencies found in the pre-release version
  - Travis CI yml file that caused build fails
  - Pod and podspec files

#### Removed
  - Removed the unneeded pod.lock file


## 0.X.X
All prerelease changes are not logged

