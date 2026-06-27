# kills previous instance of wallpaper engine on execution
# pkill awww-daemon

# opens: wallpaper engine ----- configiure the code below ----------------------------    
awww-daemon &

sleep 0.5

awww img "/home/rhythm/Pictures/Wallpapers/walls/solarized/a_red_sun_over_mountains.jpg" \
  --transition-type wave \
  --transition-duration 1
