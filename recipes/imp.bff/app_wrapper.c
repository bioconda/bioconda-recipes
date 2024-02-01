#include <stdio.h>
#include <windows.h>
#include <string.h>
#include <stdlib.h>

/*
   IMP Python command line tools on Unix/Linux/Mac are typically named
   without a .py extension (e.g. 'myapp' not 'myapp.py') and rely on a
   #!/usr/bin/python line at the start of the file to tell the OS that
   they are Python files. This doesn't work on Windows though, since
   Windows relies on the file extension.

   To remedy this problem, we provide this wrapper. Compile with
      cl app_wrapper.c shell32.lib
   then copy the resulting app_wrapper.exe to myapp.exe and install in
   the top-level Anaconda directory. Then a user should be able to simply
   type 'myapp', and the right Python tool will be run.
*/

/* Get full path to fname in topdir */
static char *get_new_full_path(const char *topdir, const char *fname)
{
    char *newpath = malloc(strlen(topdir) + strlen(fname) + 2);
    strcpy(newpath, topdir);
    strcat(newpath, "\\");
    strcat(newpath, fname);
    return newpath;
}

/* Get full path to this binary */
static void get_full_path(char **dir, char **fname)
{
    char path[MAX_PATH * 2];
    size_t l;
    char *ch;
    DWORD ret = GetModuleFileName(NULL, path, MAX_PATH * 2);
    if (ret == 0) {
        fprintf(stderr, "Failed to get executable name, code %d\n", GetLastError());
        exit(1);
    }
    l = strlen(path);
    if (l > 4 && path[l - 4] == '.') {
        /* Remove extension */
        path[l-4] = '\0';
    }
    ch = strrchr(path, '\\');
    if (ch) {
        *ch = '\0';
        *fname = strdup(ch + 1);
    } else {
        *fname = strdup("");
    }
    *dir = strdup(path);
}

/* Find where the parameters start in the command line (skip past the
   executable name) */
static char *find_param_start(char *cmdline)
{
    BOOL in_quote = FALSE, in_space = FALSE;
    for (; *cmdline; cmdline++) {
        /* Ignore spaces that are quoted */
        if (*cmdline == ' ' && !in_quote) {
            in_space = TRUE;
        } else if (*cmdline == '"') {
            in_quote = !in_quote;
        }
        /* Return the first nonspace that follows a space */
        if (in_space && *cmdline != ' ') {
            break;
        }
    }
    return cmdline;
}

/* Convert original parameters into those that python.exe wants (i.e. prepend
   the name of the Python script) */
static char *make_python_parameters(const char *orig_param, const char *binary)
{
    char *param = malloc(strlen(orig_param) + strlen(binary) + 4);
    strcpy(param, "\"");
    strcat(param, binary);
    strcat(param, "\" ");
    strcat(param, orig_param);
    /*printf("python param %s\n", param);*/
    return param;
}

/* Remove the last component of the path in place */
static void remove_last_component(char *dir)
{
    char *pt;
    if (!dir || !*dir) return;
    /* Remove trailing slash if present */
    if (dir[strlen(dir)-1] == '\\') {
        dir[strlen(dir)-1] = '\0';
    }
    /* Remove everything after the last slash */
    pt = strrchr(dir, '\\');
    if (pt) {
        *pt = '\0';
    }
}

/* Get the full path to the Anaconda Python. */
static char* get_python_binary(const char *topdir)
{
    char *python = malloc(strlen(topdir) + 12);
    strcpy(python, topdir);
    /* Remove last two components of the path (we are in Library/bin; python
       is in the top-level directory) */
    remove_last_component(python);
    remove_last_component(python);
    strcat(python, "\\python.exe");
    return python;
}

/* Run the given Python script, passing it the parameters we ourselves
   were given. */
static DWORD run_binary(const char *binary, const char *topdir)
{
    SHELLEXECUTEINFO si;
    BOOL bResult;
    char *param, *python = NULL;
    param = strdup(GetCommandLine());

    ZeroMemory(&si, sizeof(SHELLEXECUTEINFO));
    si.cbSize = sizeof(SHELLEXECUTEINFO);
    /* Wait for the spawned process to finish, so that any output goes to the
       console *before* the next command prompt */
    si.fMask = SEE_MASK_NO_CONSOLE | SEE_MASK_NOASYNC | SEE_MASK_NOCLOSEPROCESS;
    {
        char *orig_param = param;
        python = get_python_binary(topdir);
        si.lpFile = python;
        param = make_python_parameters(find_param_start(param), binary);
        free(orig_param);
        si.lpParameters = param;
    }
    si.nShow = SW_SHOWNA;
    bResult = ShellExecuteEx(&si);
    free(param);
    free(python);

    if (bResult) {
        if (si.hProcess) {
            DWORD exit_code;
            WaitForSingleObject(si.hProcess, INFINITE);
            GetExitCodeProcess(si.hProcess, &exit_code);
            CloseHandle(si.hProcess);
            return exit_code;
        }
    } else {
        fprintf(stderr, "Failed to start process, code %d\n", GetLastError());
        exit(1);
    }
    return 0;
}

int main(int argc, char *argv[]) {
    int is_python;
    char *dir, *fname, *new_full_path;
    DWORD return_code;

    get_full_path(&dir, &fname);
    /*printf("%s, %s\n", dir, fname);*/
    new_full_path = get_new_full_path(dir, fname);
    /*printf("new full path %s, %d\n", new_full_path, is_python);*/
    return_code = run_binary(new_full_path, dir);
    free(dir);
    free(fname);
    free(new_full_path);
    return return_code;
}