##11/04/2018
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

import subprocess, select
import os
class CMD_RUNNER():
    ####This is assume the output is small amount of data
    ####Note: one issue for Popen.communicate() is: when output file is large, the process will be hanged, which will
    ####cause deadlock
    def run_cmd_small_output(self, cmd):
        print("Running command: {0}\n".format(cmd))
        subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE).communicate()

    ####This is try to solve the issue mentioned previously with assumption that stderr is small
    def run_cmd_to_file(self, cmd, sf_out):
        print("Running command with output: {0}\n".format(cmd))
        sf_err=sf_out+".err"
        errcode=None
        with open(sf_out, "w") as f:
            p = subprocess.Popen(cmd, shell=True, stdout=f, stderr=None)
            #errcode = p.wait()
            p.communicate()

        # if errcode:
        #     errmess = p.stderr.read()
        #     log.error('cmd failed <%s>: %s' % (errcode, errmess))
        if os.path.isfile(sf_err):
            os.remove(sf_err)
        return errcode

####