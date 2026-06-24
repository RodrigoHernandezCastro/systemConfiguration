{
  pkgs,
  ...
}:
let
  backlightScript = ''
    DEF_VALUE=1

    usage() {
    	local script=''${0##*/}

    	cat <<- EOF
    		USAGE: $script {up|down} [value]

    		Adjust screen brightness and send a notification with the current level

    		OPTIONS:
    		  up   [value]    Increase brightness by [value] (default: $DEF_VALUE)
    		  down [value]    Decrease brightness by [value] (default: $DEF_VALUE)

    		EXAMPLES:
    		  Increase brightness:
    		    $ $script up

    		  Decrease brightness by 5:
    		    $ $script down 5
    	EOF
    }

    main() {
    	local action=$1
    	local value=''${2:-$DEF_VALUE}

    	if ((value < 1)); then
    		usage >&2
    		return 1
    	fi

    	case $action in
    		up | down)
    			local sign

    			case $action in
    				up)   sign='+' ;;
    				down) sign='-' ;;
    			esac

    			brightnessctl -n set "''${value}%''${sign}" > /dev/null

    			local level
    			level=$(brightnessctl -m | awk -F ',' '{print $4}')

    			notify-send "Brightness: $level" -h int:value:"$level" -i \
    				"contrast" -h string:x-canonical-private-synchronous:backlight
    			;;
    		*)
    			usage >&2
    			return 1
    			;;
    	esac
    }

    main "$@"
  '';

  bluetoothScript = ''
    FG_RED="\e[31m"
    FG_RESET="\e[39m"

    TIMEOUT=10

    printf() {
    	command printf "$@" >&2
    }

    power_on() {
    	local state
    	state=$(bluetoothctl show | awk '/PowerState/ {print $2}')

    	case $state in
    		off)
    			bluetoothctl power on > /dev/null
    			;;
    		off-blocked)
    			rfkill unblock bluetooth

    			local new_state

    			local i
    			for ((i = 1; i <= TIMEOUT; i++)); do
    				printf "\rUnblocking Bluetooth... (%d/%d)" $i $TIMEOUT

    				new_state=$(bluetoothctl show | awk '/PowerState/ {print $2}')
    				if [[ $new_state == on ]]; then
    					break
    				fi

    				sleep 1
    			done

    			if [[ $new_state != on ]]; then
    				notify-send "Bluetooth" "Failed to unblock" -i "package-purge"
    				read -rsn 1 -p "Press any key to exit..."
    				exit 1
    			fi
    			;;
    		*)
    			return 0
    			;;
    	esac

    	notify-send "Bluetooth On" -i "network-bluetooth-activated" \
    		-h string:x-canonical-private-synchronous:bluetooth
    }

    get_devices() {
    	bluetoothctl -t $TIMEOUT scan on > /dev/null &

    	local num

    	local i
    	for ((i = 1; i <= TIMEOUT; i++)); do
    		printf "\rScanning for devices... (%d/%d)" $i $TIMEOUT
    		printf "\n%bPress [q] to stop%b\n" "$FG_RED" "$FG_RESET"

    		num=$(bluetoothctl devices | grep -c "^Device")
    		printf "\nDevices: %d" "$num"

    		# Move cursor 3 lines up
    		printf "\e[3F"

    		read -rsn 1 -t 1
    		if [[ $REPLY == [Qq] ]]; then
    			break
    		fi
    	done

    	printf "\n%bScanning stopped.%b\n\n" "$FG_RED" "$FG_RESET"

    	LIST=$(bluetoothctl devices | sed "s/^Device //")
    	if [[ -z $LIST ]]; then
    		notify-send "Bluetooth" "No devices found" -i "package-broken"
    		read -rsn 1 -p "Press any key to exit..."
    		exit 1
    	fi
    }

    select_device() {
    	local header
    	printf -v header "%-17s %s" "Address" "Name"

    	local options=(
    		"--border=sharp"
    		"--border-label= Bluetooth Devices "
    		"--cycle"
    		"--ghost=Search"
    		"--header=$header"
    		"--height=~100%"
    		"--highlight-line"
    		"--info=inline-right"
    		"--pointer="
    		"--reverse"
    	)

    	ADDRESS=$(fzf "''${options[@]}" <<< "$LIST" | awk '{print $1}')
    	if [[ -z $ADDRESS ]]; then
    		exit 0
    	fi

    	local connected
    	connected=$(bluetoothctl info "$ADDRESS" | awk '/Connected/ {print $2}')

    	if [[ $connected == yes ]]; then
    		notify-send "Bluetooth" "Already connected to this device" \
    				-i "package-install"
    			read -rsn 1 -p "Press any key to exit..."
    			exit 1
    	fi
    }

    pair_and_connect() {
    	local paired
    	paired=$(bluetoothctl info "$ADDRESS" | awk '/Paired/ {print $2}')

    	if [[ $paired == no ]]; then
    		printf "Pairing..."

    		if ! timeout $TIMEOUT bluetoothctl pair "$ADDRESS" > /dev/null; then
    			notify-send "Bluetooth" "Failed to pair" -i "package-purge"
    			read -rsn 1 -p "Press any key to exit..."
    			exit 1
    		fi
    	fi

    	printf "\nConnecting..."

    	if ! timeout $TIMEOUT bluetoothctl connect "$ADDRESS" > /dev/null; then
    		notify-send "Bluetooth" "Failed to connect" -i "package-purge"
    		read -rsn 1 -p "Press any key to exit..."
    		exit 1
    	fi

    	notify-send "Bluetooth" "Successfully connected" -i "package-install"
    	read -rsn 1 -p "Press any key to exit..."
    }

    main() {
    	if [[ $1 == off ]]; then
    		bluetoothctl power off
    		notify-send 'Bluetooth Off' -i 'network-bluetooth-inactive' \
    			-h string:x-canonical-private-synchronous:bluetooth
    		return 0
    	fi

    	# Make cursor invisible
    	printf "\e[?25l"

    	power_on
    	get_devices

    	# Make cursor visible
    	printf "\e[?25h"

    	select_device
    	pair_and_connect
    }

    main "$@"
  '';

  networkScript = ''
    FG_RED="\e[31m"
    FG_RESET="\e[39m"

    TIMEOUT=5

    printf() {
    	command printf "$@" >&2
    }

    switch_on() {
    	local state
    	state=$(nmcli radio wifi)

    	if [[ $state == enabled ]]; then
    		return 0
    	fi

    	nmcli radio wifi on

    	local new_state

    	local i
    	for ((i = 1; i <= TIMEOUT; i++)); do
    		printf "\rEnabling Wi-Fi... (%d/%d)" $i $TIMEOUT

    		new_state=$(nmcli -t -f STATE general)
    		if [[ $new_state != "connected (local only)" ]]; then
    			break
    		fi

    		sleep 1
    	done

    	notify-send "Wi-Fi Enabled" -i "network-wireless-on" \
    		-h string:x-canonical-private-synchronous:network
    }

    get_networks() {
    	nmcli device wifi rescan

    	local i
    	for ((i = 1; i <= TIMEOUT; i++)); do
    		printf "\rScanning for networks... (%d/%d)" $i $TIMEOUT

    		LIST=$(timeout 1 nmcli device wifi list)
    		NETWORKS=$(tail -n +2 <<< "$LIST" | awk '$2 != "--"')

    		if [[ -n $NETWORKS ]]; then
    			break
    		fi
    	done

    	printf "\n%bScanning stopped.%b\n\n" "$FG_RED" "$FG_RESET"

    	if [[ -z $NETWORKS ]]; then
    		notify-send "Wi-Fi" "No networks found" -i "package-broken"
    		read -rsn 1 -p "Press any key to exit..."
    		exit 1
    	fi
    }

    select_network() {
    	local header
    	header=$(head -n 1 <<< "$LIST")

    	local options=(
    		"--border=sharp"
    		"--border-label= Wi-Fi Networks "
    		"--cycle"
    		"--ghost=Search"
    		"--header=$header"
    		"--height=~100%"
    		"--highlight-line"
    		"--info=inline-right"
    		"--pointer="
    		"--reverse"
    	)

    	BSSID=$(fzf "''${options[@]}" <<< "$NETWORKS" | awk '{print $1}')
    	case $BSSID in
    		''')
    			exit 0
    			;;
    		'*')
    			notify-send "Wi-Fi" "Already connected to this network" \
    				-i "package-install"
    			read -rsn 1 -p "Press any key to exit..."
    			exit 1
    			;;
    	esac
    }

    connect() {
    	printf "Connecting...\n"

    	if ! nmcli -a device wifi connect "$BSSID"; then
    		notify-send "Wi-Fi" "Failed to connect" -i "package-purge"
    		read -rsn 1 -p "Press any key to exit..."
    		exit 1
    	fi

    	notify-send "Wi-Fi" "Successfully connected" -i "package-install"
    	read -rsn 1 -p "Press any key to exit..."
    }

    main() {
    	if [[ $1 == off ]]; then
    		nmcli radio wifi off
    		notify-send 'Wi-Fi Disabled' -i 'network-wireless-off' \
    			-h string:x-canonical-private-synchronous:network
    		exit 0
    	fi

    	# Make cursor invisible
    	printf "\e[?25l"

    	switch_on
    	get_networks

    	# Make cursor visible
    	printf "\e[?25h"

    	select_network
    	connect
    }

    main "$@"
  '';

  powerScript = ''
    main() {
    	local list=(
    		"Lock"
    		"Shutdown"
    		"Reboot"
    		"Logout"
    		"Hibernate"
    		"Suspend"
    	)

    	local options=(
    		"--border=sharp"
    		"--border-label= Power Menu "
    		"--cycle"
    		"--ghost=Search"
    		"--height=~100%"
    		"--highlight-line"
    		"--info=inline-right"
    		"--pointer="
    		"--reverse"
    	)

    	local selected
    	selected=$(printf "%s\n" "''${list[@]}" | fzf "''${options[@]}")

    	case $selected in
    		Lock)      loginctl lock-session ;;
    		Shutdown)  systemctl poweroff ;;
    		Reboot)    systemctl reboot ;;
    		Logout)    loginctl terminate-session "$XDG_SESSION_ID" ;;
    		Hibernate) systemctl hibernate ;;
    		Suspend)   systemctl suspend ;;
    		*)         return 1 ;;
    	esac
    }

    main "$@"
  '';

  updateScript = ''
    FG_RED="\e[31m"
    FG_GREEN="\e[32m"
    FG_BLUE="\e[34m"
    FG_RESET="\e[39m"

    printf() {
    	command printf "$@" >&2
    }

    main() {
    	case $1 in
    		module)
    			cat <<- EOF
    				{ "text": "󱄅", "tooltip": "NixOS System" }
    			EOF
    			;;
    		*)
    			HOME="''${HOME:-/home/randy}"
    			printf "%bBuilding NixOS configuration...%b\n\n" "$FG_BLUE" "$FG_RESET"
    			if nh os switch "$HOME/systemConfiguration"; then
    				printf "\n%bDone.%b\n" "$FG_GREEN" "$FG_RESET"
    			else
    				printf "\n%bBuild failed.%b\n" "$FG_RED" "$FG_RESET"
    			fi
    			read -rsn 1 -p "Press any key to exit..."
    			;;
    	esac
    }

    main "$@"
  '';

  volumeScript = ''
    DEF_VALUE=1
    MIN=0
    MAX=100

    usage() {
    	local script=''${0##*/}

    	cat <<- EOF
    		USAGE: $script {input|output} {mute|raise|lower} [value]

    		Adjust default device volume and send a notification with the current level

    		DEVICE:
    		  input            Use "@DEFAULT_SOURCE@" (microphone)
    		  output           Use "@DEFAULT_SINK@" (speaker/headphones)

    		OPTIONS:
    		  mute             Toggle device mute
    		  raise [value]    Raise volume by [value] (default: $DEF_VALUE)
    		  lower [value]    Lower volume by [value] (default: $DEF_VALUE)

    		EXAMPLES:
    		  Toggle microphone mute:
    		    $ $script input mute

    		  Raise speaker volume:
    		    $ $script output raise

    		  Lower speaker volume by 5:
    		    $ $script output lower 5
    	EOF
    }

    pactl() {
    	command pactl "$1" "$DEV_DEF" "''${@:2}"
    }

    get_state() {
    	local state
    	state=$(pactl "get-$DEV_STATE" | awk '{print $2}')

    	case $state in
    		yes) printf "Muted" ;;
    		no)  printf "Unmuted" ;;
    	esac
    }

    get_volume() {
    	pactl "get-$DEV_VOLUME" | awk '{print $5}' | tr -d '%'
    }

    get_icon() {
    	local state level

    	state=$(get_state)
    	level=$(get_volume)

    	local icon
    	local new_level=''${1:-$level}

    	if [[ $state == Muted ]]; then
    		icon="$DEV_ICON-muted"
    	else
    		if ((new_level < MAX * 33 / 100)); then
    			icon="$DEV_ICON-low"
    		elif ((new_level < MAX * 66 / 100)); then
    			icon="$DEV_ICON-medium"
    		else
    			icon="$DEV_ICON-high"
    		fi
    	fi

    	printf "%s" "$icon"
    }

    set_state() {
    	pactl "set-$DEV_STATE" toggle

    	local state icon

    	state=$(get_state)
    	icon=$(get_icon)

    	notify-send "$DEV_NAME: $state" -i "$icon" \
    		-h string:x-canonical-private-synchronous:volume
    }

    set_volume() {
    	local level
    	level=$(get_volume)

    	local new_level

    	case $ACTION in
    		raise)
    			new_level=$((level + VALUE))
    			if ((new_level > MAX)); then
    				new_level=$MAX
    			fi
    			;;
    		lower)
    			new_level=$((level - VALUE))
    			if ((new_level < MIN)); then
    				new_level=$MIN
    			fi
    			;;
    	esac

    	pactl "set-$DEV_VOLUME" "$new_level%"

    	local icon
    	icon=$(get_icon $new_level)

    	notify-send "$DEV_NAME: $new_level%" -h int:value:$new_level -i "$icon" \
    		-h string:x-canonical-private-synchronous:volume
    }

    main() {
    	DEVICE=$1
    	ACTION=$2
    	VALUE=''${3:-$DEF_VALUE}

    	if ((VALUE < 1)); then
    		usage >&2
    		return 1
    	fi

    	case $DEVICE in
    		input)
    			DEV_DEF="@DEFAULT_SOURCE@"
    			DEV_STATE="source-mute"
    			DEV_VOLUME="source-volume"
    			DEV_ICON="mic-volume"
    			DEV_NAME="Microphone"
    			;;
    		output)
    			DEV_DEF="@DEFAULT_SINK@"
    			DEV_STATE="sink-mute"
    			DEV_VOLUME="sink-volume"
    			DEV_ICON="audio-volume"
    			DEV_NAME="Volume"
    			;;
    		*)
    			usage >&2
    			return 1
    			;;
    	esac

    	case $ACTION in
    		mute)
    			set_state
    			;;
    		raise | lower)
    			set_volume
    			;;
    		*)
    			usage >&2
    			return 1
    			;;
    	esac
    }

    main "$@"
  '';

  onBacklight = pkgs.writeShellApplication {
    name = "backlight";
    runtimeInputs = with pkgs; [
      brightnessctl
      libnotify
    ];
    text = backlightScript;
  };
  onBluetooth = pkgs.writeShellApplication {
    name = "bluetooth";
    runtimeInputs = with pkgs; [
      bluez
      libnotify
      fzf
      util-linux
    ];
    text = bluetoothScript;
  };
  onNetwork = pkgs.writeShellApplication {
    name = "network";
    runtimeInputs = with pkgs; [
      networkmanager
      libnotify
      fzf
    ];
    text = networkScript;
  };
  onPower = pkgs.writeShellApplication {
    name = "power";
    runtimeInputs = with pkgs; [
      fzf
      systemd
    ];
    text = powerScript;
  };
  onUpdate = pkgs.writeShellApplication {
    name = "update";
    runtimeInputs = with pkgs; [ nh ];
    text = updateScript;
  };
  onVolume = pkgs.writeShellApplication {
    name = "volume";
    runtimeInputs = with pkgs; [
      pulseaudio
      libnotify
    ];
    text = volumeScript;
  };
in

{
  programs.waybar = {
    enable = true;

    settings = [
      {
        layer = "top";
        height = 0;
        width = 0;
        margin = "0";
        spacing = 0;
        mode = "dock";
        reload_style_on_change = true;

        modules-left = [
          "custom/user"
          "custom/left_div#1"
          "niri/workspaces"
          "custom/right_div#1"
          "niri/window"
        ];

        modules-center = [
          "niri/language"
          "custom/left_div#2"
          "temperature"
          "custom/left_div#3"
          "memory"
          "custom/left_div#4"
          "cpu"
          "custom/left_inv#1"
          "custom/left_div#5"
          "custom/distro"
          "custom/right_div#2"
          "custom/right_inv#1"
          "idle_inhibitor"
          "clock#time"
          "custom/right_div#3"
          "clock#date"
          "custom/right_div#4"
          "network"
          "bluetooth"
          "custom/update"
          "custom/right_div#5"
        ];

        modules-right = [
          "mpris"
          "custom/left_div#6"
          "group/pulseaudio"
          "custom/left_div#7"
          "backlight"
          "custom/left_div#8"
          "battery"
          "custom/left_inv#2"
          "custom/power"
        ];

        "custom/user" = {
          format = "󰍜";
          min-length = 4;
          max-length = 4;
          tooltip-format = "No command set";
        };

        "custom/left_div#1" = {
          format = "";
          tooltip = false;
        };
        "custom/left_div#2" = {
          format = "";
          tooltip = false;
        };
        "custom/left_div#3" = {
          format = "";
          tooltip = false;
        };
        "custom/left_div#4" = {
          format = "";
          tooltip = false;
        };
        "custom/left_div#5" = {
          format = "";
          tooltip = false;
        };
        "custom/left_div#6" = {
          format = "";
          tooltip = false;
        };
        "custom/left_div#7" = {
          format = "";
          tooltip = false;
        };
        "custom/left_div#8" = {
          format = "";
          tooltip = false;
        };
        "custom/left_inv#1" = {
          format = "";
          tooltip = false;
        };
        "custom/left_inv#2" = {
          format = "";
          tooltip = false;
        };
        "custom/right_div#1" = {
          format = "";
          tooltip = false;
        };
        "custom/right_div#2" = {
          format = "";
          tooltip = false;
        };
        "custom/right_div#3" = {
          format = "";
          tooltip = false;
        };
        "custom/right_div#4" = {
          format = "";
          tooltip = false;
        };
        "custom/right_div#5" = {
          format = "";
          tooltip = false;
        };
        "custom/right_inv#1" = {
          format = "";
          tooltip = false;
        };

        "niri/workspaces" = {
          format = "{icon}";
          format-icons = {
            active = "";
            default = "";
          };

          persistent-workspaces = {
            "*" = 5;
          };

          workspace-taskbar = {

          };

          on-scroll-up = "niri msg action focus-workspace-down";
          on-scroll-down = "niri msg action focus-workspace-up";

        };

        "niri/window" = {
          format = "{}";
          rewrite = {
            "" = "Desktop";
            kitty = "Terminal";
          };
          swap-icon-label = false;
        };

        "niri/language" = {
          format-en = "  latam";
        };

        temperature = {
          thermal-zone = 1;
          critical-threshold = 90;
          interval = 10;
          format-critical = "󰀦 {temperatureC}°C";
          format = "{icon} {temperatureC}°C";
          format-icons = [
            "󱃃"
            "󰔏"
            "󱃂"
          ];
          min-length = 8;
          max-length = 8;
        };

        memory = {
          interval = 10;
          format = "󰘚 {percentage}%";
          format-warning = "󰀧 {percentage}%";
          format-critical = "󰀧 {percentage}%";
          states = {
            warning = 75;
            critical = 90;
          };
          min-length = 7;
          max-length = 7;

          tooltip-format = "Memory Used: {used:0.0f}/{total:0.0f} GiB";
        };

        cpu = {
          interval = 10;
          format = "󰍛 {usage}%";
          format-warning = "󰀨 {usage}%";
          format-critical = "󰀨 {usage}%";
          min-length = 7;
          max-length = 7;
          states = {
            warning = 75;
            critical = 90;
          };
          tooltip = false;
        };

        "custom/distro" = {
          format = "󱄅";
          tooltip = false;
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰈈";
            deactivated = "󰈉";
          };
          min-length = 3;
          max-length = 3;
          tooltip-format-activated = "<b>Idle Inhibitor</b>: Activated";
          tooltip-format-deactivated = "<b>Idle Inhibitor</b>: Deactivated";
          start-activated = false;
        };

        "clock#time" = {
          format = "{:%H:%M}";
          min-length = 5;
          max-length = 5;
          tooltip-format = "<b>Standard Time</b>: <span text_transform='lowercase'>{:%I:%M %p}</span>";
        };

        "clock#date" = {
          format = "󰸗 {:%d-%m}";
          min-length = 8;
          max-length = 8;
          tooltip-format = "{calendar}";
          calendar = {
            mode = "month";
            mode-mon-col = 6;
            format = {
              months = "<span alpha='100%'><b>{}</b></span>";
              days = "<span alpha='90%'>{}</span>";
              weekdays = "<span alpha='80%'><i>{}</i></span>";
              today = "<span alpha='100%'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            on-click = "mode";
          };
        };

        network = {
          interval = 10;
          format = "󰤨";
          format-ethernet = "󰈀";
          format-wifi = "{icon}";
          format-disconnected = "󰤯";
          format-disabled = "󰤮";
          format-icons = [
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          min-length = 2;
          max-length = 2;
          on-click = "${pkgs.kitty}/bin/kitty -e ${onNetwork}/bin/network";
          on-click-right = "${onNetwork}/bin/network off";

          tooltip-format = "<b>Gateway</b>: {gwaddr}";
          tooltip-format-ethernet = "<b>Interface</b>: {ifname}";
          tooltip-format-wifi = "<b>Network</b>: {essid}\n<b>IP Addr</b>: {ipaddr}/{cidr}\n<b>Strength</b>: {signalStrength}%\n<b>Frequency</b>: {frequency} GHz";
          tooltip-format-disconnected = "Wi-Fi Disconnected";
          tooltip-format-disabled = "Wi-Fi Disabled";
        };

        bluetooth = {
          format = "󰂯";
          format-disabled = "󰂲";
          format-off = "󰂲";
          format-on = "󰂰";
          format-connected = "󰂱";

          min-length = 2;
          max-length = 2;
          on-click = "${pkgs.kitty}/bin/kitty -e ${onBluetooth}/bin/bluetooth";
          on-click-right = "${onBluetooth}/bin/bluetooth off";

          tooltip-format = "Device Addr: {device_address}";
          tooltip-format-disabled = "Bluetooth Disabled";
          tooltip-format-off = "Bluetooth Off";
          tooltip-format-on = "Bluetooth Disconnected";
          tooltip-format-connected = "Device: {device_alias}";
          tooltip-format-enumerate-connected = "Device: {device_alias}";
          tooltip-format-connected-battery = "Device: {device_alias}\nBattery: {device_battery_percentage}%";
          tooltip-format-enumerate-connected-battery = "Device: {device_alias}\nBattery: {device_battery_percentage}%";
        };

        "custom/update" = {
          exec = "${onUpdate}/bin/update module";
          return-type = "json";
          interval = 3600;
          format = "{}";
          min-length = 2;
          max-length = 2;
          on-click = "${pkgs.kitty}/bin/kitty -e ${onUpdate}/bin/update";
          on-click-right = "pkill waybar";
        };

        mpris = {
          format = "{player_icon} {title} - {artist}";
          format-paused = "{status_icon} {title} - {artist}";
          tooltip-format = "Playing: {title} - {artist}";
          tooltip-format-paused = "Paused: {title} - {artist}";

          player-icons = {
            default = "󰐊";
          };
          status-icons = {
            paused = "󰏤";
          };

          max-length = 1000;
        };

        "group/pulseaudio" = {
          orientation = "horizontal";
          modules = [
            "pulseaudio#output"
            "pulseaudio#input"
          ];
          drawer = {
            transition-left-to-right = false;
          };
        };

        "pulseaudio#output" = {
          format = "{icon} {volume}%";
          format-muted = "{icon} {volume}%";

          format-icons = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
            default-muted = "󰝟";
            headphone = "󰋋";
            headphone-muted = "󰟎";
            headset = "󰋎";
            headset-muted = "󰋐";
          };

          min-length = 7;
          max-length = 7;

          on-click = "${onVolume}/bin/volume output mute";
          on-scroll-up = "${onVolume}/bin/volume output raise";
          on-scroll-down = "${onVolume}/bin/volume output lower";

          tooltip-format = "<b>Output Device</b>: {desc}";
        };

        "pulseaudio#input" = {
          format = "{format_source}";
          format-source = "󰍬 {volume}%";
          format-source-muted = "󰍭 {volume}%";

          min-length = 7;
          max-length = 7;

          on-click = "${onVolume}/bin/volume input mute";
          on-scroll-up = "${onVolume}/bin/volume input raise";
          on-scroll-down = "${onVolume}/bin/volume input lower";

          tooltip-format = "<b>Input Device</b>: {desc}";
        };

        backlight = {
          format = "{format} {percent}%";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
          ];

          min-length = 7;
          max-length = 7;
          on-scroll-up = "${onBacklight}/bin/backlight up";
          on-scroll-down = "${onBacklight}/bin/backlight down";

          tooltip-format = "Screen Brightness";
        };

        battery = {
          states = {
            warning = 20;
            critical = 10;
          };

          format = "{icon} {capacity}%";
          format-time = "{H}h {M}min";
          format-icons = [
            "󰂎"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];

          format-charging = "󰉁 {capacity}%";
          min-length = 7;
          max-length = 7;

          tooltip-format = "<b>Discharging</b>: {time}";
          tooltip-format-charging = "<b>Charging</b>: {time}";
          events = {
            on-discharging-warning = "notify-send 'Battery Low (20%)' -u critical -i 'battery-020' -h string:x-canonical-private-synchronous:battery";
            on-discharging-critical = "notify-send 'Battery Critical (10%)' -u critical -i 'battery-010' -h string:x-canonical-private-synchronous:battery";
            on-charging-100 = "notify-send 'Battery Full (100%)' -i 'battery-100-charged' -h string:x-canonical-private-synchronous:battery";
          };
        };

        "custom/power" = {
          format = "󰤄";
          on-click = "${pkgs.kitty}/bin/kitty -e ${onPower}/bin/power";
          tooltip-format = "Power Menu";
        };
      }
    ];

    style = ''
      /* Catppuccin Mocha */
      @define-color rosewater      #f5e0dc;
      @define-color flamingo       #f2cdcd;
      @define-color pink           #f5c2e7;
      @define-color mauve          #cba6f7;
      @define-color red            #f38ba8;
      @define-color maroon         #eba0ac;
      @define-color peach          #fab387;
      @define-color yellow         #f9e2af;
      @define-color green          #a6e3a1;
      @define-color teal           #94e2d5;
      @define-color sky            #89dceb;
      @define-color sapphire       #74c7ec;
      @define-color blue           #89b4fa;
      @define-color lavender       #b4befe;
      @define-color text           #cdd6f4;
      @define-color subtext1       #bac2de;
      @define-color subtext0       #a6adc8;
      @define-color overlay2       #9399b2;
      @define-color overlay1       #7f849c;
      @define-color overlay0       #6c7086;
      @define-color surface2       #585b70;
      @define-color surface1       #45475a;
      @define-color surface0       #313244;
      @define-color base           #1e1e2e;
      @define-color mantle         #181825;
      @define-color crust          #11111b;
      @define-color accent         @lavender;
      @define-color main-br        @subtext0;
      @define-color main-bg        @crust;
      @define-color main-fg        @text;
      @define-color hover-bg       @base;
      @define-color hover-fg       alpha(@main-fg, 0.75);
      @define-color outline        shade(@main-bg, 0.5);
      @define-color workspaces     @mantle;
      @define-color temperature    @mantle;
      @define-color memory         @base;
      @define-color cpu            @surface0;
      @define-color time           @surface0;
      @define-color date           @base;
      @define-color tray           @mantle;
      @define-color volume         @mantle;
      @define-color backlight      @base;
      @define-color battery        @surface0;
      @define-color warning        @yellow;
      @define-color critical       @red;
      @define-color charging       @green;

      * {
          all: initial;
          color: @main-fg;
      }

      * {
          font-family: "CommitMono Nerd Font";
          font-weight: bold;
          font-size: 16px;
      }
      #window label,
      #mpris,
      tooltip label {
          font-weight: normal;
      }

      #workspaces button.active label,
      #workspaces button.focused label,
      #custom-distro {
          font-size: 20px;
      }

      #custom-power {
          font-size: 18px;
      }

      #custom-left_div,
      #custom-left_inv,
      #custom-right_div,
      #custom-right_inv {
          font-size: 22px;
      }

      #custom-left_div.1,
      #custom-right_div.1 {
          color: @workspaces;
      }
      #workspaces {
          padding: 0 1px;
          background-color: @workspaces;
      }
      #workspaces button.active label,
      #workspaces button.focused label {
          color: @accent;
      }

      #window {
          margin: 0 12px;
      }

      #keyboard-state label,
      #language {
          margin-right: 12px;
          color: @hover-fg;
      }

      #custom-left_div.2 {
          color: @temperature;
      }
      #temperature {
          background-color: @temperature;
      }

      #custom-left_div.3 {
          background-color: @temperature;
          color: @memory;
      }
      #memory {
          background-color: @memory;
      }

      #custom-left_div.4 {
          background-color: @memory;
          color: @cpu;
      }
      #cpu {
          background-color: @cpu;
      }
      #custom-left_inv.1 {
          color: @cpu;
      }

      #custom-left_div.5,
      #custom-right_div.2 {
          color: @accent;
      }
      #custom-distro {
          padding: 0 10px 0 5px;
          background-color: @accent;
          color: @main-bg;
      }

      #custom-right_inv.1 {
          color: @time;
      }
      #idle_inhibitor {
          background-color: @time;
      }

      #clock.time {
          padding-right: 6px;
          background-color: @time;
      }
      #custom-right_div.3 {
          background-color: @date;
          color: @time;
      }

      #clock.date {
          padding-left: 6px;
          background-color: @date;
      }
      #custom-right_div.4 {
          background-color: @tray;
          color: @date;
      }

      #network {
          background-color: @tray;
          padding: 0 6px 0 4px;
      }
      #bluetooth {
          background-color: @tray;
          padding: 0 5px;
      }
      #custom-update {
          background-color: @tray;
          padding: 0 8px 0 2px;
      }
      #custom-right_div.5 {
          color: @tray;
      }

      #mpris {
          padding: 0 12px;
      }

      #custom-left_div.6 {
          color: @volume;
      }
      #pulseaudio,
      #wireplumber {
          background-color: @volume;
      }

      #custom-left_div.7 {
          background-color: @volume;
          color: @backlight;
      }
      #backlight {
          background-color: @backlight;
      }

      #custom-left_div.8 {
          background-color: @backlight;
          color: @battery;
      }
      #battery {
          background-color: @battery;
      }
      #custom-left_inv.2 {
          color: @battery;
      }

      #custom-power {
          border-radius: 16px;
          padding: 0 19px 0 16px;
          color: @accent;
      }
      #custom-power:hover {
          background-color: @hover-bg;
      }

      #custom-user:hover,
      #idle_inhibitor:hover,
      #clock.date:hover,
      #network:hover,
      #bluetooth:hover,
      #custom-update:hover,
      #mpris:hover,
      #pulseaudio:hover,
      #wireplumber:hover {
          color: @hover-fg;
      }

      #idle_inhibitor.deactivated,
      #mpris.paused,
      #pulseaudio.output.muted,
      #pulseaudio.input.source-muted,
      #wireplumber.muted {
          color: @hover-fg;
      }

      #memory.warning,
      #cpu.warning,
      #battery.warning {
          color: @warning;
      }

      #temperature.critical,
      #memory.critical,
      #cpu.critical,
      #battery.critical {
          color: @critical;
      }

      #battery.charging {
          color: @charging;
      }

      .module {
          margin-bottom: -1px;
      }

      #waybar {
          background-color: @outline;
      }
      #waybar > box {
          margin: 4px;
          background-color: @main-bg;
      }

      button {
          border-radius: 16px;
          min-width: 16px;
          padding: 0 10px;
      }
      button:hover {
          background-color: @hover-bg;
          color: @hover-fg;
      }

      tooltip {
          border: 2px solid @main-br;
          border-radius: 10px;
          background-color: @main-bg;
      }
      tooltip > box {
          padding: 0 6px;
      }
    '';
  };
}
