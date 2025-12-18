import Foundation
import Cadova
import Helical

let packageURL = URL(filePath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
let outputRoot = packageURL.appending(path: "Models", directoryHint: .isDirectory)

await Project(root: outputRoot) {
    Metadata(
        title: "Filament Drain Line",
        description: "A through-surface filament waste solution using standard vacuum hose for Bambu Lab H2 series printers.",
        author: "Tomas Wincent Franzén",
        license: "MIT"
    )

    Environment(\.tolerance, 0.2)

    await Model("Mounting Bracket") { MountingBracket() }
    await Model("Connector") { HoseConnector() }
    await Model("Grommet") { Grommet() }
}
