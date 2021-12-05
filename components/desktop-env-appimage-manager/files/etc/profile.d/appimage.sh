case ":$PATH:" in
	*:/var/local/lib/appimage/bin:*) ;;
	*) [ -d /var/local/lib/appimage/bin ] && PATH=$PATH:/var/local/lib/appimage/bin
esac

[ -z "$XDG_DATA_DIRS" ] &&
	export XDG_DATA_DIRS="/usr/local/share/:/usr/share/"
case ":$XDG_DATA_DIRS:" in
	*:/var/local/lib/appimage/desktop:*) ;;
	*) [ -d /var/local/lib/appimage/desktop ] && XDG_DATA_DIRS=$XDG_DATA_DIRS:/var/local/lib/appimage/desktop/
esac
