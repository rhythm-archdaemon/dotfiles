import Quickshell 
import QtQuick 
import Quickshell.Io

ShellRoot {
	// ── Theme tokens ─────────────────────────────────────────────────
	// Catppuccin Mocha base + neon cyberpunk accents
	// Base: #1e1e2e (Mocha crust)
	// Mantle: #181825
	// Surface: #313244
	// Neon cyan: #89dceb (sky)
	// Neon pink: #f38ba8 (red)
	// Neon lavender:#cba6f7
	// Neon green: #a6e3a1
	// Subtext: #a6adc8
	// ─────────────────────────────────────────────────────────────────

	// ── Workspace state ───────────────────────────────────────────────
	QtObject { 
		id: workspaceState 
		property int active: 1
	}

	Process { 
		id: wsPoller 
		command: ["bash", "-c", "niri msg --json workspaces | python3 -c \"import sys,json; ws=json.load(sys.stdin); print(next((w['idx'] for w in ws if w['is_focused']),1))\""] 
		running: true 
		stdout: SplitParser { 
			onRead: data => { 
				var idx = parseInt(data.trim()) 
				if (!isNaN(idx)) workspaceState.active = idx 
			} 
		} 
	}

	Timer { 
		interval: 100 
		running: true 
		repeat: true 
		onTriggered: wsPoller.running = true
	}

	Process { 
		id: wsSwitcher 
		command: ["bash", "-c", "niri msg action focus-workspace " + workspaceState.active]
	}

	// ── Media state ───────────────────────────────────────────────────
	QtObject { 
		id: mediaState 
		property string trackInfo: "No Media" 
		property string status: "Stopped" 
		property int volume: 50 
		property string visualizer: "▁▁▁▁▁▁▁▁"
	}

	function updateMediaState(rawData) { 
		var trimmed = rawData.trim() 
		if (!trimmed) return 
		var parts = trimmed.split("|") 
		if (parts.length >= 2) { 
			mediaState.status = parts[0] 
			var rawTrack = parts[1].replace(/^ - /, "") 
			mediaState.trackInfo = rawTrack 
		} 
	}

	// CHANGE 1: playerctl --follow keeps a persistent process that emits
	// immediately on any track/status change — no polling lag at all.
	// The fallback poller still fires at 1000ms to handle edge cases
	// (e.g. player starts after the follow process launches).
	Process {
		id: mediaFollower
		command: ["bash", "-c",
			"playerctl --follow metadata --format '{{status}}|{{artist}} - {{title}}' 2>/dev/null" +
			" || echo 'Stopped|No Media'"
		]
		running: true
		stdout: SplitParser {
			onRead: data => {
				var trimmed = data.trim()
				if (!trimmed) return
				// --follow emits lines like "Playing|Artist - Title"
				var parts = trimmed.split("|")
				if (parts.length >= 2) {
					mediaState.status = parts[0]
					var rawTrack = parts[1].replace(/^ - /, "")
					mediaState.trackInfo = rawTrack
				} else if (trimmed === "Stopped" || trimmed === "Paused") {
					mediaState.status = trimmed
					mediaState.trackInfo = "No Media"
				}
			}
		}
	}

	// Fallback poller at 1000ms (was 3000ms) — catches cases where
	// playerctl --follow missed an event or player launched after follow started
	Process { 
		id: mediaPoller 
		command: ["bash", "-c", "status=$(playerctl status 2>/dev/null || echo 'Stopped'); title=$(playerctl metadata title 2>/dev/null || echo 'No Media'); artist=$(playerctl metadata artist 2>/dev/null || echo ''); if [ \"$status\" = \"Stopped\" ]; then echo \"Stopped|No Media\"; else echo \"$status|$artist - $title\"; fi"] 
		running: true 
		stdout: SplitParser { 
			onRead: data => updateMediaState(data) 
		} 
	}

	Timer { 
		interval: 500
		running: true 
		repeat: true 
		onTriggered: mediaPoller.running = true
	}

	Process { 
		id: mediaCmd 
		stdout: SplitParser { 
			onRead: data => updateMediaState(data) 
		} 
	}

	Process { 
		id: volumePoller 
		command: ["bash", "-c", "vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{printf \"%d\", $2*100}'); [ -z \"$vol\" ] && vol=$(amixer get Master 2>/dev/null | grep -oP '\\d+(?=%)' | head -1); echo ${vol:-50}"] 
		running: true 
		stdout: SplitParser { 
			onRead: data => { 
				var v = parseInt(data.trim()) 
				if (!isNaN(v)) mediaState.volume = Math.max(0, Math.min(100, v)) 
			} 
		} 
	}

	Timer { 
		interval: 2000 
		running: true 
		repeat: true 
		onTriggered: volumePoller.running = true
	}

	Process { 
		id: volumeCmd 
		command: ["bash", "-c", "echo idle"]
	}

	// CHANGE 2: vizFallbackTimer always running (not gated on expand)
	// so the cava pill in the bar is always animated
	Timer { 
		id: vizFallbackTimer 
		interval: 200 
		running: true
		repeat: true 
		property int tick: 0 
		onTriggered: { 
			if (mediaState.status !== "Playing") { 
				mediaState.visualizer = "▁▁▁▁▁▁▁▁" 
				return 
			} 
			tick++ 
			var seeds = [3,7,1,5,2,8,4,6] 
			var blocks = ["▁","▂","▃","▄","▅","▆","▇","█"] 
			var bar = "" 
			for (var i = 0; i < 8; i++) { 
				var v = Math.abs(Math.sin((tick + seeds[i]) * 0.37 + i)) 
				bar += blocks[Math.min(7, Math.floor(v * 8))] 
			} 
			mediaState.visualizer = bar 
		}
	}

	// ── Network state ─────────────────────────────────────────────────
	QtObject { 
		id: networkState 
		property var ssids: [] 
		property string pendingConnect: "" 
		property bool showPasswordInput: false
	}

	Process { 
		id: wifiPoller 
		command: ["bash", "-c", "nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2 || echo 'offline'"] 
		running: true 
		stdout: SplitParser { 
			onRead: data => { 
				var ssid = data.trim() 
				if (ssid === "" || ssid === "offline") { 
					wifiText.text = "󰤭 offline" 
					wifiText.color = "#f38ba8" 
				} else { 
					wifiText.text = "󰤨 " + ssid.substring(0, 14) 
					wifiText.color = "#89dceb" 
				} 
			} 
		} 
	}

	Process { 
		id: wifiScanner 
		command: ["bash", "-c", "nmcli -t -f ssid dev wifi 2>/dev/null | sort -u | grep -v '^$' | python3 -c \"import sys, json; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))\""] 
		stdout: SplitParser { 
			onRead: data => { 
				try { 
					networkState.ssids = JSON.parse(data.trim()) 
				} catch(e) {} 
			} 
		} 
	}

	Process { 
		id: wifiCmd 
		stdout: SplitParser { 
			onRead: data => { 
				var msg = data.trim() 
				if (msg.indexOf("successfully") >= 0 || msg.indexOf("already") >= 0) { 
					wifiText.text = "󰤨 " + networkState.pendingConnect.substring(0,14) 
					wifiText.color = "#89dceb" 
					networkState.showPasswordInput = false 
					networkState.pendingConnect = "" 
					pwInput.text = "" 
				} 
			} 
		} 
	}

	Timer { 
		interval: 10000 
		running: true 
		repeat: true 
		onTriggered: wifiPoller.running = true
	}

	// ── Battery state ─────────────────────────────────────────────────
	QtObject { 
		id: batteryState 
		property bool limitActive: false
	}

	Process { 
		id: batteryPoller 
		command: ["bash", "-c", "echo $(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null || echo '--') $(cat /sys/class/power_supply/BAT1/status 2>/dev/null || echo 'Unknown')"] 
		running: true 
		stdout: SplitParser { 
			onRead: data => { 
				var parts = data.trim().split(" ") 
				if (parts.length >= 2) { 
					var level = parseInt(parts[0]) 
					var status = parts[1].trim() 
					var icon = status === "Charging" ? "󰂄" : level > 50 ? "󰁹" : level > 20 ? "󰁾" : "󰁺" 
					var col = level <= 20 && status !== "Charging" ? "#f38ba8" : "#a6adc8" 
					batteryText.text = icon + " " + level + "%" 
					batteryText.color = col 
				} 
			} 
		} 
	}

	// CHANGE 3: battery charge cap via pkexec so it can actually write
	// to the sysfs path which requires root.
	// Prerequisite: install a polkit rule (see comment below) OR
	// add to /etc/sudoers.d/battery:
	//   username ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/class/power_supply/BAT1/charge_control_end_threshold
	// Then change pkexec below to: sudo tee ...
	Process { 
		id: batteryCmd 
		command: ["bash", "-c", "echo idle"]
	}

	Timer { 
		interval: 30000 
		running: true 
		repeat: true 
		onTriggered: batteryPoller.running = true
	}

	// ── Brightness & Night Light ──────────────────────────────────────
	QtObject { 
		id: brightnessState 
		property int value: 22800
	}
	
	Process { id: brightnessCmd; command: ["bash", "-c", "echo idle"] }
	Process { id: nightLightCmd; command: ["bash", "-c", "echo idle"] }

	// ─────────────────────────────────────────────────────────────────
	// ── TOP PANEL WINDOW ─────────────────────────────────────────────
	// ─────────────────────────────────────────────────────────────────
	PanelWindow {
		anchors.top: true
		anchors.left: true
		anchors.right: true
		margins.top: 3
		margins.left: 15
		margins.right: 15
		color: "transparent"
		exclusiveZone: 30 + 5

		// Dynamic height — only rightPill expands now; mediaPill is always 32
		implicitHeight: Math.max(40, rightPill.height + 4)

		// ── Solid Full Panel Base Bar ────────────────────────────────
		Rectangle {
			id: mainPanelBar
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.right: parent.right
			height: 40
			color: "#1e1e2e"
			radius: 14
			border.color: "#313244"
      border.width: 1

			// ── LEFT SIDE: Power + Workspaces + Media + Cava ─────────
			Rectangle {
				id: powerPill
				anchors.left: parent.left
				anchors.leftMargin: 10
				anchors.verticalCenter: parent.verticalCenter
				width: 64
				height: 32
				color: "#181825"
				radius: 10
				border.color: "#f38ba8"
				border.width: 1

				Row {
					anchors.centerIn: parent
					spacing: 12
					
					Text {
						anchors.verticalCenter: parent.verticalCenter
						text: "󰌾"
						color: "#a6adc8"
						font.pixelSize: 14 
						font.family: "MesloLGS Nerd Font"
						MouseArea {
							anchors.fill: parent
							cursorShape: Qt.PointingHandCursor
							hoverEnabled: true
							onEntered: parent.color = "#cba6f7"
							onExited: parent.color = "#a6adc8"
							onClicked: {
								var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ["bash","-c","gtklock &"]; running: true }', powerPill)
							}
						}
					}

					Text {
						anchors.verticalCenter: parent.verticalCenter
						text: "󰐥"
						color: "#a6adc8"
						font.pixelSize: 14
						font.family: "MesloLGS Nerd Font"
						MouseArea {
							anchors.fill: parent
							cursorShape: Qt.PointingHandCursor
							hoverEnabled: true
							onEntered: parent.color = "#f38ba8"
							onExited: parent.color = "#a6adc8"
							onClicked: {
								var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ["bash","-c","systemctl poweroff"]; running: true }', powerPill)
							}
						}
					}
				}
			}

			Rectangle {
				id: workspacePill
				anchors.left: powerPill.right
				anchors.leftMargin: 8
				anchors.verticalCenter: parent.verticalCenter
				width: 160
				height: 32
				color: "#181825"
				radius: 10
				border.color: "#89dceb"
				border.width: 1

				Row {
					anchors.centerIn: parent
					spacing: 4
					Repeater {
						model: 5
						delegate: Rectangle {
							width: 24 
							height: 20
							radius: 6
							property bool isActive: (index + 1) === workspaceState.active
							color: isActive ? "#89dceb" : "#313244"
							border.color: isActive ? "#89dceb" : "#45475a"
							border.width: 1
							
							Rectangle {
								anchors.fill: parent
								radius: parent.radius
								color: "transparent"
								border.color: "#89dceb"
								border.width: 2
								opacity: isActive ? 0.4 : 0
								anchors.margins: -2
							}
							
							Text {
								anchors.centerIn: parent
								text: index + 1
								color: isActive ? "#1e1e2e" : "#585b70"
								font.pixelSize: 10
								font.bold: true
							}
							
							MouseArea {
								anchors.fill: parent
								cursorShape: Qt.PointingHandCursor
								onClicked: {
									workspaceState.active = index + 1
									wsSwitcher.running = true
								}
							}
						}
					}
				}
			}

			// Music player pill — flat inline controls, no expand
			// Layout: [play/pause icon] [track name] [prev] [next]
			Rectangle {
				id: mediaPill
				anchors.left: workspacePill.right
				anchors.leftMargin: 8
				anchors.verticalCenter: parent.verticalCenter
				height: 32
				// Width hugs content: icon + separator + track text + two nav icons + padding
				width: mediaPillRow.implicitWidth + 24
				color: "#181825"
				radius: 10
				border.color: "#a6e3a1"
				border.width: 1

				Row {
					id: mediaPillRow
					anchors.centerIn: parent
					spacing: 8

					// Play / Pause icon — clicking toggles playback
					Text {
						id: playPauseIcon
						anchors.verticalCenter: parent.verticalCenter
						text: mediaState.status === "Playing" ? "󰏤" : "󰐊"
						color: mediaState.status === "Playing" ? "#a6e3a1" : "#585b70"
						font.pixelSize: 15
						font.family: "MesloLGS Nerd Font"

						MouseArea {
							anchors.fill: parent
							cursorShape: Qt.PointingHandCursor
							hoverEnabled: true
							onEntered: parent.color = "#a6e3a1"
							onExited: parent.color = mediaState.status === "Playing" ? "#a6e3a1" : "#585b70"
							onClicked: {
								mediaCmd.command = ["bash", "-c",
									"playerctl play-pause;" +
									"status=$(playerctl status 2>/dev/null || echo 'Stopped');" +
									"title=$(playerctl metadata title 2>/dev/null || echo 'No Media');" +
									"artist=$(playerctl metadata artist 2>/dev/null || echo '');" +
									"echo \"$status|$artist - $title\""]
								mediaCmd.running = true
							}
						}
					}

					// Separator
					Text {
						anchors.verticalCenter: parent.verticalCenter
						text: "|"
						color: "#a6e3a1"
						font.pixelSize: 12
						opacity: 1
					}

					// Track name — truncated to 22 chars
					Text {
						id: trackText
						anchors.verticalCenter: parent.verticalCenter
						text: mediaState.trackInfo.length > 22
							? mediaState.trackInfo.substring(0, 22) + "…"
							: mediaState.trackInfo
						color: "#cdd6f4"
						font.pixelSize: 11
						font.bold: true
					}

					// Separator
					Text {
						anchors.verticalCenter: parent.verticalCenter
						text: "|"
						color: "#a6e3a1"
						font.pixelSize: 12
						opacity: 1
					}

					// Previous
					Text {
						anchors.verticalCenter: parent.verticalCenter
						text: "󰒮"
						color: "#585b70"
						font.pixelSize: 15
						font.family: "MesloLGS Nerd Font"

						MouseArea {
							anchors.fill: parent
							cursorShape: Qt.PointingHandCursor
							hoverEnabled: true
							onEntered: parent.color = "#a6e3a1"
							onExited: parent.color = "#585b70"
							onClicked: {
								mediaCmd.command = ["bash", "-c",
									"playerctl previous;" +
									"status=$(playerctl status 2>/dev/null || echo 'Stopped');" +
									"title=$(playerctl metadata title 2>/dev/null || echo 'No Media');" +
									"artist=$(playerctl metadata artist 2>/dev/null || echo '');" +
									"echo \"$status|$artist - $title\""]
								mediaCmd.running = true
							}
						}
          }
          //Separator 
          Text {
						anchors.verticalCenter: parent.verticalCenter
						text: " - "
						color: "#a6e3a1"
						font.pixelSize: 12
						opacity: 1
					}
					// Next
					Text {
						anchors.verticalCenter: parent.verticalCenter
						text: "󰒭"
						color: "#585b70"
						font.pixelSize: 15
						font.family: "MesloLGS Nerd Font"

						MouseArea {
							anchors.fill: parent
							cursorShape: Qt.PointingHandCursor
							hoverEnabled: true
							onEntered: parent.color = "#a6e3a1"
							onExited: parent.color = "#585b70"
							onClicked: {
								mediaCmd.command = ["bash", "-c",
									"playerctl next;" +
									"status=$(playerctl status 2>/dev/null || echo 'Stopped');" +
									"title=$(playerctl metadata title 2>/dev/null || echo 'No Media');" +
									"artist=$(playerctl metadata artist 2>/dev/null || echo '');" +
									"echo \"$status|$artist - $title\""]
								mediaCmd.running = true
							}
						}
					}
				}
			}

			// CHANGE 2: Standalone cava visualizer pill — no expand, purely decorative
			// Always shows the animated bar, anchored right of mediaPill
			Rectangle {
				id: cavaPill
				anchors.left: mediaPill.right
				anchors.leftMargin: 8
				anchors.verticalCenter: parent.verticalCenter
				width: 80
				height: 32
				color: "#181825"
				radius: 10
				border.color: "#a6e3a1"
				border.width: 1
				opacity: mediaState.status === "Playing" ? 1.0 : 0.35

				Behavior on opacity { NumberAnimation { duration: 100 } }

				Text {
					anchors.centerIn: parent
					text: mediaState.visualizer
					color: "#a6e3a1"
          font.pixelSize: 10
					font.family: "MesloLGS Nerd Font"
					// subtle vertical nudge so block chars sit centered optically
					anchors.verticalCenterOffset: 1
				}
			}

			// ── RIGHT SIDE: WiFi/Battery/Brightness + Clock ───────────
			Rectangle {
				id: clockPill
				anchors.right: parent.right
				anchors.rightMargin: 10
				anchors.verticalCenter: parent.verticalCenter
				width: 180
				height: 32
				color: "#181825"
				radius: 10
				border.color: "#cba6f7"
				border.width: 1

				Rectangle {
					anchors.fill: parent; radius: parent.radius
					color: "transparent"
					border.color: "#cba6f7"
					border.width: 1
					opacity: 0.25
					anchors.margins: -2
				}

				Row {
					anchors.centerIn: parent
					spacing: 6
					
					Text {
						anchors.verticalCenter: parent.verticalCenter
						text: Qt.formatTime(new Date(), "hh:mm AP")
						color: "#cba6f7"
						font.pixelSize: 12
						font.bold: true
						font.letterSpacing: 1
						Timer {
							interval: 1000; running: true; repeat: true
							onTriggered: parent.text = Qt.formatTime(new Date(), "hh:mm AP")
						}
					}
					
					Text {
						anchors.verticalCenter: parent.verticalCenter
						text: "|"
						color: "#cba6f7"
						font.pixelSize: 12
						opacity: 1
					}
					
					Text {
						id: dateText
						anchors.verticalCenter: parent.verticalCenter
						text: Qt.formatDate(new Date(), "ddd, MMM d")
						color: "#a6adc8"
						font.pixelSize: 12
						font.bold: false
						Timer {
							interval: 60000; running: true; repeat: true
							onTriggered: parent.text = Qt.formatDate(new Date(), "ddd, MMM - d")
						}
					}
				}
			}

			Rectangle {
				id: rightPill
				anchors.right: clockPill.left
				anchors.rightMargin: 8
				anchors.top: parent.top
				anchors.topMargin: 4
				property string activeSection: "none"
				width: 200
				height: {
					if (activeSection === "wifi") {
						var base = 38 + 8
						var rows = networkState.ssids.length * 26
						var pwExtra = networkState.showPasswordInput ? 36 : 0
						return base + rows + pwExtra + 10
					} else if (activeSection === "battery") {
						return 78
					} else if (activeSection === "brightness") {
						return 78
					} else {
						return 32
					}
				}
				color: "#181825"
				radius: 10
				border.color: "#89dceb"
				border.width: 1
				clip: true

				Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

				MouseArea {
					anchors.fill: parent
					hoverEnabled: true
					acceptedButtons: Qt.NoButton
					onExited: {
						rightPill.activeSection = "none"
						networkState.showPasswordInput = false
						pwInput.text = ""
					}
				}

				Row {
					anchors.top: parent.top
					anchors.horizontalCenter: parent.horizontalCenter
					height: 32
					spacing: 10
					
					Text {
						id: wifiText
						anchors.verticalCenter: parent.verticalCenter
						text: "󰤨 ..."
						color: rightPill.activeSection === "wifi" ? "#89dceb" : "#cdd6f4"
						font.pixelSize: 12
						font.family: "MesloLGS Nerd Font"
						MouseArea {
							anchors.fill: parent
							cursorShape: Qt.PointingHandCursor
							onClicked: {
								rightPill.activeSection = rightPill.activeSection === "wifi" ? "none" : "wifi"
								if (rightPill.activeSection === "wifi") wifiScanner.running = true
							}
						}
					}
					
					Text { anchors.verticalCenter: parent.verticalCenter; text: "|"; color: "#89dceb"; font.pixelSize: 11; opacity: 0.4 }
					
					Text {
						id: batteryText
						anchors.verticalCenter: parent.verticalCenter
						text: "󰁹 --%"
						color: rightPill.activeSection === "battery" ? "#89dceb" : "#a6adc8"
						font.pixelSize: 12
						font.family: "MesloLGS Nerd Font"
						MouseArea {
							anchors.fill: parent
							cursorShape: Qt.PointingHandCursor
							onClicked: rightPill.activeSection = rightPill.activeSection === "battery" ? "none" : "battery"
						}
					}
					
					Text { anchors.verticalCenter: parent.verticalCenter; text: "|"; color: "#89dceb"; font.pixelSize: 11; opacity: 0.4 }
					
					Text {
						anchors.verticalCenter: parent.verticalCenter
						text: "󰃟"
						color: rightPill.activeSection === "brightness" ? "#89dceb" : "#cdd6f4"
						font.pixelSize: 14
						font.family: "MesloLGS Nerd Font"
						MouseArea {
							anchors.fill: parent
							cursorShape: Qt.PointingHandCursor
							onClicked: rightPill.activeSection = rightPill.activeSection === "brightness" ? "none" : "brightness"
						}
					}
				}

				Rectangle {
					anchors.top: parent.top
					anchors.topMargin: 32
					width: parent.width; height: 1
					color: "#89dceb"
					opacity: 0.25
					visible: rightPill.activeSection !== "none"
				}

				Row {
					anchors.top: parent.top
					anchors.topMargin: 44
					anchors.horizontalCenter: parent.horizontalCenter
					spacing: 10
					visible: rightPill.activeSection === "brightness"
					
					Text { anchors.verticalCenter: parent.verticalCenter; text: "󰃟"; color: "#cdd6f4"; font.pixelSize: 13; font.family: "MesloLGS Nerd Font" }
					
					Rectangle {
						id: sliderTrack
						anchors.verticalCenter: parent.verticalCenter
						width: 140; height: 4; radius: 2
						color: "#313244"
						
						Rectangle {
							width: sliderTrack.width * (brightnessState.value / 24000)
							height: parent.height; radius: 2
							color: "#cba6f7"
						}
						
						Rectangle {
							x: sliderTrack.width * (brightnessState.value / 24000) - 6
							anchors.verticalCenter: parent.verticalCenter
							width: 12; height: 12; radius: 6
							color: "#cdd6f4"
							border.color: "#cba6f7"; border.width: 1
						}
						
						MouseArea {
							anchors.fill: parent
							function setBrightness(mx) {
								var raw = Math.round((mx / sliderTrack.width) * 24000)
								brightnessState.value = Math.max(1000, Math.min(24000, raw))
								brightnessCmd.command = ["bash", "-c", "brightnessctl set " + brightnessState.value]
								brightnessCmd.running = true
							}
							onClicked: function(mouse) { setBrightness(mouse.x) }
							onPositionChanged: function(mouse) { if (pressed) setBrightness(mouse.x) }
						}
					}
					
					Text {
						id: nightLightIcon
						anchors.verticalCenter: parent.verticalCenter
						text: "󰛨"
						color: nightLightIcon.nightLightState ? "#f9e2af" : "#45475a"
						font.pixelSize: 14
						font.family: "MesloLGS Nerd Font"
						property bool nightLightState: false
						MouseArea {
							anchors.fill: parent
							cursorShape: Qt.PointingHandCursor
							onClicked: {
								nightLightIcon.nightLightState = !nightLightIcon.nightLightState
								nightLightCmd.command = ["bash", "-c", nightLightIcon.nightLightState ? "wlsunset -l 27.7 -L 85.3" : "pkill wlsunset"]
								nightLightCmd.running = true
							}
						}
					}
				}

				Row {
					anchors.top: parent.top
					anchors.topMargin: 48
					anchors.horizontalCenter: parent.horizontalCenter
					spacing: 14
					visible: rightPill.activeSection === "battery"
					
					Text { anchors.verticalCenter: parent.verticalCenter; text: "Limit charge to 80%"; color: "#a6adc8"; font.pixelSize: 11; font.bold: true }
					
					Rectangle {
						anchors.verticalCenter: parent.verticalCenter
						width: 34; height: 18; radius: 9
						color: batteryState.limitActive ? "#a6e3a1" : "#313244"
						border.color: batteryState.limitActive ? "#a6e3a1" : "#45475a"; border.width: 1
						
						Rectangle {
							x: batteryState.limitActive ? 17 : 2
							anchors.verticalCenter: parent.verticalCenter
							width: 13; height: 13; radius: 7
							color: "#1e1e2e"
							Behavior on x { NumberAnimation { duration: 150 } }
						}
						
						MouseArea {
							anchors.fill: parent
							cursorShape: Qt.PointingHandCursor
							onClicked: {
								batteryState.limitActive = !batteryState.limitActive
								var val = batteryState.limitActive ? 80 : 100
								// Uses pkexec to write as root — requires polkit or sudoers rule
								// Sudoers rule (recommended, add via visudo):
								//   YOUR_USER ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/class/power_supply/BAT1/charge_control_end_threshold
								// Then replace the command below with:
								//   "echo " + val + " | sudo tee /sys/class/power_supply/BAT1/charge_control_end_threshold"
								batteryCmd.command = ["bash", "-c",
									"echo " + val + " | pkexec tee /sys/class/power_supply/BAT1/charge_control_end_threshold"]
								batteryCmd.running = true
							}
						}
					}
				}

				Column {
					anchors.top: parent.top
					anchors.topMargin: 38
					anchors.left: parent.left; anchors.leftMargin: 14
					anchors.right: parent.right; anchors.rightMargin: 14
					spacing: 4
					visible: rightPill.activeSection === "wifi"
					
					Repeater {
						model: networkState.ssids
						delegate: Row {
							spacing: 8; height: 24; width: parent.width
							Text {
								width: parent.width - 62
								text: modelData; color: "#cdd6f4"; font.pixelSize: 11
								elide: Text.ElideRight; anchors.verticalCenter: parent.verticalCenter
							}
							Rectangle {
								width: 54; height: 20; color: "#313244"; radius: 5
								border.color: "#89dceb"; border.width: 1
								anchors.verticalCenter: parent.verticalCenter
								Text { anchors.centerIn: parent; text: "Connect"; color: "#89dceb"; font.pixelSize: 9; font.bold: true }
								MouseArea {
									anchors.fill: parent
									cursorShape: Qt.PointingHandCursor
									onClicked: {
										if (networkState.pendingConnect === modelData && networkState.showPasswordInput) {
											networkState.showPasswordInput = false
											networkState.pendingConnect = ""
										} else {
											networkState.pendingConnect = modelData
											networkState.showPasswordInput = true
											pwInput.text = ""
											pwInput.forceActiveFocus()
										}
									}
								}
							}
						}
					}

					Row {
						visible: networkState.showPasswordInput
						spacing: 6; height: networkState.showPasswordInput ? 30 : 0; width: parent.width
						TextInput {
							id: pwInput
							width: parent.width - 52; height: 26
							anchors.verticalCenter: parent.verticalCenter
							color: "#cdd6f4"; font.pixelSize: 11
							echoMode: TextInput.Password; leftPadding: 8
							Rectangle {
								anchors.fill: parent; anchors.margins: -1; radius: 5
								color: "#313244"; border.color: "#cba6f7"; border.width: 1; z: -1
							}
							Keys.onReturnPressed: connectBtn.doConnect()
						}
						Rectangle {
							id: connectBtn
							width: 44; height: 26; color: "#313244"; radius: 5
							border.color: "#a6e3a1"; border.width: 1
							anchors.verticalCenter: parent.verticalCenter
							function doConnect() {
								var ssid = networkState.pendingConnect
								var pw = pwInput.text
								wifiText.text = "󰤨 Connecting…"
								wifiText.color = "#cba6f7"
								if (pw.length > 0) {
									wifiCmd.command = ["bash", "-c", "nmcli dev wifi connect '" + ssid + "' password '" + pw + "' 2>&1 | tail -1"]
								} else {
									wifiCmd.command = ["bash", "-c", "nmcli dev wifi connect '" + ssid + "' 2>&1 | tail -1"]
								}
								wifiCmd.running = true
								networkState.showPasswordInput = false
							}
							Text { anchors.centerIn: parent; text: "OK"; color: "#a6e3a1"; font.pixelSize: 9; font.bold: true }
							MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: connectBtn.doConnect() }
						}
					}
				}
			}
		}
	}
}
