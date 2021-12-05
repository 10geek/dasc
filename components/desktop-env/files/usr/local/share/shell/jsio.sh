err() {
	if [ $# -gt 1 ]; then
		printf %s\\n "$program_name: $2" >&2
	else
		printf %s\\n "$program_name: $1" >&2
	fi
	[ $# -gt 1 ] && exit "$1"
	return 1
}
checkutil() {
	unset -v checkutil__not_found_utils checkutil__util
	checkutil__silent=0
	checkutil__any=0
	while [ $# -ne 0 ]; do
		checkutil___is_arg_opt=0
		case $1 in --)
			shift; break; esac
		case $1 in -s*|-*s*|-*s)
			checkutil___is_arg_opt=1; checkutil__silent=1; esac
		case $1 in -a*|-*a*|-*a)
			checkutil___is_arg_opt=1; checkutil__any=1; esac
		case $checkutil___is_arg_opt in 0)
			break; esac
		shift
	done
	set -- $*
	while [ $# -ne 0 ]; do
		if ! checkutil__util_path=$(command -v -- "$1") || [ -z "$checkutil__util_path" ]; then
			checkutil__not_found_utils=$checkutil__not_found_utils' '$1
		else case $checkutil__any in 1)
			checkutil__util=$1
			return 0
		esac; fi
		shift
	done
	[ -z "$checkutil__not_found_utils" ] || {
		checkutil__not_found_utils=${checkutil__not_found_utils# }
		[ $checkutil__silent -eq 0 ] &&
			err "\`$(printf %s\\n "$checkutil__not_found_utils" | sed 's/ /'\'', `/g; s/\(.*\), /\1 and /')' is not found in the system; PATH=$PATH"
		return 1
	}
}
waitpid() {
	while :; do
		wait "$1" 2>/dev/null
		waitpid__retval=$?
		sh -c 'trap '\'\'' '"$SIGNALS"'
		ps -Ao ppid,pid | LC_ALL=C awk -- '\''
			BEGIN { ARGC = 1; exit_code = 1 }
			$2 == ARGV[2] { if($1 == ARGV[1]) exit_code = 0; exit }
			END { exit exit_code }
		'\'' "$PPID" "$0"' "$1" || break
	done
	wait "$1" 2>/dev/null
	waitpid__last_retval=$?
	[ $waitpid__last_retval -ne 127 ] && return $waitpid__last_retval
	return $waitpid__retval
}


unset -v \
	jsio__fd_stdin \
	jsio__fd_stdout \
	jsio__pid
jsio__fifo_stdin=$HOME/.jsio/fifo-stdin
jsio__fifo_stdout=$HOME/.jsio/fifo-stdout
jsio__lock_file=$HOME/.jsio/lock
jsio__debug=0
jsio__err_fatal=1
jsio___is_internal_call=0
jsio___lf=$(printf \\n.); jsio___lf=${jsio___lf%.}

