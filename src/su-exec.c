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

int main(int argc, char *argv[])
{
	char *end;

	if (argc < 3) {
		fprintf(stderr, "Usage: su-exec user-spec command [args]\n");
		fprintf(stderr, " e.g.: su-exec tianon bash\n");
		fprintf(stderr, "       su-exec nobody:root bash -c 'whoami && id'\n");
		fprintf(stderr, "       su-exec 1000:1 id\n");
		exit(1);
	}

	/* get user and group part from user-spec */
	char *user = argv[1];
	char *group = strchr(user, ':');
	if (group) {
		*group++ = '\0';
	}

	if (user[0] == '\0') {
		errx(1, "invalid user-spec, user part needed");
	}

	/* get passwd entry */
	struct passwd *pw = NULL;
	if (user[0] != '\0') {
		pw = getpwnam(user);
		uid_t nuid = strtol(user, &end, 10);
		if (*end == '\0') {
			pw = getpwuid(nuid);
		}
	}
	if (pw == NULL) {
		errx(1, "invalid user-spec, user '%s' not found", user);
	}

	uid_t uid = pw->pw_uid;
	gid_t gid = pw->pw_gid;

	/* set variable HOME and USER in the environment */
	setenv("HOME", pw->pw_dir != NULL ? pw->pw_dir : "/", 1);
	setenv("USER", pw->pw_name, 1);

	/* get group entry */
	if (group && group[0] != '\0') {
		/* group was specified, ignore grouplist for setgroups later */
		pw = NULL;

		struct group *gr = getgrnam(group);
		if (gr == NULL) {
			gid_t ngid = strtol(group, &end, 10);
			if (*end == '\0') {
				gr = getgrgid(ngid);
			}
		}
		if (gr != NULL)
			gid = gr->gr_gid;
		else {
			errx(1, "invalid user-spec, group '%s' not found", group);
		}
	}

	/* setgroups */
	if (pw == NULL) {
		/* group was specified */
		if (setgroups(1, &gid) < 0)
			err(1, "setgroups(%i)", gid);
	} else {
		/* group was not specified */
		int ngroups = 0;
		gid_t *glist = NULL;

		while (1) {
			int r = getgrouplist(pw->pw_name, gid, glist, &ngroups);

			if (r >= 0) {
				if (setgroups(ngroups, glist) < 0)
					err(1, "setgroups");
				break;
			}

			glist = realloc(glist, ngroups * sizeof(gid_t));
			if (glist == NULL)
				err(1, "malloc");
		}
		free(glist);
	}

	/* setgid */
	if (setgid(gid) < 0)
		err(1, "setgid(%i)", gid);

	/* setuid */
	if (setuid(uid) < 0)
		err(1, "setuid(%i)", uid);

	/* exec */
	execvp(argv[2], &argv[2]);

	/* error has occurred */
	err(1, "%s", argv[2]);

	return 1;
}
