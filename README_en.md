# AutoTask

[中文 README](README.md)

AutoTask is a remote GPU monitor and task launcher. It checks GPU status over SSH and can start remote `.sh` scripts inside detached `tmux` sessions.

## Requirements

- macOS or Windows
- Conda installed locally
- Local `ssh <Host>` works for your remote servers
- Remote NVIDIA driver, `nvidia-smi`, and `tmux`

AutoTask does not store passwords or handle interactive password login. Set up SSH keys or passwordless login first.

## Quick Start

macOS:

1. Double-click `setup_macos.command` for first-time setup.
2. Double-click `start_monitor_macos.command` to open Monitor.
3. Double-click `start_runner_macos.command` to open Runner.

Windows:

1. Double-click `setup_windows.bat` for first-time setup.
2. Double-click `start_monitor_windows.bat` to open Monitor.
3. Double-click `start_runner_windows.bat` to open Runner.

On first use, click **编辑服务器** and paste your SSH config, for example:

```sshconfig
Host gpu-box-01
  HostName gpu.example.com
  User yourname
  Port 22
```

The `Host` value is the server name shown in the app.

## Monitor

Monitor shows remote GPU status. It displays the last cached result first, then refreshes in the background. Later refreshes happen only when you click **刷新** or a single server refresh button.

## Runner

Runner starts remote tasks. Click **添加任务**, then choose the server, GPU, Conda environment, task name, and remote shell script path.

After launch, AutoTask creates a detached `tmux` session on the remote server. Closing the local browser page does not stop remote tasks. The task table can open tmux, stop the program, delete tmux, or remove the local task record.

## Troubleshooting

- If Conda is missing, install Anaconda or Miniconda and rerun the setup file for your system.
- If SSH fails, test `ssh <Host>` in your local terminal first.
- If GPU data is missing, check that `nvidia-smi` works on the remote server.
- If a task cannot start, check that `tmux` is installed and the script path exists.
- Logs are stored at `data/monitor.log` and `data/runner.log`. Monitor and Runner clear their own logs when they close.

## License

Apache License 2.0
