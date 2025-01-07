# Variables for paths and config
$runnerDir = "C:\actions-runner"
$configCmd = "$runnerDir\config.cmd"
$runCmd = "$runnerDir\run.cmd"

# Check required environment variables
if (-not $env:RUNNER_TOKEN) {
    Write-Error "RUNNER_TOKEN is not set. Exiting."
    exit 1
}
if (-not $env:RUNNER_REPO_URL) {
    Write-Error "RUNNER_REPO_URL is not set. Exiting."
    exit 1
}
if (-not $env:RUNNER_NAME) {
    $env:RUNNER_NAME = "default-runner"
    Write-Host "RUNNER_NAME not set. Using default: $env:RUNNER_NAME"
}
if (-not $env:RUNNER_WORKDIR) {
    $env:RUNNER_WORKDIR = "_work"
    Write-Host "RUNNER_WORKDIR not set. Using default: $env:RUNNER_WORKDIR"
}

# Register the runner
Write-Host "Registering the runner..."
& $configCmd --url $env:RUNNER_REPO_URL `
             --token $env:RUNNER_TOKEN `
             --name $env:RUNNER_NAME `
             --work $env:RUNNER_WORKDIR `
             --unattended `
             --replace

# Check if registration was successful
if ($LASTEXITCODE -ne 0) {
    Write-Error "Runner registration failed. Exiting."
    exit $LASTEXITCODE
}

# Start the runner
Write-Host "Starting the runner..."
& $runCmd

# Cleanup on exit (optional)
if ($env:RUNNER_TOKEN -and $env:RUNNER_REPO_URL) {
    Write-Host "Cleaning up runner registration..."
    & $configCmd remove --unattended --token $env:RUNNER_TOKEN
} else {
    Write-Host "Skipping cleanup. Token or URL missing."
}
