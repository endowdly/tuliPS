# PSScriptAnalyzerSettings.psd1
@{
    Severity = "Error", "Warning"

    ExcludeRules = @(
        "PSUseDeclaredVarsMoreThanAssignments"  # The dumbest rule there is
    )
}