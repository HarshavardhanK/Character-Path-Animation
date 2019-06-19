//: A UIKit based Playground for presenting user interface
  
import UIKit

var hello = "Hello, Playground!"

extension Array {
    
    func slice(from: Int, to: Int) -> Array {
        
        if to >= self.count {
            return Array(self[from..<self.count])
        }
        
        return Array(self[from..<to])
        
    }
}

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

class CircleView: UIView {
    
    override func draw(_ rect: CGRect) {
        //TODO: Draw a circle..
        
        let path = UIBezierPath()
        
        let center = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
        let radius = 150.0
        
        path.move(to: CGPoint(x: center.x + CGFloat(radius), y: center.y + CGFloat(radius)))
        
        for i in stride(from: 0.0, to: 361.0, by: 1) {
            
            let rad = i * Double.pi / 180.0
            let x = Double(center.x) + radius * cos(rad)
            let y = Double(center.y) + radius * sin(rad)
            
            //let x1 = radius * cos(rad)
            //let y1 = radius * sin(rad)
            
            path.addLine(to: CGPoint(x: x, y: y))
            
        }
        
        UIColor.red.setStroke()
        path.lineWidth = 4
        path.stroke()
        
       // path.addCurve(to: CGPoint(x: 100, y: 150), controlPoint1: CGPoint(x: 50, y: 80), controlPoint2: CGPoint(x: 80, y: 100))
        
        path.stroke()
        
    }
    
    
}

func displayCircleView() {
    
    let view = CircleView(frame: CGRect(x: 0, y: 0, width: 600, height: 600))
    view.backgroundColor = UIColor.white
    
}

displayCircleView()

func toCGPoint(x: Double, y: Double) -> CGPoint {
    return CGPoint(x: x, y: y)
}

func arrayPoints_toCGPoint(array: [Double]) -> [CGPoint] {
    
    var pointArray = [CGPoint]()
    let length = array.count
    
    for i in stride(from: 0, to: length, by: 2) {
        pointArray.append(CGPoint(x: array[i], y: array[i+1]))
    }
    
    return pointArray
    
}

class Path {
    
    private var _cubicCurves: [CubicBezierCurve]?
    private var _lines: [Line]?
    private var _moveTo: CGPoint?
    
    private var _pathNodes: [Int]
    private var _points: [CGPoint]
    
    private var _center: CGPoint?
    
    //PATH PROPERTY
    private var _path: UIBezierPath?
    
    var pathNodes: [Int] {
        return _pathNodes
    }
    
    var points: [CGPoint] {
        return _points
    }
    
    var cubicCurves: [CubicBezierCurve]? {
        
        if let _cubeCurves = _cubicCurves {
            return _cubeCurves
            
        } else {
            print("No cubic curves found")
            return nil
        }
    }
    
    var moveTo: CGPoint? {
        
        if let movesTo = _moveTo {
            return movesTo
            
        } else {
            print("No moveTo point")
            return nil
        }
    }
    
    var center: CGPoint? {
        
        if let __center = _center {
            return __center
            
        } else {
            print("No center point defined")
            return nil
        }
    }
    
    var isPathClosed: Bool {
        
        if pathNodes.contains(3) {
            return true
        }
        
        return false
        
    }
    
    var hasCubicCurves: Bool {
        
        if pathNodes.contains(2) {
            return true
        }
        
        return false
    }
    
    var hasLines: Bool {
        
        if pathNodes.contains(1) {
            return true
        }
        
        return false
    }
    
    var path: UIBezierPath? {
        
        if let __path = _path {
            return __path
            
        } else {
            print("No path could be formed. Check your points and path nodes")
            return nil
        }
    }
    
    init(pathNodes: [Int], points: [CGPoint], center: CGPoint?) {
        
        self._pathNodes = pathNodes
        self._points = points
        self._path = UIBezierPath()
      //  _cubicCurves = [CubicBezierCurve]
        
        if hasCubicCurves {
            _cubicCurves = [CubicBezierCurve]()
        }
        
        if hasLines {
            _lines = [Line]()
        }
        
        guard let __center = center else {
            print("No center found..")
            return //CGPoint(x: 0.0, y: 0.0)
        }
        
        if pathNodes.contains(0) {
            _moveTo = points[0] + __center
        }
        
        var pointIndex = 0
        
        //Check BOOLEANS
        var isMoveToFound = false
        
        for node in pathNodes {
            
            print(node)
            
            if node == 0 {
                isMoveToFound = true
                _moveTo = points[pointIndex]
                pointIndex += 1
            }
            
            if node == 1 {
                
                let line = Line(from: points[pointIndex - 1], to: points[pointIndex])
                _lines?.append(line)
                
                pointIndex += 1
            }
            
            if node == 2 {
                
                _cubicCurves?.append(CubicBezierCurve(pointArray: points.slice(from: pointIndex, to: pointIndex + 3)))
                pointIndex += 3
            }
            
        }
        
        if !hasCubicCurves {
            print("No cubic curves found in \(points)")
        }
        
        if !isMoveToFound {
            print("No moveTo point found in \(pathNodes)")
        }
        
        if !hasLines {
            print("Contains no straight line")
        }
    
    }
    
    func offset(offset: CGPoint) {
        _points = _points.map{$0 + offset}
        _moveTo = _moveTo! + offset
    }
    
    
    func addPaths() {
        
        if let __moveTo = _moveTo {
            self._path?.move(to: __moveTo)
            
        } else {
            print("No moveTo point defined.. Moving to the origin..")
            self._path?.move(to: CGPoint(x: 0, y: 0))
        }
        
        //Adding an array of cubic curves.. Test it out, read docs..
        
        if let curves = _cubicCurves {
            
            for curve in curves {
                self._path?.addCurve(to: curve.to, controlPoint1: curve.controlPoint1, controlPoint2: curve.controlPoint2)
            }
            
        }
        
        if let lines = _lines {
            
            for line in lines {
                self.path?.move(to: line.from)
                self.path?.addLine(to: line.to)
            }
        }
        
        if isPathClosed {
            self._path?.close()
        }
        
    }
    
