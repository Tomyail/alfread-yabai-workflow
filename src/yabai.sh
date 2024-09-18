#!/bin/bash

# 定义 get_yabai_action 函数
get_yabai_action() {
  cat << EOB
{
  "items": [
    {
      "title": "Toggle Layout",
      "arg": "toggle_layout"
    },
    {
      "title": "Send Current Active Window to Space",
      "arg": "send_window_to_space"
    }
  ]
}
EOB
}



# 函数：发送系统通知
send_notification() {
    local message="$1"
    osascript -e "display notification \"$message\" with title \"Yabai 布局已更改\""
}

toggle_layout(){



# 获取当前 space 的布局
current_layout=$(yabai -m query --spaces --space | jq -r '.type')

# 切换布局
if [ "$current_layout" = "bsp" ]; then
    yabai -m space --layout float
    send_notification "已切换到 float 布局"
elif [ "$current_layout" = "float" ]; then
    yabai -m space --layout bsp
    send_notification "已切换到 bsp 布局"
else
    yabai -m space --layout bsp
    send_notification "已切换到 bsp 布局"
fi
}


if [ "$1" = "get_yabai_action" ]; then
  get_yabai_action
  exit
elif [ "$1" = "toggle_layout" ]; then
  toggle_layout
  exit
else 
  send_notification "未知的操作"
  exit 1
fi