jsio___backend_init() {
	case $1 in
	gjs|cjs)
		"$1" /dev/fd/3 3<<- EOF > "$jsio__fifo_stdout" < "$jsio__fifo_stdin" &
		'use strict';

		// Fix for CJS with broken ByteArray.toString()
		if(imports.byteArray.toString(imports.byteArray.fromString('')) !== '') {
			imports.byteArray.toString = function(arr, encoding) {
				return arr.toString(arr, encoding);
			};
		}

		const jsio = {
			Gio: imports.gi.Gio,
			GLib: imports.gi.GLib,
			System: imports.system,
			callbackOverride: {},
			read: function() {
				let result = this.stdin.read_upto('\\0', 1, null);
				result = result[1] == 0 ? '' : result[0];
				if((!result && result !== '') || this.stdin.skip(1, null) < 0)
					throw new this.Error('ReadError', 'jsio.read() failed');
				return result;
			},
			readAsync: function(callback) {
				this.stdin.read_upto_async('\\0', 1, this.GLib.PRIORITY_DEFAULT, null, (srcObj, asyncResult) => {
					let result = this.stdin.read_upto_finish(asyncResult);
					result = result[1] == 0 ? '' : result[0];
					if((!result && result !== '') || this.stdin.skip(1, null) < 0)
						throw new this.Error('ReadError', 'jsio.readAsync() failed');
					if(callback(result)) this.readAsync(callback);
				});
			},
			write: function(str) {
				let lineCount = 0;
				for(let idx = -2; idx != -1; lineCount++)
					idx = str.indexOf('\\n', idx + 1);
				if(
					this.stdout.write(lineCount + '\\n', null) < 0 ||
					this.stdout.write(str, null) < 0 ||
					this.stdout.write('\\n', null) < 0 ||
					!this.stdout.flush(null)
				) throw new this.Error('WriteError', 'jsio.write() failed to write string ' + JSON.stringify(str));
			},
			handler: function(args) {
				let ret = function(value) {
					_waitStmt = false;
					_retval = value;
				};
				let _stmt, _async, _getStmtRetval, _stmtRetval, _waitStmt = true, _retval;
				let local = {};
				while(_waitStmt) {
					_stmt = jsio.read();
					_async = _stmt.charAt(3) == '1';
					_getStmtRetval = _stmt.charAt(4) == '1';
					try {
						_stmtRetval = eval(_stmt);
					} catch(e) {
						e.name = 'failed to execute statement: ' + _stmt + ': ' + e.name;
						throw e;
					}
					if(_getStmtRetval) {
						if(_async) jsio.write('');
						if(typeof _stmtRetval != 'string')
							_stmtRetval = String(_stmtRetval);
						jsio.write(_stmtRetval);
					} else {
						if(!_async) jsio.write('');
					}
					_stmtRetval = null;
				}
				return _retval;
			}.bind(this),
			callback: function(eventName) {
				return function() {
					if(eventName in jsio.callbackOverride) {
						if(typeof jsio.callbackOverride[eventName] == 'function')
							return jsio.callbackOverride[eventName](arguments, eventName);
						return jsio.callbackOverride[eventName];
					}
					if('callbackOverrideAll' in jsio) {
						if(typeof jsio.callbackOverrideAll == 'function')
							return jsio.callbackOverrideAll(arguments, eventName);
						return jsio.callbackOverrideAll;
					}
					jsio.write(eventName);
					return jsio.handler(arguments);
				};
			}
		};
		jsio.Error = function(name, message) {
			this.name = name;
			this.message = message;
		};
		jsio.Error.prototype = Error.prototype;
		jsio.stdin = new jsio.Gio.DataInputStream({
			base_stream: new jsio.Gio.UnixInputStream({ fd: 0 })
		});
		jsio.stdout = new jsio.Gio.DataOutputStream({
			base_stream: new jsio.Gio.UnixOutputStream({ fd: 1 })
		});
		jsio.stdin.set_newline_type(jsio.Gio.DataStreamNewlineType.LF);

		jsio.System.exit(jsio.handler());
		EOF
		jsio__pid=$!
		;;
	*)
		err "jsio__init(): unsupported backend: \`$1'"
		return 1
		;;
	esac
}

# Usage: jsio__init <backend> <fd_stdin> <fd_stdout>
jsio__init() {
	checkutil flock "$1" || return 1
	jsio__fd_stdin=$2
	jsio__fd_stdout=$3
	mkdir -p "$HOME/.jsio" &&
	{
		flock 1 &&
		rm -f "$jsio__fifo_stdin" "$jsio__fifo_stdout" &&
		mkfifo "$jsio__fifo_stdin" "$jsio__fifo_stdout" &&
		jsio___backend_init "$1" &&
		case $jsio__debug in
		0) ;;
		*) err "jsio__init(): [debug] process started with PID $jsio__pid"; true
		esac &&
		eval "exec $jsio__fd_stdout<\"\$jsio__fifo_stdout\" $jsio__fd_stdin>\"\$jsio__fifo_stdin\"" &&
		rm -f "$jsio__fifo_stdin" "$jsio__fifo_stdout"
	} > "$jsio__lock_file" >&2 &&
	return
	set -- 1
	jsio__exit || set -- $?
	[ $jsio__err_fatal -eq 1 ] && exit 1
	return $1
}

# Usage: jsio__exit
jsio__exit() {
	[ -z "$jsio__pid" ] && return
	set -- 0
	kill -TERM "$jsio__pid" 2>/dev/null
	waitpid $jsio__pid || set -- $?
	case $jsio__debug in
	0)
		[ $1 -eq 0 ] || [ $1 -gt 128 ] ||
			err "jsio__exit(): process with PID $jsio__pid exited with code $1"
		;;
	*) err "jsio__exit(): [debug] process with PID $jsio__pid exited with code $1"
	esac
	[ $1 -gt 128 ] && set -- 0
	unset -v jsio__pid
	eval "exec $jsio__fd_stdin>&- $jsio__fd_stdout>&-" || set -- 1
	return $1
}

# Usage: jsio__read [<varname>]
jsio__read() {
	set -- "$1"
	case $1 in
	'') ;;
	*) eval " $1=";;
	esac
	IFS= read -r jsio___buf <&"$jsio__fd_stdout" &&
	set -- "$1" $((jsio___buf + 0)) &&
	while [ $2 -gt 0 ]; do
		IFS= read -r jsio___buf <&"$jsio__fd_stdout" || {
			set --; break
		}
		case $1 in
		'') ;;
		*)
			eval " $1=\$$1\$jsio___buf"
			[ $2 -ne 1 ] && eval " $1=\$$1\$jsio___lf"
			;;
		esac
		set -- "$1" $(($2 - 1))
	done
	unset -v jsio___buf
	case $jsio__debug in
	0) ;;
	*)
		case $1 in
		'') err "jsio__read(): [debug] <null>";;
		*) eval "err \"jsio__read(): [debug] '\$$1'\"";;
		esac
		;;
	esac
	[ $# -eq 2 ] || {
		case $1 in
		'')
			err "jsio__read(): failed to read value";;
		*)
			err "jsio__read(): failed to read value into variable \`$1'";;
		esac
		[ $jsio__err_fatal -eq 1 ] && [ $jsio___is_internal_call -eq 0 ] && exit 1
	}
}

