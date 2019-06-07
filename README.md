# MZRKit

Measuring objects on macOS/iOS with just a few lines of code.(WIP)

<img src="https://github.com/scchnxx/MZRKit/blob/master/etc/Example.png" />


## Drawing

```swift
import MZRKit

let mzrView = MZRView()

mzrView.makeItem(.rect)
```

## Getting Measurement Info

|Measurable          |Measurement Info       |
|--------------------|-----------------------|
|DistanceMeasurable  |distances              |
|RectangleMeasurable |width, height          |
|CircleMeasurable    |center, radius         |
|AngleMeasurable1    |angle                  |
|AngleMeasurable2    |acuteAngle, obtuseAngle|

Converse items to `Measurable` protocols above to extract measurement info.

## Rotation

```swift
let radian = MZRRadianFromDegree(90)

mzrView.rotateSelecteditems(radian)
```

## Setting Scale

Crosshair:
```swift
let fov = CGFloat(10)
let origin = MZRView.ScaleStyle.Origin.center
let division = MZRView.ScaleStyle.Division.by10

mzrView.scaleStyle = .cross(fov, origin, division)
```

Grid:
```swift
// 10x10 grid
mzrView.scaleStyle = .grid(10)
```

## Demo

### macOS

|Drawing|Scale|Rotation|
|-|-|-|
|![Item](https://github.com/scchnxx/MZRKit/blob/master/etc/Item.gif)|![Scale](https://github.com/scchnxx/MZRKit/blob/master/etc/Scale.gif)|![Rotation](https://github.com/scchnxx/MZRKit/blob/master/etc/Rotation.gif)|

### iOS

|Drawing|
|-|
|<img src="https://github.com/scchnxx/MZRKit/blob/master/etc/Item%20iOS.gif" width="250"/>|
