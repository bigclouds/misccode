#define _GNU_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <limits.h>
#include <fcntl.h>
#include <errno.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/statfs.h>
#include <sys/vfs.h>
#include <sys/mman.h>
#include <sys/mount.h>
#include <sys/sendfile.h>
#include <sys/syscall.h>


int try_bindfd(void)
{
        int fd, ret = -1;
        char template[PATH_MAX] = { 0 };
        char *prefix = NULL;

        if (!prefix || *prefix != '/')
                prefix = "/tmp/rcu";
        if (snprintf(template, sizeof(template), "%s/runc.XXXXXX", prefix) < 0)
                return ret;

        /*
         * We need somewhere to mount it, mounting anything over /proc/self is a
         * BAD idea on the host -- even if we do it temporarily.
         */
        fd = mkstemp(template);
        if (fd < 0)
                return ret;
        close(fd);

        /*
         * For obvious reasons this won't work in rootless mode because we haven't
         * created a userns+mntns -- but getting that to work will be a bit
         * complicated and it's only worth doing if someone actually needs it.
         */
        ret = -EPERM;
        if (mount("/proc/self/exe", template, "", MS_BIND, "") < 0)
                goto out;
        if (mount("", template, "", MS_REMOUNT | MS_BIND | MS_RDONLY, "") < 0)
                goto out_umount;

        /* Get read-only handle that we're sure can't be made read-write. */
        ret = open(template, O_PATH | O_CLOEXEC);

out_umount:
	/*
         * Make sure the MNT_DETACH works, otherwise we could get remounted
         * read-write and that would be quite bad (the fd would be made read-write
         * too, invalidating the protection).
         */
        if (umount2(template, MNT_DETACH) < 0) {
                if (ret >= 0)
                       close(ret);
                ret = -ENOTRECOVERABLE;
        }
	// my
        //if (ret >= 0)
        //       close(ret);

out:
        /*
         * We don't care about unlink errors, the worst that happens is that
         * there's an empty file left around in STATEDIR.
         */
        unlink(template);
        return ret;
}


int main() {
	int binfd, execfd;
	execfd = try_bindfd();
	printf("execfd = %d", execfd);
	sleep(100);
}
