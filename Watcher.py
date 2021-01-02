import sys
import time
import datetime
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from subprocess import Popen

MAX_WAIT_TIME = 10
RUN_SCRIPT_TRIGGER = True
LAST_TRIGGER_TIME = 0
WATCH_PATH = "./input"
OUTPUT_PATH = "./output"
watcher = Observer()


def log_console(string):
    d = datetime.datetime.now()
    print(d.strftime("%m-%d-%Y %H:%M:%S") + " -> " + string)


class Handler(FileSystemEventHandler):
    def on_any_event(self, event):
        global RUN_SCRIPT_TRIGGER
        if event.is_directory:
            return None

        elif event.event_type == 'created':
            RUN_SCRIPT_TRIGGER = True
        elif event.event_type == 'modified':
            RUN_SCRIPT_TRIGGER = True
        elif event.event_type == 'moved':
            RUN_SCRIPT_TRIGGER = True


def configure():
    global MAX_WAIT_TIME, WATCH_PATH, OUTPUT_PATH

    if len(sys.argv) == 1:
        WATCH_PATH = sys.argv[0]
    if len(sys.argv) == 2:
        MAX_WAIT_TIME = int(sys.argv[1])
        WATCH_PATH = sys.argv[0]
    if len(sys.argv) == 3:
        OUTPUT_PATH = sys.argv[2]
        MAX_WAIT_TIME = int(sys.argv[1])
        WATCH_PATH = sys.argv[0]

    try:
        f = open("FileBot.conf", "r")
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
    log_console("**********CONFIGURATION**********")
    log_console("MAX_WAIT_TIME = " + str(MAX_WAIT_TIME) + " seconds")
    log_console("WATCH_PATH = " + str(WATCH_PATH))
    log_console("OUTPUT_PATH = " + str(OUTPUT_PATH))
    log_console("*********************************")


def DirChanged():
    global RUN_SCRIPT_TRIGGER, LAST_TRIGGER_TIME
    Wait()
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
    watcher.event_queue.empty()
    log_console("Starting script...")
    p = Popen(["./filebot.sh", WATCH_PATH, OUTPUT_PATH])
    p.wait()
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

