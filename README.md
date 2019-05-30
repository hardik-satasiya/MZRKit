# MZRKit

Measuring objects on macOS/iOS with just a few lines of code.(WIP)

## Usage

Place MZRView on your preview view.

<img src="https://github.com/scchnxx/MZRKit/blob/master/etc/Showcase.png" width="70%"/>


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

You can use switch-case-let to extract the info of a MZRItem.

```swift
let item = mzrView.items[0]
        
switch item {
case let item as DistanceMeasurable:
    print(item.distances)
    
case let item as RectangleMeasurable:
    print(item.width, item.height)
    
case let item as CircleMeasurable:
    print(item.center, item.radius)
    
case let item as AngleMeasurable1:
    print(item.angle)
    
case let item as AngleMeasurable2:
    print(item.acuteAngle, item.obtuseAngle)
    
default:
    break
}
```

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

|Drawing Items|Scale|Rotation|
|-|-|-|
|![Item](https://github.com/scchnxx/MZRKit/blob/master/etc/Item.gif)|![Scale](https://github.com/scchnxx/MZRKit/blob/master/etc/Scale.gif)|![Rotation](https://github.com/scchnxx/MZRKit/blob/master/etc/Rotation.gif)|
