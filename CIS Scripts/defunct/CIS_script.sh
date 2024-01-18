username=$(whoami)
function decide 
{
    printf "Select what you would like to do:\n\t[1] Section 1\n\t[2] Section 2\n\t[3] Section 3\n\t[4] Section 4\n\t[5] Section 5\n\t[6] Section 6\n"
    read -p "" -n 1 -r
    echo
    if [[ $REPLY =~ ^[1]$ ]]
    then

        # Filesystem and storage management
        printf "Now disabling unused filesystems and usb storage.\n"
        filesystems=(cramfs freevxfs jffs2 hfs hfsplus squashfs udf vfat usb-storage)
        for fs in ${filesystems[@]}
        do
          printf "Disabling $fs."
          echo -e "install $fs /bin/true" >> /etc/modprobe.d/cisfs.conf # all put into one .conf file, should check if this works
          rmmod $fs
        done
        printf "Done!\n"

        printf "Securing tmp/"
        sudo systemctl unmask tmp.mount
        sudo systemctl enable tmp.mount
        sudo touch /etc/systemd/system/local-fs.target.wants/tmp.mount
        echo -e "[Mount]\nWhat=tmpfs\nWhere=/tmp\nType=tmpfs\nOptions=mode=1777,strictatime,noexec,nodev,nosuid" > /etc/systemd/system/local-fs.target.wants/tmp.mount
        
        # General remounts
        printf "Remounting /tmp\n"
        sudo mount -o remount,nodev,nosuid,noexec /tmp
        printf "Remounting /var/tmp\n"
        sudo mount -o remount,nodev,nosuid,noexec /var/tmp
        printf "Remounting /home\n"
        sudo mount -o remount,nodev /home
        printf "Remounting /dev/shm\n"
        sudo mount -o remount,nodev,nosuid,noexec /dev/shm

        # temporarily ignoring 1.1.18 1.1.19 1.1.20

        # might need to remove --local, idk it said it in the last script
        printf "Making things sticky :woozy:\n"
        sudo df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null | xargs -I '{}' chmod a+t '{}'
        
        printf "Disabling automount\n" # apparently i put redundancy
        sudo systemctl --now disable autofs
        sudo apt purge autofs

        printf "Securing sudo\n"
        sudo apt install sudo sudo-ldap
        echo -e "Defaults use_pty" >> /etc/sudoers
        echo -e "Defaults logfile="/var/log/sudo.log"" >> /etc/sudoers
        
        # 1.4.2 dont want to bother with it rn

        # gonna skip bootloader stuff, i dont think itll be part of CP

        

        decide
    fi
    if [[ $REPLY =~ ^[2]$ ]]
    then
        decide
    fi
    if [[ $REPLY =~ ^[3]$ ]]
    then
        decide
    fi
    if [[ $REPLY =~ ^[4]$ ]]
    then
        decide
    fi
    if [[ $REPLY =~ ^[5]$ ]]
    then
        decide
    fi
    if [[ $REPLY =~ ^[6]$ ]]
    then
        decide
    fi
}

decide