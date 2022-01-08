7z a
	-mx9 out.7z file  # create add files 7z archive
	-mx9 -v"$(LC_ALL=C gawk -M 'BEGIN { OFMT = "%d"; print 1024 ^ 3 * 4 - 1 }')b" out.7z file  # create add files 7z archive split big file fat32
7z x -oiso-unpacked *.iso  # unpack extract files from iso image
addgroup --system --gid 800 groupname  # create system group
adduser --system --uid 800 --disabled-login --ingroup groupname --home /nonexistent --no-create-home --gecos '' --shell /usr/sbin/nologin username  # create system user
apt-config dump
apt-file
	--substring-match search  # find search package by file provides
	-x search  # regexp find search package by file provides
aptitude --schedule-only install  # set mark schedule packages to install
aptitude search '?tag()'  # search package by debtags
awktest() { local command; for command in gawk 'gawk --posix --lint' mawk 'busybox awk'; do printf %s\\n "$command:"; eval " $command \"\$@\""; printf 'Exit code: %s\n\n' $?; done; }
chmod +x  # set execution permission
cp -af  # merge copy a file or directory exactly
df -hT  # file system disk space usage
dpkg
	-S  # find search package by file path
	--listfiles  # list package files
	--get-selections |
		awk '$2 == "install" { sub(/:[^\t\v\f\r ]*[\t\v\f\r ]*$/, "", $1); if($1 in dup) next; dup[$1] = ""; print $1 }'  # list all installed packages
		awk 'BEGIN { ORS = ""; ARGC = 1; has_pkgs = 0; sortcmd = "LC_ALL=C sort | tr \\\\n \47 \47 | sed \47s/ *$//\47"; while((getline < ARGV[1]) > 0) target[$1] = "" } $2 == "install" { sub(/:[^\t\v\f\r ]*[\t\v\f\r ]*$/, "", $1); if($1 in dup) next; dup[$1] = ""; if($1 in target) { delete target[$1] } else { if(!has_pkgs) { has_pkgs = 1; print "aptitude --schedule-only purge " } print $1 "\n" | sortcmd } } END { if(has_pkgs) { close(sortcmd); print "\n" } has_pkgs = 0; for(pkg in target) { if(!has_pkgs) { has_pkgs = 1; print "aptitude --schedule-only --without-recommends install " } print pkg "\n" | sortcmd } if(has_pkgs) { close(sortcmd); print "\n" } }' packages-list  # rollback packages state
dpkg-divert --add --rename --divert /path/to/file.original /path/to/file
dpkg-query -Wf '${Installed-Size}\t${Package}\n' | LC_ALL=C sort -n  # sort packages by disk space usage
find . -path './DEBIAN/*' -prune -o -type f -exec md5sum {} \; | awk '{ sum = $1; if(!sub(/^[ \t]*[^ \t]+[ \t]+\.\//, "")) next; print sum "  " $0 }' | LC_ALL=C sort > DEBIAN/md5sums && pkginfo=$(cat DEBIAN/control) && { du -sx --exclude DEBIAN . && printf %s\\n "$pkginfo"; } | awk 'BEGIN { is_found = 0 } { if(NR == 1) size = $1; else if($0 ~ /^Installed-Size: /) { is_found = 1; print "Installed-Size: " size } else print $0 } END { if(!is_found) print "Installed-Size: " size }' > DEBIAN/control && fakeroot dpkg-deb -b . ../package.deb  # build deb package
"$(command -v avconv || command -v ffmpeg)" -y
	-f x11grab -framerate 30 -video_size $(xwininfo | awk 'BEGIN { x = y = w = h = 0 } { sub("^[ \t]+", ""); $0 = tolower($0); if(sub("^absolute upper-left x:", "")) x = $1; else if(sub("^absolute upper-left y:", "")) y = $1; else if(sub("^width:", "")) w = $1; else if(sub("^height:", "")) h = $1 } END { w += w % 2; h += h % 2; print w "x" h " -i :0.0+" x "," y }') -f alsa -ac 2 -i default -acodec libmp3lame -ab 320k -c:v libx264 "capture-$(date +%F_%T).mp4"  # capture record video from desktop x11 xorg
	-f alsa -ac 1 -i default -acodec libmp3lame -ab 320k -ar 44100 "record-$(date +%F_%T).mp3"  # sound recording
