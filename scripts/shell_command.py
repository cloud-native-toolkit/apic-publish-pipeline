#!/usr/bin/env python
#import argparse
#import subprocess
from subprocess import Popen, PIPE
import os, requests

FILE_NAME = "shell_command.py"

class cd:
    """Context manager for changing the current working directory"""
    def __init__(self, newPath):
        self.newPath = newPath

    def __enter__(self):
        self.savedPath = os.getcwd()
        os.chdir(self.newPath)

    def __exit__(self, etype, value, traceback):
        os.chdir(self.savedPath)
"""
def shcmd(cmd, ignore_error=False):
    print('Doing:', cmd)
    ret = subprocess.call(cmd, shell=True)
    print('Returned', ret, cmd)
    if ignore_error == False and ret != 0:
        raise RuntimeError("Failed to execute {}. Return code:{}".format(
            cmd, ret))
    return ret
"""

def shcmd(cmd, ignore_error=False):
    # print("INFO " + "in " + FILE_NAME + " : shcmd() : cmd: ",cmd)
    p = Popen(cmd, shell=True, stdout=PIPE, stderr=PIPE)
    stdoutput = p.stdout.read().decode("utf-8")
    p.wait()
    if "404: Not Found" in stdoutput:
        cmd_res = {
            "returncode" : "404",
            "stderr" : stdoutput
        }
    else:
        cmd_res = {
            "returncode" : "200",
            "stdout" : stdoutput
        }
    # print("INFO " + "in " + FILE_NAME + " : shcmd(): ", cmd_res)
    return cmd_res

def execute_request(url, token):
    headers = {"Authorization": "token " + token}
    response = requests.get(url, headers=headers)
    if 200 == response.status_code:
        return response.json()
    else:
        raise Exception("ERROR in shell_command.py in function execute_request: " + response.text)

def execute_request_download(url, token, file_name):
    headers = {"Authorization": "token " + token}
    response = requests.get(url, headers=headers)

    open(file_name, "wb").write(response.content)

    if 200 != response.status_code:
        cmd_res = {"returncode" : "404"}
    else:
        cmd_res = {"returncode" : "200"}
    return cmd_res