    func addPath(curve: CubicBezierCurve, path: inout UIBezierPath) {
        
       // let path = UIBezierPath()
        path.move(to: moveTo!)
        
        path.addCurve(to: curve.to, controlPoint1: curve.controlPoint1, controlPoint2: curve.controlPoint2)
        path.stroke()
    }
    
    func printPath() {
        
        for curve in cubicCurves! {
            print(curve.description())
        }
    }
    
    
    
}

struct Line {
    
    private var _from: CGPoint
    private var _to: CGPoint
    
    init(from: CGPoint, to: CGPoint) {
        self._from = from
        self._to = to
    }
    
    var from: CGPoint {
        return _from
    }
    
    var to: CGPoint {
        return _to
    }
}

struct CubicBezierCurve {
    
    var controlPoint1: CGPoint
    var controlPoint2: CGPoint
    var to: CGPoint
    
    init(pointArray: [CGPoint]) {
        
        print("Array size is \(pointArray.count)")
        print("Point array is \(pointArray)")
        
        controlPoint1 = pointArray[0]
        controlPoint2 = pointArray[1]
        to = pointArray[2]
    }
    
    func description() -> String {
        return "to: \(to) CP1: \(controlPoint1) CP2: \(controlPoint2)"
    }
    
}

func iteratePathNodes(pathNodes: [Double]) {
    
}



let points = [106.147,600.321,140.665,654.788,220.013,655.426,276.563,629.77,338.257,601.781,353.706,527.461,319.624,472.874,297.437,437.337,255.572,425.389,213.271,428.509,190.594,430.181,168.159,433.917,147.741,445.745,91.6268,478.252,71.0627,544.959,106.147,600.321]

let pathNodes = [0,2,2,2,2,2,3]

let points2 = [250.652,
               429.312,
               251.962,
               413.386,
               240.586,
               413.386,
               237.965,
               384.288,
               227.231,
               384.288,
               223.3,
               413.386,
               213.272,
               413.386,
               213.272,
               428.509,
               213.272,
               428.509,
               250.652,
               429.312,
               250.652,
               429.312]
let pathNodes2 = [0,
                  1,
                  1,
                  1,
                  1,
                  1,
                  1,
                  1,
                  2,
                  3]

let points3 = [227.232,
               388.238,
               227.232,
               388.238,
               122.361,
               352.137,
               48.2825,
               371.161,
               -25.7957,
               390.185,
               185.438,
               394.627,
               185.438,
               394.627,
               185.438,
               394.627,
               210.894,
               396.41,
               227.232,
               388.238]
let pathNodes3 = [0,
                  2,
                  2,
                  2,
                  3]

let points4 = [237.965,
               392.512,
               257.356,
               400.663,
               407.514,
               414.129,
               421.503,
               399.503,
               441.513,
               378.582,
               257.908,
               382.268,
               237.965,
               392.512]

let pathNodes4 = [0,
                  2,
                  2,
                  3]

let points5 = [//move to
               536.886,
               517.869,
               //move to
               465.55,
               511.842,
               396.408,
               499.85,
               328.463,
               484.606,
               335.424,
               504.833,
               338.067,
               524.111,
               335.67,
               544.861,
               //line
               532.497,
               550.943,
               //line
               521.671,
               539.415,
               527.303,
               529.615,
               536.886,
               517.869
]

let pathNodes5 = [0,
                  2,
                  2,
                  1,
                  2,
                  3]

let cgPointArray = arrayPoints_toCGPoint(array: points)
print(cgPointArray)

let pointA = CGPoint(x: 10, y: 5)
let pointB = CGPoint(x: 10, y: 3)
let pointC = pointA + pointB
print(pointC)

class CurveView: UIView {
    
    override func draw(_ rect: CGRect) {
        //TODO:- Setup a UIBezierPath from the above created struct of the CubicBezierPath ..
        
        let center = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
        
        var path = UIBezierPath()
        
        let path_ = Path(pathNodes: pathNodes, points: cgPointArray, center: center)
        path_.addPaths()
        path = path_.path!
        path_.printPath()
        
        path.stroke()
        
        let path2_ = Path(pathNodes: pathNodes2, points: arrayPoints_toCGPoint(array: points2), center: center)
        path2_.addPaths()
        path = path2_.path!
        path2_.printPath()
        
        path.stroke()
        
        let path3_ = Path(pathNodes: pathNodes3, points: arrayPoints_toCGPoint(array: points3), center: center)
        path3_.addPaths()
        path = path3_.path!
        path.stroke()
//
        let path4_ = Path(pathNodes: pathNodes4, points: arrayPoints_toCGPoint(array: points4), center: center)
        path4_.addPaths()
        path = path4_.path!
        path.stroke()
        
        let path5_ = Path(pathNodes: pathNodes5, points: arrayPoints_toCGPoint(array: points5), center: center)
        path5_.addPaths()
        path = path5_.path!
        path.stroke()
        
    }
}

func displayCurveView() {
    let curveView = CurveView(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
    curveView.backgroundColor = UIColor.white
}

displayCurveView()
//let path = Path(pathNodes: pathNodes, points: cgPointArray)
//print(path.isPathClosed)

//TODO: ADD LINES FUNCTIONALITY