# Usage: jsio__write [<string>]
jsio__write() {
	case $# in
	0)
		case $jsio__debug in
		0) ;;
		*) err "jsio__write(): [debug] <stdin>"
		esac
		{ cat && printf \\0; } >&"$jsio__fd_stdin" ||
			err "jsio__write(): failed to write from stdin"
		;;
	*)
		case $jsio__debug in
		0) ;;
		*) err "jsio__write(): [debug] '$1'"
		esac
		printf %s\\0 "$1" >&"$jsio__fd_stdin" ||
			err "jsio__write(): failed to write value \`$1'"
		;;
	esac || {
		[ $jsio__err_fatal -eq 1 ] && [ $jsio___is_internal_call -eq 0 ] && exit 1
	}
}

# Usage: jsio__write_var <varname>
jsio__write_var() {
	case $jsio__debug in
	0) ;;
	*) eval "err \"jsio__write_var(): [debug] '\$$1'\""
	esac
	eval 'printf %s\\0 "${'"$1"'}"' >&"$jsio__fd_stdin" || {
		err "jsio__write_var(): failed to write value of the variable \`$1'"
		[ $jsio__err_fatal -eq 1 ] && [ $jsio___is_internal_call -eq 0 ] && exit 1
	}
}

# Usage: jsio (: [=] | [<varname>=]) [<eval_str> <pass_str>] ...
#
# Arguments:
#   :           Perform the call asynchronously
#   =           Get the value returned by the asynchronous call after it has
#               been executed. To get the value, it is necessary to wait for the
#               call to complete using the `jsio__read` function.
#   <varname>=  Get the value returned by the synchronous call after it has been
#               executed. The value will be assigned to the variable specified
#               in the <varname> argument.
#   <eval_str>  Part of the statement that will be passed to the eval()
#               function unchanged.
#   <pass_str>  String value that will be passed to the interpreter as a
#               prepared variable. Useful for passing strings with arbitrary
#               values to the interpreter.
jsio() {
	jsio___async=0
	jsio___get_retval=0
	jsio___get_retval_varname=
	jsio___stmt=
	jsio___is_internal_call=1
	case $1 in
	:) jsio___async=1; shift
	esac
	case $jsio___async$1 in
	0*=)
		jsio___get_retval=1
		jsio___get_retval_varname=${1%=}
		shift
		;;
	1=)
		jsio___get_retval=1
		shift
		;;
	esac
	[ $# -eq 0 ] && set -- ''
	jsio___stmt="/* $jsio___async$jsio___get_retval */ 'use strict'; "
	jsio___i=1
	while [ $jsio___i -le $# ]; do
		case $((jsio___i % 2)) in
		0) jsio___stmt=$jsio___stmt'jsio.read()';;
		*) eval "jsio___stmt=\$jsio___stmt\${$jsio___i}";;
		esac
		jsio___i=$((jsio___i + 1))
	done
	jsio__write_var jsio___stmt || set --
	jsio___i=2
	while [ $jsio___i -le $# ]; do
		case $jsio__debug in
		0) ;;
		*)  eval 'err "jsio(): [debug] writing <pass_str> '\''${'"$jsio___i"'}'\''"'
		esac
		eval 'printf %s\\0 "${'"$jsio___i"'}"' >&"$jsio__fd_stdin" || { set --; break; }
		jsio___i=$((jsio___i + 2))
	done
	[ $# -ne 0 ] &&
	case $jsio___async in
	0)
		case $jsio___get_retval in
		0) jsio__read;;
		1) jsio__read "$jsio___get_retval_varname";;
		esac || set --
	esac
	jsio___is_internal_call=0
	[ $# -ne 0 ] || {
		err "jsio(): failed to execute statement: ${jsio___stmt#*; } [async=$jsio___async, get_retval=$jsio___get_retval${jsio___get_retval_varname:+, get_retval_varname=}$jsio___get_retval_varname]"
		[ $jsio__err_fatal -eq 1 ] && exit 1
		return 1
	}
}

SIGNALS='HUP INT QUIT ILL ABRT FPE SEGV PIPE ALRM TERM USR1 USR2'
signal_handler___ifs=$IFS
eval "signal_handler__register() { trap 'EXIT_CODE=\$?; trap '\\'\\'' $SIGNALS; IFS=\$signal_handler___ifs; signal_handler EXIT' EXIT;$(
	LC_ALL=C awk -- 'BEGIN { for(i = 2; i < ARGC; i++) print "trap \47trap \47\134\47\134\47\47 " ARGV[1] "; IFS=$signal_handler___ifs; signal_handler " ARGV[i] "; signal_handler__register\47 " ARGV[i] }' "$SIGNALS" $SIGNALS
);}"
