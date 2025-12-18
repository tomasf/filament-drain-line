import Foundation
import Cadova
import Helical

struct Grommet: Shape3D {
    var body: any Geometry3D {
        let hoseOuterDiameter = 48.1
        let hoseHelixDepth = 2.4
        let hoseOuterThread = ScrewThread(
            handedness: .left,
            pitch: 5.5,
            majorDiameter: hoseOuterDiameter,
            minorDiameter: hoseOuterDiameter - hoseHelixDepth * 2,
            form: TrapezoidalThreadform(angle: 50°, crestWidth: 2.6)
        )

        let maximumHoleDiameter = 70.0
        let surfaceDiameter = maximumHoleDiameter + 20.0
        let surfaceThickness = 1.8

        let screwMountDiameter = hoseOuterDiameter + 4.0
        let screwMountDepth = 1.0

        let maximumTabletopThickness = 50.0
        let minimumScrewMountThreadOverlap = 6.0
        let screwLength = (maximumTabletopThickness + minimumScrewMountThreadOverlap) / 2.0

        let screwMountThread = ScrewThread(
            pitch: 3.0,
            majorDiameter: screwMountDiameter + 2 * screwMountDepth,
            minorDiameter: screwMountDiameter,
            form: TrapezoidalThreadform(angle: 90°, crestWidth: 0.4)
        )

        let topPart = Circle(diameter: surfaceDiameter)
            .extruded(height: surfaceThickness, bottomEdge: .chamfer(depth: surfaceThickness))
            .adding {
                Screw(thread: screwMountThread, length: screwLength, chamferFactor: 1)
            }
            .subtracting {
                ThreadedHole(thread: hoseOuterThread, depth: screwLength + 0.2, entryEnds: [.negative])
                    .translated(z: -0.1)
            }

        let bottomSurfaceThickness = 8.0
        let gripDepth = 3.0
        let circle = Circle(diameter: surfaceDiameter + gripDepth * 2)
        let bottomScrewOuterDiameter = screwMountThread.majorDiameter + 3 // This is also the minimum surface hole diameter

        let bottomPart = circle
            .subtracting {
                Circle.ellipse(x: 14, y: gripDepth * 2)
                    .translated(y: -circle.radius)
                    .repeated(count: 17)
            }
            .rounded(radius: 3)
            .extruded(height: bottomSurfaceThickness, topEdge: .chamfer(depth: 0.8), bottomEdge: .chamfer(depth: 0.8))
            .adding {
                Cylinder(diameter: bottomScrewOuterDiameter, height: screwLength + bottomSurfaceThickness)
            }
            .subtracting {
                ThreadedHole(thread: screwMountThread, depth: screwLength + bottomSurfaceThickness, entryEnds: [.negative, .positive])
            }

        Stack(.x, spacing: 1.0) {
            topPart
            bottomPart
        }
    }
}
