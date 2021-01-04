#!/usr/bin/python3
import sys
import time
import datetime
import os
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from subprocess import Popen

MAX_WAIT_TIME = 60
RUN_SCRIPT_TRIGGER = True
LAST_TRIGGER_TIME = 0
LAST_EVENT_TIME = 0
STORED_EVENT_TIME = 0
WATCH_PATH = "./input"
OUTPUT_PATH = "./output"
SCRIPT_PATH = "/config/filebot.sh"
CONFIG_PATH = "/config/FileBot.conf"
watcher = Observer()


def log_console(string):
    d = datetime.datetime.now()
    print(d.strftime("%m-%d-%Y %H:%M:%S") + " -> " + string, flush=True)


def get_wdir_size():
    dsize = 0
    for dirpath, dirnames, files in os.walk(WATCH_PATH):
        for i in files:
            filename = os.path.join(dirpath, i)
            dsize += os.stat(filename).st_size
    log_console(str(dsize))
    return dsize


def WAIT_FOR_STABILIZE():
    global STORED_EVENT_TIME, LAST_EVENT_TIME
    log_console("Waiting for directory to stabilize...")
    STORED_EVENT_TIME = LAST_EVENT_TIME
    time.sleep(10)
    while STORED_EVENT_TIME < LAST_EVENT_TIME:
        STORED_EVENT_TIME = LAST_EVENT_TIME
        time.sleep(10)


class Handler(FileSystemEventHandler):
    def on_any_event(self, event):
        global RUN_SCRIPT_TRIGGER, LAST_EVENT_TIME
        if event.is_directory:
            return None

        elif event.event_type == 'created':
            RUN_SCRIPT_TRIGGER = True
            LAST_EVENT_TIME = time.time()
        elif event.event_type == 'modified':
            RUN_SCRIPT_TRIGGER = True
            LAST_EVENT_TIME = time.time()
        elif event.event_type == 'moved':
            RUN_SCRIPT_TRIGGER = True
            LAST_EVENT_TIME = time.time()


def configure():
    global MAX_WAIT_TIME, WATCH_PATH, OUTPUT_PATH

    if len(sys.argv) == 2:
        WATCH_PATH = sys.argv[1]
    if len(sys.argv) == 3:
        MAX_WAIT_TIME = int(sys.argv[2])
        WATCH_PATH = sys.argv[1]
    if len(sys.argv) == 4:
        OUTPUT_PATH = sys.argv[3]
        MAX_WAIT_TIME = int(sys.argv[2])
        WATCH_PATH = sys.argv[1]

    try:
        f = open(CONFIG_PATH, "r")
        for x in f.readlines():
            if "MAX_WAIT_TIME" in x:
                MAX_WAIT_TIME = int(x.split("=")[1].replace('\n', ''))
            if "WATCH_PATH" in x:
                WATCH_PATH = x.split("=")[1].replace('\n', '')
            if "OUTPUT_PATH" in x:
                OUTPUT_PATH = x.split("=")[1].replace('\n', '')
        f.close()
    except IOError:
        log_console("Config File does not exist")

    if not os.path.exists(WATCH_PATH):
        log_console("WATCH PATH NOT VALID")
        return
    if not os.path.exists(OUTPUT_PATH):
        log_console("OUTPUT PATH NOT VALID")
        return
    log_console("**********CONFIGURATION**********")
    log_console("MAX_WAIT_TIME = " + str(MAX_WAIT_TIME) + " seconds")
    log_console("WATCH_PATH = " + str(WATCH_PATH))
    log_console("OUTPUT_PATH = " + str(OUTPUT_PATH))
    log_console("*********************************")


def DirChanged():
    global RUN_SCRIPT_TRIGGER, LAST_TRIGGER_TIME
    Wait()
    WAIT_FOR_STABILIZE()
    RunScript()
    log_console("Waiting for new change...")


def Wait():
    global LAST_TRIGGER_TIME
    if time.time() - LAST_TRIGGER_TIME >= MAX_WAIT_TIME:
        LAST_TRIGGER_TIME = time.time()
    else:
        log_console("Too early to trigger command waiting " + str(MAX_WAIT_TIME) + " seconds")
        while time.time() - LAST_TRIGGER_TIME < MAX_WAIT_TIME:
            time.sleep(1)
        LAST_TRIGGER_TIME = time.time()


def RunScript():
    global RUN_SCRIPT_TRIGGER, watcher
    #watcher.event_queue.empty()
    log_console("Starting script...")
    p = Popen([SCRIPT_PATH, WATCH_PATH, OUTPUT_PATH])
    p.wait()
    p.kill()
    RUN_SCRIPT_TRIGGER = False


def do_task():
    if RUN_SCRIPT_TRIGGER == False:
        return
    DirChanged()


if __name__ == '__main__':
    observer = Observer()
    configure()
    event_handler = Handler()
    observer.event_queue.maxsize = 1

    observer.schedule(event_handler, WATCH_PATH, recursive=True)
    observer.start()
    watcher = observer
    try:
        while observer.is_alive():
            observer.join(1)
            do_task()
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
    
    
