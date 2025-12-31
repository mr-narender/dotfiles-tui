#!/usr/bin/env bash
# Auto-layout: 2 windows = side-by-side; 3 windows = top row 2 side-by-side, 3rd on bottom

normalize_two() {
  aerospace layout tiles horizontal
  aerospace flatten-workspace-tree
  aerospace balance-sizes
}

layout_three() {
  # Start from clean horizontal row, then drop the 3rd window to bottom using implicit container
  aerospace layout tiles horizontal
  aerospace focus --dfs-index 2 # focus the 3rd window (0-based DFS)
  aerospace move down           # creates v_tiles: top = h_tiles(1,2), bottom = 3
  aerospace balance-sizes
}

last=""
while :; do
  # Count windows in the focused workspace (includes floating)
  n="$(aerospace list-windows --workspace focused --count 2>/dev/null || echo 0)"

  # Avoid noisy re-runs
  key="$n"
  if [ "$key" != "$last" ]; then
    case "$n" in
    2) normalize_two ;;
    3) layout_three ;;
    *) : ;; # leave other counts unchanged
    esac
    last="$key"
  fi
  sleep 0.5
done
