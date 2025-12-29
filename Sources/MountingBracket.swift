import Foundation
import Cadova

struct MountingBracket: Shape3D {
    static let margins = Vector2D(10.0, PurgeChuteMetrics.screwHoleDistance - PurgeChuteMetrics.chuteSize.y)
    static let latch = (
        depth: 1.4,
        length: 7.0,
        inset: 5.0,
    )

    var body: any Geometry3D {
        @Environment(\.tolerance) var tolerance

        let mountBaseThickness = 1.0
        let mountThickness = mountBaseThickness + PurgeChuteMetrics.screwHeadThickness + 1

        Rectangle(PurgeChuteMetrics.chuteSize + Self.margins * 2)
            .cuttingEdgeProfile(.fillet(radius: 5))
            .aligned(at: .center)
            .subtracting {
                Circle(diameter: PurgeChuteMetrics.screwHoleDiameter + tolerance * 2)
                    .translated(y: PurgeChuteMetrics.screwHoleDistance / 2)
                    .symmetry(over: .y)

                Rectangle(PurgeChuteMetrics.chuteSize)
                    .aligned(at: .center)
            }
            .extruded(height: mountThickness)
            .adding {
                Tab()
                    .extruded(height: PurgeChuteMetrics.chuteSize.y)
                    .rotated(x: 90°)
                    .translated(
                        x: -PurgeChuteMetrics.chuteSize.x / 2 - Self.margins.x / 2,
                        y: PurgeChuteMetrics.chuteSize.y / 2,
                        z: mountThickness
                    )
                    .symmetry(over: .x)
            }
            .subtracting {
                Cylinder(diameter: PurgeChuteMetrics.screwHeadDiameter, height: mountThickness)
                    .translated(y: PurgeChuteMetrics.screwHoleDistance / 2, z: mountBaseThickness)
                    .symmetry(over: .y)

                Triangle.right(a: Self.latch.length, b: Self.latch.depth)
                    .extruded(height: Self.margins.x + tolerance)
                    .rotated(x: -90°, z: -90°)
                    .aligned(at: .top)
                    .translated(
                        x: PurgeChuteMetrics.chuteSize.x / 2 - tolerance,
                        y: PurgeChuteMetrics.chuteSize.y / 2 + Self.margins.y - Self.latch.inset + tolerance,
                        z: mountThickness
                    )
                    .symmetry(over: .xy)
            }
    }

    struct Tab: Shape2D {
        private var shape: BezierPath2D {
            BezierPath(from: [-2.5, -0.5]) {
                curve(controlX: -0.5, controlY: 0, controlX: -0.5, controlY: 0.50, endX: -2, endY: 0.9)
                continuousCurve(distance: 1, controlX: -2.5, controlY: 2.0, endX: 0, endY: 2.0)
                line(y: -0.5)
            }
        }

        var body: any Geometry2D {
            Polygon(shape)
                .scaled(x: 0.7, y: 2)
                .symmetry(over: .x)
        }
    }
}
