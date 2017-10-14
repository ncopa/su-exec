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
	printf("Usage: %s -l\n\tShows license.\n", argv0);
	exit(exitcode);
}

#include "license.inc"
static void print_license()
{
	unsigned int i;
	for (i=0; i<LICENSE_len; i++)
		putchar(LICENSE[i]);
}

int main(int argc, char *argv[])
{
	char *user, *group, **cmdargv;
	char *end;

	uid_t uid = getuid();
	gid_t gid = getgid();

	argv0 = argv[0];
	if (argc == 2 && strcmp(argv[1], "-l") == 0) {
		print_license();
		return EXIT_SUCCESS;
	}
	if (argc < 3)
		usage(EXIT_FAILURE);

	user = argv[1];
	group = strchr(user, ':');
	if (group)
		*group++ = '\0';

	cmdargv = &argv[2];

	struct passwd *pw = NULL;
	if (user[0] != '\0') {
		pw = getpwnam(user);
		uid_t nuid = strtol(user, &end, 10);
		if (*end == '\0')
			uid = nuid;
	}
	if (pw == NULL) {
		pw = getpwuid(uid);
	}
	if (pw != NULL) {
		uid = pw->pw_uid;
		gid = pw->pw_gid;
	}

	setenv("HOME", pw != NULL ? pw->pw_dir : "/", 1);

	if (group && group[0] != '\0') {
		/* group was specified, ignore grouplist for setgroups later */
		pw = NULL;

		struct group *gr = getgrnam(group);
		if (gr == NULL) {
			gid_t ngid = strtol(group, &end, 10);
			if (*end == '\0') {
				gr = getgrgid(ngid);
				if (gr == NULL)
					gid = ngid;
			}
		}
		if (gr != NULL)
			gid = gr->gr_gid;
	}

	if (pw == NULL) {
		if (setgroups(1, &gid) < 0)
			err(EXIT_FAILURE, "setgroups(%i)", gid);
	} else {
		int ngroups = 0;
		gid_t *glist = NULL;

		while (1) {
			int r = getgrouplist(pw->pw_name, gid, glist, &ngroups);

			if (r >= 0) {
				if (setgroups(ngroups, glist) < 0)
					err(EXIT_FAILURE, "setgroups");
				break;
			}

			glist = realloc(glist, ngroups * sizeof(gid_t));
			if (glist == NULL)
				err(EXIT_FAILURE, "malloc");
		}
	}

	if (setgid(gid) < 0)
		err(EXIT_FAILURE, "setgid(%i)", gid);

	if (setuid(uid) < 0)
		err(EXIT_FAILURE, "setuid(%i)", uid);

	execvp(cmdargv[0], cmdargv);
	err(EXIT_FAILURE, "%s", cmdargv[0]);

	return EXIT_FAILURE;
}