du -sh  # file directory disk space usage
find
	. -type d -exec chmod a-st,u=rwx,go=rx {} \; && find . -type f -exec chmod a-st,u=rw,go=r {} \;  # set directories permissions
	. -type f -exec wc -l {} \; | awk '{ sum += $1 } END { print sum }'  # count total number of lines in files in directory
	. -printf %h\\n | LC_ALL=C awk '{ c[$0]++ } END { for(d in c) print c[d], d }' | LC_ALL=C sort -n  # count total number of files and directories in directory and subdirectories
	. -printf %h\\n | LC_ALL=C awk 'BEGIN { FS = OFS = "/" } { do { c[$0]++; $NF = "" } while(--NF) } END { OFS = " "; for(d in c) print c[d], d }' | LC_ALL=C sort -n  # recursive count total number of files and directories in directory and subdirectories
	. -type f -printf \\n | awk 'BEGIN { count = 0 } { if(!(++count % 1000)) printf("%s\r", count) } END { print count }'  # count large number of files in directory
	. -type f -name '*.gz' -exec zgrep -HFi pattern {} \;  # recursive search on gzipped files
	/ \( -path /dev -o -path /proc -o -path /sys \) -prune -o -type f -perm /u=s,g=s -ls  # find files with SUID/SGID in the system
	/tmp /var/tmp ! -type d -atime +7 ! -exec fuser -s {} \; -exec rm -f -- {} \;  # remove old files from temp directories
	. -depth -type d \! -path . -exec rmdir -- {} \; 2>/dev/null  # remove empty directories
	/sys/kernel/iommu_groups -type l -exec sh -c 'IFS=/; set -- $0; printf '\''IOMMU Group %-4s '\'' "$5"; lspci -nns "$7"' {} \; | sort -n -k3  # pci devices IOMMU groups
findimagedupes -R -t 99.22% -f findimagedupes.db -i 'VIEW() { for file in "$@"; do printf %s\\n "$file"; done; printf \\n; }' -- .  # find images duplicates
{ if command -v getent > /dev/null; then getent passwd; else cat /etc/passwd; fi; } | awk -F: "$(awk 'BEGIN { ORS = ""; pre = "" } { if(NF != 2) next; if($1 == "UID_MIN") { print "$3 >= " int($2); pre = " && " } else if($1 == "UID_MAX") { print pre "$3 < " int($2) } }' /etc/login.defs 2>/dev/null || printf %s '$3 >= 1000 && $3 < 60000')"' && $1 != "nobody" { print $1 }'  # get all non-system users
git
	add -A && git commit -S && git push
	clone
	reset --hard
		HEAD~1 && git push origin HEAD --force  # delete last commit
		tagName && git push origin HEAD --force  # delete commit
	tag -d tagName && git push origin :refs/tags/tagName  # delete tag or release
rm -rf .git && git init && git add . && git commit -S -m 'Initial commit' && git remote add origin https://github.com/user/project.git && git push -u --force origin master  # reset recreate git repository
gpg
	--gen-key
	--fingerprint
	--delete-secret-key user@example.com
	--delete-key user@example.com
	--export --armor user@example.com > gpg-key.asc
grep
	-Fi
	-vFi
	-rFi
history -d  # delete history item
htop -u "$USER"
iat in.mdf out.iso  # convert mdf iso
inotifywait -mqe modify path-to-file | while head -n1 > /dev/null; do on-update-command; done  # monitor changes do action on file update
journalctl -p3 -b  # system startup errors log
LC_ALL=C
	#
	sort -u
	awk --
		'{  }'
		'!($0 in dup) { print $0; dup[$0] = "" }'  # deleting duplicate lines
		'{ print length, $0 }' | LC_ALL=C sort -n | LC_ALL=C awk '{ $1 = ""; print substr($0, 2) }'  # sort lines strings by length
ls -lhA
lsof -Pni  # network connections processes ports
lspci -nnk  # pci devices kernel modules
machinectl -q shell username@
	# systemd user shell
	"$(command -v sh)" -c 'command'  # systemd user command
mksquashfs input output.sqfs -comp xz -b 1024k -Xdict-size 100%
mount -o loop image.img /mnt/  # mount partition image
mplayer tv:// -tv device=/dev/video0  # play video from device
MYSQL_PWD=dbpassword mysql --no-defaults --sigint-ignore --skip-reconnect -h dbhost -u dbuser -- dbname  # mysql database dump import
MYSQL_PWD=dbpassword mysqldump --no-defaults --single-transaction --routines -h dbhost -u dbuser -r dump.sql -- dbname  # mysql database dump export
mysqlcheck -rAp 2>&1 | less  # mysql tables recovery
od -vAn
	-tu1 # decimal
	-to1 # octal
	-tx1 # hexademical
printf %s\\n
	#
	"${string#*.}"     # 1.2.3.4 --> 2.3.4  remove string part
	"${string##*.}"    # 1.2.3.4 --> 4      remove string part
	"${string%.*}"     # 1.2.3.4 --> 1.2.3  remove string part
	"${string%%.*}"    # 1.2.3.4 --> 1      remove string part
	"${string##*( )}"  # "  string  " --> "string  "  left trim string (bash only)
	"${string%%*( )}"  # "  string  " --> "  string"  right trim string (bash only)
ps -Ao pid,user,group,stat,args  # process list
qemu-img
	create
		-f qcow2 image.img 64G  # create virtual disk image
		-f qcow2 -b parent-image.img child-image.img  # create child virtual disk image
	commit child-image.img  # commit merge changes from child to backing parent image
	convert -O qcow2 image-from.img image-to.img  # convert virtual disk image
	rebase -ub parent-image.img child-image.img  # change backing parent virtual disk image
