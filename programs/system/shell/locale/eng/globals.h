
const command_t COMMANDS[]=
{
	{"about",   "  Displays information about Shell\n\r", &cmd_about},
	{"alias",   "  Allows the user view the current aliases\n\r", &cmd_alias},
	{"cd",      "  Changes current directory. Usage:\n\r    cd <directory name>\n\r", &cmd_cd},
	{"clear",   "  Clears the screen\n\r", &cmd_clear},
	{"cp",      "  Copies file\n\r", &cmd_cp},
	{"mv",      "  Moves file\n\r", &cmd_mv},
	{"ren",     "  Renames file\n\r", &cmd_ren},
	{"date",    "  Returns the current date and time\n\r", &cmd_date},
	{"echo",    "  Echoes the data to the screen. Usage:\n\r    echo <data>\n\r", &cmd_echo},
	{"exit",    "  Exits from Shell\n\r", &cmd_exit},
	{"free",    "  Displays total, free and used memory\n\r", &cmd_memory},
	{"help",    "  Gives help on commands. Usage:\n\r    help ;it lists all builtins\n\r    help <command> ;help on command\n\r", &cmd_help},
	{"history", "  Lists used commands\n\r", &cmd_history},	
	{"kill",    "  Stops a running process. Usage:\n\r    kill <PID of process>\n\r    kill all\n\r", &cmd_kill},
	{"ls",      "  Lists the files in a directory. Usage:\n\r    ls ;lists the files in current directory\n\r    ls <directory> ;lists the files at specified folder\n\r    ls -1 ;lists the files in a single column\n\r", &cmd_ls},
	{"mkdir",   "  Makes directory. Usage:\n\r    mkdir <folder name> ;creates the folder in working directory\n\r    mkdir <path><folder name> ;create folder by specified path\n\r", &cmd_mkdir},
	{"more",    "  Displays a file data to the screen. Usage:\n\r    more <file name>\n\r", &cmd_more},
	{"ps",      "  Lists the current processes running\n\r  or shows more info on <procname> and save LASTPID\n\r", &cmd_ps},
	{"pwd",     "  Displays the name of the working directory\n\r", &cmd_pwd},
	{"reboot",  "  Reboots the computer or KolibriOS kernel. Usage:\n\r    reboot ;reboot a PC\n\r    reboot kernel ;reboot the KolibriOS kernel\n\r", &cmd_reboot},
	{"rm",      "  Removes a file. Usage:\n\r    rm file name>\n\r", &cmd_rm},
	{"rmdir",   "  Removes a folder. Usage:\n\r    rmdir <directory>\n\r", &cmd_rmdir},
	{"shutdown","  Turns off the computer\n\r", &cmd_shutdown},
	{"sleep",   "  Stops the shell for the desired period. Usage:\n\r    sleep <time in the 1/100 of second>\n\r  Example:\n\r    sleep 500 ;pause for 5sec.\n\r", &cmd_sleep},
	{"touch",   "  Creates an empty file or updates the time/date stamp on a file. Usage:\n\r    touch <file name>\n\r", &cmd_touch},
	{"uptime",  "  Displays the uptime\n\r", &cmd_uptime},
	{"ver",     "  Displays version. Usage:\n\r    ver ;Shell version\n\r    ver kernel ;version of KolibriOS kernel\n\r    ver cpu ;information about CPU\n\r", &cmd_ver},
	{"waitfor", "  Stops console waiting while process finish. Usage:\n\r    waitfor ;waiting previous started executable LASTPID\n\r    waitfor <PID>;awaiting PID finish\n\r", &cmd_waitfor},
};

