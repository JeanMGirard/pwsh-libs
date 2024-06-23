
function Get-Displays {
    param ([switch] $primary=$false)
    begin { Add-Type -AssemblyName System.Windows.Forms; }
    process {
        [System.Windows.Forms.Screen]::AllScreens | Where-Object { $primary -eq $false -or $_.Primary -eq $primary }
    }
}

#Add-Type -AssemblyName UIAutomationClient
function Get-WindowState {
    [CmdletBinding()]
    param ([Parameter(Mandatory=$true)][System.Diagnostics.Process] $process)
    begin { Add-Type -AssemblyName UIAutomationClient; }
    process {
        $automationElement = [System.Windows.Automation.AutomationElement]::FromHandle($process.MainWindowHandle)
        $processPattern = $automationElement.GetCurrentPattern([System.Windows.Automation.WindowPatternIdentifiers]::Pattern)
        return $processPattern.Current.WindowVisualState

    }
}

function Get-Windows {
    param (
        [switch] $active=$false,
        [string[]] $omit=@()
    )
    process
    {
        $windowList = Get-Process | Where-Object { $_.MainWindowTitle -and $_.Parent.ProcessName -ne 'svchost' -and $omit -notcontains $_.ProcessName  }  | ForEach-Object { [PSCustomObject]@{
            Name = $_.ProcessName
            State = $(Get-WindowState $_)
            Handle = $_.MainWindowHandle
            # Process = $_
         }}

        if($active -eq $true){ 
            $windowList = $windowList | Where-Object { $_.State -eq "Normal"  }
         }

         return $windowList

        #  return $windowList | ForEach-Object { [Window]::GetWindowRect($Handle,[ref]$Rectangle) }
        #  if ( $Handle -eq [System.IntPtr]::Zero ) { return }
        #  $Return = [Window]::GetWindowRect($Handle,[ref]$Rectangle)
    }
}

<#
 .Synopsis
  Organize currently visible windows 

 .Description
  blablabla

 .Parameter Space
  Space between windows

 .Parameter Top
  Top boundary
  
 .Parameter Bottom
  Bottom boundary
  
 .Parameter Left
  Left boundary

 .Parameter Right
  Right boundary

 .Example
   # Default usage
   Superpose

 .Example
   # Specify boundaries & space
   Superpose -left 0 -right 0 -top 0 -bottom 0 -space 60

#>
function Superpose {
    param(
        [int] $space = 60,
        [string] $config,
        [string[]] $omit=@("ConEmu64"),
        [int] $right = 140,
        [int] $bottom = -20,
        [int] $top = -20,
        [int] $left = -20
    )
    begin {
        Add-Type @"
using System;
using System.Runtime.InteropServices;

public class Window {
    [DllImport("user32.dll")][return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll")][return: MarshalAs(UnmanagedType.Bool)]
    public extern static bool MoveWindow(IntPtr handle, int x, int y, int width, int height, bool redraw);

    [DllImport("user32.dll")][return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool ShowWindow(IntPtr handle, int state);
}
public struct RECT {
    public int Left;        // x position of upper-left corner
    public int Top;         // y position of upper-left corner
    public int Right;       // x position of lower-right corner
    public int Bottom;      // y position of lower-right corner
}
"@
    }
    process {
        $windows = Get-Windows -active -omit $omit
        $totalSpace = $($windows.Length + 1) * $space
        $display = $(Get-Displays)[0]
        $height = $display.Bounds.Height - $totalSpace - $top - $bottom
        $width = $display.Bounds.Width - $totalSpace - $left - $right

        $spaceY = $space
        $spaceX = $space
        $x = $spaceX + $left
        $y = $spaceY + $top

        foreach ($win in $windows){
            $success = [Window]::MoveWindow($win.Handle, $x, $y, $width, $height, $true)
            $x = $x + $spaceX
            $y = $y + $spaceY
        }
    }
}



Export-ModuleMember -Function Superpose
