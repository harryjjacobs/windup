#!/bin/bash

set -euxo pipefail

function prompt_user() {
	read -p "Continue? (y/n): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
}

read -p "Enter the device name on which the windows installation resides: (e.g. /dev/nvme0n1p3): " device
read -p "Enter your windows username: " winuser
read -s -p "Enter your windows password (WARNING: it will be stored in plaintext): " winpass

windows_grub_entry=$(grep -i "^menuentry 'Windows" /boot/grub/grub.cfg|head -n 1|cut -d"'" -f2)

# escape '$'
#winuser="${winuser//$/\\$}"
#winpass="${winpass//$/\\$}"

if stat run.sh; then
	echo "An run.sh already exists in this folder. It will be overwritten."
	prompt_user
fi

cat > run.sh <<EOF
#!/bin/bash
# don't run sudo if user is root
sudo ()
{
    [[ \$EUID = 0 ]] || set -- command sudo "\$@"
    "\$@"
}


echo "Mounting the windows partition"
sudo umount $device || true
sudo ntfsfix $device || true
sudo mount -t ntfs-3g -o remove_hiberfile $device /mnt/windows

echo "Editing the windows registry and adding auto login credentials"
echo -e 'cd Microsoft\\Windows NT\\CurrentVersion\\Winlogon\nnv 1 AutoAdminLogon\ned AutoAdminLogon\n1\nnv 1 DefaultUserName\ned DefaultUserName\n${winuser}\nnv 1 DefaultPassword\ned DefaultPassword\n${winpass}\nq\ny\n' | chntpw -e /mnt/windows/Windows/System32/config/SOFTWARE

sudo umount /mnt/windows

echo "Rebooting into windows in 5 seconds"
sleep 5
sudo grub-reboot "$windows_grub_entry"
sudo reboot

EOF

chmod +x run.sh

cat > undo.sh <<EOF
#!/bin/bash
# don't run sudo if user is root
sudo ()
{
    [[ \$EUID = 0 ]] || set -- command sudo "\$@"
    "\$@"
}


echo "Mounting the windows partition"
sudo umount $device || true
sudo ntfsfix $device || true
sudo mount -t ntfs-3g -o remove_hiberfile $device /mnt/windows

echo "Editing the windows registry and removing auto login credentials"
echo -e 'cd Microsoft\\Windows NT\\CurrentVersion\\Winlogon\ndv AutoAdminLogon\ndv DefaultUserName\ndv DefaultPassword\nq\ny\n' | chntpw -e /mnt/windows/Windows/System32/config/SOFTWARE

sudo umount /mnt/windows

EOF

chmod +x undo.sh

echo "Done. WARNING - please use the generated init.sh with care. Do not run it unless you understand the risks and implications of doing so"

