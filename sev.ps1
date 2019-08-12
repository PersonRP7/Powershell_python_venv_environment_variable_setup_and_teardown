function check_file_format{
    param([string] $format)
    if ($format.EndsWith("activate.bat") -and (Test-Path $format)){
        return $true
    }
    else {
        [Console]::Error.WriteLine("Error. Check the path.")
    }
}

function display_error{
    param($error_text)
    [Console]::Error.WriteLine($error_text)
}

function check_file_contents{
    param([string] $file)
    try {
        $data = Get-Content $file -ErrorAction Stop
        $echo_off = $data | Select-String -Pattern "@echo"
        $echo_str = "@echo off"
        $echo_off_to_str = $echo_off.ToString()
        if($echo_str -eq $echo_off_to_str){
            Write-Host "check_file_contents ran and returned true"
            return $true
        }else{
            display_error "Incorrect file contents."
        }
    }
    catch [System.Management.Automation.RuntimeException]{ #Addition
        display_error "Incorrect file contents."
    }
}

function check_var_format{
    param([string] $var)
    if(-Not($var.Contains("set") -and $var.Contains("="))){
        [Console]::Error.WriteLine("Environment variable incorrect format.")
    }else{
        return $true
    }
}

$global:activate_path = ""
$global:deactivate_path = ""

$global:activate_var = ""
$global:deactivate_var = ""

function set_activate_path{
    $global:activate_path = Read-Host "Path "
}

function set_activate_var{
    $global:activate_var = Read-Host "Environment variable "
}

function activate_to_deactivate_path {
    param([string] $str)
    $str -replace "activate", "deactivate"
    $global:deactivate_path = $str -replace "activate", "deactivate"
}

function env_var_to_deactivate{
    param([string] $activate_var)
    $global:deactivate_var = $activate_var -replace ("(?<==).*$")
}

function deactivate_procedure{
    param($activate_path, $activate_env_var)
    activate_to_deactivate_path $activate_path
    env_var_to_deactivate $activate_env_var
}

function describe_progress{
    param($text)
    Write-Host $text
}

set_activate_path

if((check_file_format $activate_path)){
    if((check_file_contents $activate_path)){

        set_activate_var
        if((check_var_format $activate_var)){
            Add-Content $activate_path $activate_var
            describe_progress "Added $activate_var to $activate_path"
            deactivate_procedure $activate_path $activate_var
            Add-Content $deactivate_path $deactivate_var
            describe_progress "Added $deactivate_var to $deactivate_path"
        }
    }
}