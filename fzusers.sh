#!/bin/bash

# Collect user and group lists
user_list=$(getent passwd | awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}')
group_list=$(getent group | awk -F: '$3 >= 1000 {print $1}')

menu_list=$(printf "Add New User\nManage Groups\n%s" "$user_list")

choice=$(printf '%s\n' "$menu_list" | \
  fzf --prompt="Select a user, add new, or manage groups: " \
      --preview='
        if [ "{}" = "Add New User" ]; then
          echo "Create a new Linux user account."
        elif [ "{}" = "Manage Groups" ]; then
          echo "Manage Linux groups: add or modify."
        else
          getent passwd {} | awk -F: "{print \"Username: \" \$1 \"\nUID: \" \$3 \"\nGID: \" \$4 \"\nFull Name: \" \$5 \"\nHome: \" \$6 \"\nShell: \" \$7}"
          echo
          echo "Groups:"
          groups {}
        fi
      ' \
      --preview-window=right:70%:wrap \
      --header="🔐 fzusers - Local User & Group Manager" \
      --bind "enter:accept")

[[ -z "$choice" ]] && exit 0

if [[ "$choice" == "Add New User" ]]; then
  read -rp "Enter new username: " newuser
  read -rp "Enter full name (comment): " fullname
  read -rp "Enter shell [/bin/bash]: " shell
  shell=${shell:-/bin/bash}
  read -rp "Enter home directory [/home/$newuser]: " homedir
  homedir=${homedir:-/home/$newuser}
  sudo useradd -m -c "$fullname" -s "$shell" -d "$homedir" "$newuser" && echo "✅ User '$newuser' created."
  sudo passwd "$newuser"
  exit 0
fi

if [[ "$choice" == "Manage Groups" ]]; then
  group_action=$(printf "Add Group\nModify Group\nCancel" | \
    fzf --prompt="Group Action: " --header="🛠️ Group Management")
  case "$group_action" in
    "Add Group")
      read -rp "Enter new group name: " newgroup
      sudo groupadd "$newgroup" && echo "✅ Group '$newgroup' created."
      ;;
    "Modify Group")
      mod_group=$(printf "%s\n" $group_list | fzf --prompt="Select group to modify: ")
      [[ -z "$mod_group" ]] && exit 0
      mod_action=$(printf "Add User to Group\nRemove User from Group\nDelete Group\nCancel" | \
        fzf --prompt="Modify $mod_group: ")
      case "$mod_action" in
        "Add User to Group")
          add_user=$(printf "%s\n" $user_list | fzf --prompt="Select user to add: ")
          [[ -z "$add_user" ]] && exit 0
          sudo usermod -aG "$mod_group" "$add_user" && echo "✅ Added '$add_user' to '$mod_group'."
          ;;
        "Remove User from Group")
          group_members=$(getent group "$mod_group" | awk -F: '{print $4}' | tr ',' '\n')
          rem_user=$(printf "%s\n" $group_members | fzf --prompt="Select user to remove: ")
          [[ -z "$rem_user" ]] && exit 0
          sudo gpasswd -d "$rem_user" "$mod_group" && echo "✅ Removed '$rem_user' from '$mod_group'."
          ;;
        "Delete Group")
          read -rp "Are you sure you want to delete group '$mod_group'? [y/N] " confirm
          if [[ "$confirm" =~ ^[Yy]$ ]]; then
            sudo groupdel "$mod_group" && echo "🗑️ Group '$mod_group' deleted."
          else
            echo "❌ Cancelled."
          fi
          ;;
        *)
          echo "No action taken."
          ;;
      esac
      ;;
    *)
      echo "No action taken."
      ;;
  esac
  exit 0
fi

# Action menu for users
action=$(printf "View Details\nLock User\nUnlock User\nSwitch to User\nDelete User\nChange Password\nAdd User to Group\nRemove User from Group\nCancel" | \
  fzf --prompt="Action for $choice: " --header="🛠️ Choose Action")

case "$action" in
  "View Details")
    echo "User Info:"
    getent passwd "$choice"
    echo
    echo "Groups:"
    groups "$choice"
    echo
    echo "Password Info:"
    chage -l "$choice"
    ;;
  "Lock User")
    sudo usermod -L "$choice" && echo "✅ User '$choice' locked."
    ;;
  "Unlock User")
    sudo usermod -U "$choice" && echo "✅ User '$choice' unlocked."
    ;;
  "Switch to User")
    echo "Switching to $choice. Type 'exit' to return."
    exec sudo su - "$choice"
    ;;
  "Delete User")
    read -rp "Are you sure you want to delete user '$choice'? [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      sudo userdel -r "$choice" && echo "🗑️ User '$choice' deleted."
    else
      echo "❌ Cancelled."
    fi
    ;;
  "Change Password")
    sudo passwd "$choice"
    ;;
  "Add User to Group")
    target_group=$(printf "%s\n" $group_list | fzf --prompt="Select group to add $choice to: ")
    [[ -z "$target_group" ]] && echo "No group selected." && exit 0
    sudo usermod -aG "$target_group" "$choice" && echo "✅ Added '$choice' to '$target_group'."
    ;;
  "Remove User from Group")
    # Show only groups the user is a member of
    user_groups=$(id -nG "$choice" | tr ' ' '\n')
    remove_group=$(printf "%s\n" $user_groups | fzf --prompt="Select group to remove $choice from: ")
    [[ -z "$remove_group" ]] && echo "No group selected." && exit 0
    sudo gpasswd -d "$choice" "$remove_group" && echo "✅ Removed '$choice' from '$remove_group'."
    ;;
  *)
    echo "No action taken."
    ;;
esac
