# kills previous instance of wallpaper engine on execution
# pkill awww-daemon

# opens: wallpaper engine ----- configiure the code below ----------------------------
awww-daemon &

sleep 0.5

awww img "/home/rhythm/Pictures/Wallpapers/walls/unsorted/a_car_on_a_wet_road.jpg" \
  --transition-type wave \
  --transition-duration 1
