# -----------------------------------------------------------------------------------------------------------------
# Invoke-Wrapper
# -----------------------------------------------------------------------------------------------------------------

<#
.Synopsis
  Invokes the Out-Default command wrapper.
.Description
  Invokes the Out-Default command wrapper.

  If Reset-OutDefault is used, or if the wrapped Out-Default command is accidently removed, invoke the wrapper to
  turn tuliPS formatting back on.

  This is a simple alias function that invokes the wrapping script. It takes no parameters and returns nothing.
.Example
  PS> Invoke-Wrapper
  Only way it can be used.
#>
function Invoke-Wrapper {
    & $WrapperPath 
}
