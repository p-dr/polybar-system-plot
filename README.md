# polybar-system-plot
This is a simple script to make live and simple system statistics plots on polybar. Only network traffic is currently implemented.

## Installation (suggested method)
Clone or download this repository and move `scripts` folder (where the main script is) together with the `system-plot_modules.ini` file to your polybar config directory (`~/.config/polybar`). Include the `system-plot_modules.ini` using the following line under the global WM settings of yours main polybar configuration file.

```
[global/wm]

include-file = ~/.config/polybar/system-plot_modules.ini
```

Your main configuration file is the one used at polybar launching, generaly in a launcher script at polybar config directory, such as `~/.config/polybar/launch.sh`:

```
polybar -c ~/.config/polybar/config.ini main &
```

Also in the polybar main cofiguration file, in your desired bar section, include VerticalBars or VerticalBarsCenter fonts (these fonts, in the project's `fonts` directory, should be installed), depending on your personal taste for centralized or bottom-aligned bars. Including it as the second font (`font-1`) and disabling antialiasing gave me the best results. 

```
font-1 = VerticalBars:size=5:antialias=false
```
or
```
font-1 = VerticalBarsCenter:size=6:antialias=false
```

Now you can just position the `upload-plot` and `download-plot` modules among your own ones using `modules-(center/left/right)` definitions. As an example:

```
modules-left = bspwm date
modules-center = cpu temperature memory alsa backlight keyboard
modules-right = upload-plot checknetwork download-plot
```
