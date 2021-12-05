- Change the value of the `osrelease` directive in the `common/control` file according to the values from the `/etc/os-release` file;
- Add `contrib` and `non-free` repositories to the `/etc/apt/sources.list` file (if the distribution provides them);
- Run the command `./debcomp verify-pkglists -f` and, if necessary, edit the package lists and repeat this step;
- Check which packages debcomp proposes to install or remove using the `./debcomp install -ys` command and, if necessary, make changes to the package lists and repeat the previous step;
- Generate a default configuration and presets;
- Perform a test installation of the configuration;
- Find the difference between the current backup of the configuration files (in directories named `backup`) with which the configuration was created and the current replaced distribution configuration files in the `/var/local/lib/debcomp/rollback` directory, make changes in the configuration if necessary, and create backup of the current distribution configuration files. Helper command:
```sh
while IFS= read -erp 'component: ' -i "$component" component && IFS= read -erp 'file: ' file; do backup_file=dasc/$component/backup/$file; cat "rollback/$component/backup/$file" > "$backup_file" || continue; component_file=dasc/$component/files/$file; for component_file in "$component_file" "$component_file.awm"; do [ -e "$component_file" ] || continue; atom "$component_file"; meld "$backup_file" "$component_file"; done; done
```
- Perform a test reinstallation of the configuration;
- Find the FIXME comments with the command `grep -rF FIXME:` and check their actuality;
- Test the entire configuration and troubleshoot, if any.
