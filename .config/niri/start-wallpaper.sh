# kills previous instance of wallpaper engine on execution
# pkill awww-daemon

# opens: wallpaper engine ----- configiure the code below ----------------------------    
awww-daemon &

sleep 0.5

awww img "/home/rhythm/Pictures/Wallpapers/walls/digital/a_road_with_lightning_bolts_in_the_sky.png" \
  --transition-type wave \
  --transition-duration 1
