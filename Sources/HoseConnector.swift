import Foundation
import Cadova
import Helical

struct HoseConnector: Shape3D {
    var body: any Geometry3D {
        @Environment(\.tolerance) var tolerance

        let hoseInnerDiameter = 38.1
        let hoseHelixDepth = 2.0
        let hoseMountLength = 15.0
        let hoseMountWallThickness = 1.0
        let hoseOffsetFromBase = 5.0
        let wallThickness = 1.0

        let thread = ScrewThread(
            handedness: .left,
            pitch: 5.5,
            majorDiameter: hoseInnerDiameter + hoseHelixDepth * 2,
            minorDiameter: hoseInnerDiameter,
            form: TrapezoidalThreadform(angle: 50°, crestWidth: 0.2)
        )

        let hoseMountInnerDiameter = thread.minorDiameter - 2 * hoseMountWallThickness
        let hoseToChuteTransitionLength = 30.0
        let chuteBottomZ = hoseMountLength + hoseToChuteTransitionLength - 0.2
        let chuteTopZ = hoseMountLength + hoseToChuteTransitionLength + PurgeChuteMetrics.chuteSize.y
        let topHeight = MountingBracket.margins.y
        let topZ = chuteTopZ + topHeight

        let bodyWidth = PurgeChuteMetrics.chuteSize.x + MountingBracket.margins.x * 2
        let bodyDepth = hoseMountInnerDiameter + hoseOffsetFromBase + 2 * wallThickness
        let bodyRoundingRadius = PurgeChuteMetrics.chuteSize.x / 2 + wallThickness
        let bodyOuterShape = Rectangle(
            x: bodyWidth,
            y: bodyDepth
        )
            .cuttingEdgeProfile(.fillet(radius: bodyRoundingRadius), on: .bottom)
            .aligned(at: .centerX, .maxY)

        Screw(thread: thread, length: hoseMountLength)
            .cuttingEdgeProfile(.chamfer(depth: thread.depth), on: .bottom) {
                Circle(diameter: thread.majorDiameter - tolerance)
            }
            .subtracting {
                Cylinder(diameter: hoseInnerDiameter - 2 * hoseMountWallThickness, height: hoseMountLength)
            }
            .translated(y: -hoseMountInnerDiameter / 2 - hoseOffsetFromBase - wallThickness)
            .adding {
                Loft {
                    let bodyInnerShape = Rectangle(x: PurgeChuteMetrics.chuteSize.x, y: hoseMountInnerDiameter + hoseOffsetFromBase)
                        .cuttingEdgeProfile(.fillet(radius: PurgeChuteMetrics.chuteSize.x / 2), on: .bottom)
                        .aligned(at: .centerX, .maxY)
                        .translated(y: -wallThickness)

                    layer(z: hoseMountLength) {
                        Circle(diameter: hoseInnerDiameter)
                            .subtracting { Circle(diameter: hoseMountInnerDiameter) }
                            .translated(y: -hoseMountInnerDiameter / 2 - hoseOffsetFromBase - wallThickness)
                    }
                    layer(z: chuteBottomZ, interpolation: .easeInOut) {
                        bodyOuterShape.subtracting { bodyInnerShape }
                    }
                }
                Loft {
                    layer(z: chuteBottomZ..<chuteTopZ) {
                        bodyOuterShape
                    }
                    layer(z: topZ, interpolation: .circularEaseIn) {
                        Rectangle(
                            x: bodyWidth - 2 * topHeight,
                            y: hoseMountInnerDiameter + hoseOffsetFromBase + 2 * wallThickness - topHeight
                        )
                        .cuttingEdgeProfile(.fillet(radius: bodyRoundingRadius - topHeight), on: .bottom)
                        .aligned(at: .centerX, .maxY)
                    }
                }
                .subtracting {
                    // Knurling
                    let knurlInset = 1.0
                    let knurlSize = Vector3D(0.5, bodyDepth - bodyRoundingRadius - knurlInset * 2, 1.0)
                    Box(knurlSize)
                        .aligned(at: .maxY)
                        .translated(x: -bodyWidth / 2, y: -knurlInset)
                        .repeated(along: .z, in: (chuteBottomZ + knurlInset)...(chuteTopZ - knurlInset), minimumSpacing: 2.0)
                        .symmetry(over: .x)

                    let bodyInnerShape = Rectangle(x: PurgeChuteMetrics.chuteSize.x, y: hoseMountInnerDiameter + hoseOffsetFromBase + wallThickness)
                        .cuttingEdgeProfile(.fillet(radius: PurgeChuteMetrics.chuteSize.x / 2), on: .bottom)
                        .aligned(at: .centerX, .maxY)

                    bodyInnerShape.extruded(height: chuteTopZ - chuteBottomZ)
                        .translated(z: chuteBottomZ)

                    let inset = MountingBracket.margins.x
                    let topCutoutShape = Rectangle(
                        x: bodyWidth - inset * 2,
                        y: hoseMountInnerDiameter + hoseOffsetFromBase + 2 * wallThickness - inset
                    )
                        .cuttingEdgeProfile(.fillet(radius: bodyRoundingRadius - inset), on: .bottom)
                        .aligned(at: .centerX, .maxY)

                    Loft {
                        layer(z: chuteTopZ) {
                            bodyInnerShape
                        }
                        layer(z: (chuteTopZ + 5)..<topZ, interpolation: .convexHull) {
                            topCutoutShape
                        }
                    }
                }
            }
            .subtracting {
                MountingBracket.Tab()
                    .offset(amount: 0.15, style: .round)
                    .rotated(180°)
                    .extruded(height: PurgeChuteMetrics.chuteSize.y + hoseToChuteTransitionLength + 0.4)
                    .translated(z: -hoseToChuteTransitionLength)
                    .translated(x: -PurgeChuteMetrics.chuteSize.x / 2 - 10 / 2, z: chuteBottomZ)
                    .symmetry(over: .x)
            }
    }
}
