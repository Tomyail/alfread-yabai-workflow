#!/bin/bash

# 定义 get_yabai_action 函数
get_yabai_action() {
  # 获取当前所有的 spaces
  spaces=$(yabai -m query --spaces)

  # 动态生成 spaces 信息
  spaces_json=$(echo "$spaces" | jq -r '.[] | {
    title: ("Space " + (.index | tostring)),
    subtitle: ("切换到 Space " + (.index | tostring)),
    arg: ("switch_space " + (.index | tostring))
  } | @json' | sed 's/^/    /' | sed '$!s/$/,/')

  # 开始生成 JSON
  cat <<EOB
{
  "items": [
    {
      "title": "Toggle Layout",
      "subtitle": "切换布局",
      "arg": "toggle_layout"
    },
    {
      "title": "Cycle Clockwise",
      "subtitle":"顺时针循环调整窗口(option + r)",
      "arg": "cycle_clockwise"
    },
    {
      "title": "Swap to Last Window",
      "subtitle":"将当前窗口与最后一个窗口交换",
      "arg": "swap_to_last_win"
    },
    {
      "title": "Switch Previous Space",
      "subtitle":"切换到上一个 Space(shift + option + h)",
      "arg": "switch_prev_space"
    },
    {
      "title": "Switch Next Space",
      "subtitle":"切换到下一个 Space(shift + option + l)",
      "arg": "switch_next_space"
    },
$spaces_json
  ]
}
EOB
}

# 函数：发送系统通知
send_notification() {
  local message="$1"
  osascript -e "display notification \"$message\" with title \"Yabai 布局已更改\""
}

# 在 float 和 bsp 布局之间切换
toggle_layout() {
  # 获取当前 space 的布局
  current_layout=$(yabai -m query --spaces --space | jq -r '.type')

  # 切换布局
  if [ "$current_layout" = "bsp" ]; then
    yabai -m space --layout float
    send_notification "已切换到 float 布局"
  else
    yabai -m space --layout bsp
    send_notification "已切换到 bsp 布局"
  fi
}

# 顺时针循环调整窗口
cycle_clockwise() {
  win=$(yabai -m query --windows --window last | jq '.id')
  while :; do
    yabai -m window $win --swap prev &>/dev/null
    if [[ $? -eq 1 ]]; then
      break
    fi
  done
}

swap_to_last_win() {
  yabai -m window --swap last
}

switch_space() {
  local space_index="$1"
  yabai -m space --focus "$space_index"
  send_notification "已切换到 Space $space_index"
}

switch_next_space() {
  if [[ $(yabai -m query --spaces --display | jq '.[-1]."has-focus"') == "false" ]]; then yabai -m space --focus next; fi
}

switch_prev_space() {
  if [[ $(yabai -m query --spaces --display | jq '.[0]."has-focus"') == "false" ]]; then yabai -m space --focus prev; fi
}

action="$1"
case "$action" in
"get_yabai_action")
  get_yabai_action
  ;;
"toggle_layout")
  toggle_layout
  ;;
"cycle_clockwise")
  cycle_clockwise
  ;;
"cycle_counterclockwise")
  cycle_counterclockwise
  ;;
"swap_to_last_win")
  swap_to_last_win
  ;;
"switch_next_space")
  switch_next_space
  ;;
"switch_prev_space")
  switch_prev_space
  ;;
"switch_space "*)
  space_index="${action#switch_space }"
  switch_space "$space_index"
  ;;
*)
  send_notification "Unknown action: $action"
  ;;
esac