LC_ALL=C awk -- 'function esc(string) { gsub(/\47/, "\47\134\47\47", string); return "\47" string "\47" } function add_image(image,    cmd, bimage, size) { if(image in added_images) return; added_images[image] = ""; cmd = "qemu-img info " esc(image); while((cmd | getline) > 0) { if(sub(/^backing file: */, "")) { bimage = $0; if(sub(/.* \(actual path: /, "") && sub(/\)$/, "")) bimage = $0 } else if(sub(/^disk size: /, "")) size = $0 } close(cmd); if(length(bimage) >= length(pwd) && substr(bimage, 1, length(pwd)) == pwd) bimage = substr(bimage, length(pwd) + 1); childs[bimage, ++childs[bimage, 0]] = image; images_sizes[image] = size; if(bimage != "") add_image(bimage) } function print_childs(image, pre_str,    i, is_hive_end) { for(i = 1; i <= childs[image, 0]; i++) { is_hive_end = i == childs[image, 0]; print pre_str "\342\224" (is_hive_end ? "\224" : "\234") "\342\224\200 " childs[image, i] (images_sizes[childs[image, i]] == "" ? "" : " [" images_sizes[childs[image, i]] "]"); print_childs(childs[image, i], pre_str (is_hive_end ? "   " : "\342\224\202  ")) } } BEGIN { pwd = ENVIRON["PWD"] "/"; for(i = 1; i < ARGC; i++) add_image(ARGV[i]); print_childs("") }' *  # qcow2 parent child images tree
sh -c
	'modprobe nbd max_part=128; qemu-nbd -c "$1" -- "$0" && partprobe -- "$1"' image.img /dev/nbd0  # connect virtual disk image to the system
	'qemu-nbd -d "$1" && rmmod nbd' test.img /dev/nbd0  # disconnect virtual disk image from system
rm -rf
servefile -p 8800
	#
	-l .
	-u uploads
	-t .
smartctl
	-i /dev/sda
	-A /dev/sda
split -db "$(LC_ALL=C gawk -M 'BEGIN { OFMT = "%d"; print 1024 ^ 3 * 4 - 1 }')" image.img out/image.img.  # split big file fat32
sed '/[А-Яа-яЁё]/bc; y/qwertyuiop[]asdfghjkl;'\''zxcvbnm,.\/QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?`~@#$^&|/йцукенгшщзхъфывапролджэячсмитьбю.ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,ёЁ"№;:?\//; b; :c y/йцукенгшщзхъфывапролджэячсмитьбю.ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,ёЁ"№;:?\//qwertyuiop[]asdfghjkl;'\''zxcvbnm,.\/QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?`~@#$^&|/'  # fix translate incorrect keyboard layout language
swapoff -a && swapon -a  # empty swap
smbpasswd
	-a username  # add samba user
	-x username  # delete samba user
systemctl
	restart
	start
	stop
	status
pdbedit -L  # list samba users
net usershare
	add resource-name /directory '' username:f  # add samba resource
	delete resource-name  # delete samba resource
scp -BCP 22 ./file user@host:~/  # copy file to remote host over ssh
strace -f
	-e open -p PID  # files opened by process
	command 2>&1 | grep "mkdir\|O_CREAT"  # which files and directories are created or modified
	-fe trace=file command 2>&1 > /dev/null | grep '^[^"]*"[^"]*"[^)]*)[ \t]*=[ \t]*-1'  # system calls errors
	-c  # system calls CPU time
su -l
systemctl
	daemon-reload  # reload systemd configuration
	list-dependencies  # units dependencies tree
	show -p After,Before,Requires,Wants,WantedBy,RequiredBy unit-name  # unit ordering and dependencies
systemd-run -qGP -pUser=username --slice="user-$(id -u -- username)" -- command
unar -e cp866 archive.zip  # unpack zip archive with non-standard encoding
virsh
	list --all  # list of virtual machines
	shutdown  # stop shutdown virtual machine
	start  # start virtual machine
	console
	snapshot-create-as '' --name ''  # create virtual machine snapshot
	snapshot-revert '' --snapshotname ''  # revert virtual machine snapshot
	snapshot-delete '' --snapshotname ''  # delete virtual machine snapshot
	undefine '' --snapshots-metadata  # delete virtual machine
xmacrorec2 > macro  # keyboard mouse emulation recording
xmacroplay -d 10ms :0 < macro  # keyboard mouse emulation recording
xrandr
	--prop  # list of supported options configurable via --set
	--output HDMI1
		--brightness 1  # brightness correction
		--gamma 1:1:1  # gamma correction
		--mode 1024x768 --rate 60  # change display resolution and frame rate
shutdown
	-P now  # shutdown system
	-r now  # reboot system
sleep 1 && xset dpms force off  # turn off display
zpaq
	a archive.zpaq files -m4  # create add files to archive
	x *.zpaq -t1 -to zpaq-unpacked  # unpack extract files from archive
	l *.zpaq  # list files in archive

for value in *; do ; done
xargs -rl -d$'\n' -P5 sh -c ' "$0"'
while IFS= read -r value; do ; done
