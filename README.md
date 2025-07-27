# fzusers

A fast, interactive Bash tool for managing Linux users and groups with an FZF-powered menu.

## Features

- Add new users with step-by-step prompts
- View user details, groups, and password info
- Lock, unlock, switch to, or delete users
- Change user passwords
- Add users to groups or remove them from groups
- Manage groups: add, modify, delete, add/remove users from groups
- All actions via a simple, searchable menu

## Requirements

- Bash
- [fzf](https://github.com/junegunn/fzf)
- Standard Linux utilities: `getent`, `awk`, `groups`, `id`, `sudo`, `useradd`, `usermod`, `userdel`, `groupadd`, `groupdel`, `gpasswd`, `chage`

## Installation

Clone the repository and run the install script:

```sh
git clone https://github.com/cmerrill00/fzusers.git
cd fzusers
bash install.sh
```

This will install `fzusers` to `/usr/local/bin/fzusers` (requires sudo).

## Usage

Simply run:

```sh
fzusers
```

You'll be presented with a menu to manage users and groups interactively.

## Notes

- You need to run this script with a user that has `sudo` privileges for user/group management.
- Make sure `fzf` is installed and available in your `$PATH`.
- Intended for use on Linux systems.

---