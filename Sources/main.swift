import Foundation
import Cadova
import Helical

await Project(packageRelative: "Models") {
    Metadata(
        title: "Filament Drain Line",
        description: "A through-surface filament waste solution using standard vacuum hose for Bambu Lab H2 series printers.",
        author: "Tomas Wincent Franzén",
        license: "MIT"
    )

    Environment(\.tolerance, 0.2)

    await Model("Mounting Bracket") { MountingBracket() }
    await Model("Connector") { HoseConnector().removingParts(ofType: .context) }
    await Model("Grommet") { Grommet() }
}
