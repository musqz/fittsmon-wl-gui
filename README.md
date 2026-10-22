# fittsmon-wl-gui

GTK3 GUI to configure [`fittsmon-wl`](https://codeberg.org/linux-bird/fittsmon) screen-corner hotspots on Wayland (wlroots compositors).
For X11 use [fittsmon-gui](https://codeberg.org/linux-bird/fittsmon-gui).

Based on fittsmon-gui.

## Requirements
- `fittsmon-wl`, `wlr-randr`, `python-gobject`, `gtk3`, `gtk-layer-shell`

## Run
```bash
python3 fittsmon-wl-gui.py
```

## Install
```bash
sudo make install
```

## Config
`~/.config/fittsmon-wl/fittsmon-wlrc`
