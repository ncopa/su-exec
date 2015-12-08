/* set user and group id and exec */

#include <sys/types.h>

#include <err.h>
#include <errno.h>
#include <grp.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static char *argv0;

static void usage(int exitcode)
{
	printf("Usage: %s user-spec command [args]\n", argv0);
	exit(exitcode);
}

int main(int argc, char *argv[])
{
	char *user, *group, **cmdargv;
	struct passwd *pw = NULL;
	char *end;

	argv0 = argv[0];
	if (argc < 3)
		usage(0);

	user = argv[1];
	group = strchr(user, ':');
	if (group)
		*group++ = '\0';

	cmdargv = &argv[2];

	if (group && group[0] != '\0') {
		struct group *gr = NULL;
		gid_t gid = strtol(group, &end, 10);
		if (*end != '\0') {
			gr = getgrnam(group);
			if (gr == NULL)
				err(1, "%s", group);
			gid = gr->gr_gid;
		}

		if (setgid(gid) < 0)
			err(1, "setgid(%i)", gid);
	}

	if (user[0] != '\0') {
		uid_t uid = strtol(user, &end, 10);
		if (*end == '\0') {
			pw = getpwuid(uid);
		} else {
			pw = getpwnam(user);
			if (pw == NULL)
				err(1, "%s", user);
			uid = pw->pw_uid;
		}

		setenv("HOME", pw != NULL ? pw->pw_dir : "/", 1);

		if (setuid(uid) < 0)
			err(1, "setuid(%i)", uid);

	}

	execvp(cmdargv[0], cmdargv);
	err(1, "%s", cmdargv[0]);

	return 1;
}
