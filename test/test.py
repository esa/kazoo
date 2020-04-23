#!/usr/bin/env python3
import subprocess
import sys
import time
import signal
import os
from functools       import partial
from multiprocessing import cpu_count
from concurrent      import futures


def openLog(name, mode='w'):
    logs = os.path.join(os.path.dirname(os.path.abspath(__file__)),'logs')
    os.makedirs(logs, exist_ok=True)
    return open(os.path.join(logs, name + '.err.txt'), mode)

def colorMe(result, msg):
    if sys.stdout.isatty():
        code = "1" if result else "2"
        msg = chr(27) + "[3" + code + "m" + msg + chr(27) + "[0m"
    return msg

def main():
    ''' Run the test cases in parallel on all available CPUs '''
    start = time.time()
    results = []
    rule = sys.argv[1]
    paths = sys.argv[2:]
    # the following line is temporarily disabled so that it can run on
    # old versions of python that did not support f-strings
    #print (f"Running {len(paths)} tests using {cpu_count()} processors")
    xfails = os.environ['EXPECTED_FAILURES']

    with futures.ProcessPoolExecutor(max_workers=cpu_count()) as executor:
        fs = [executor.submit(partial(make, rule), path) for path in paths]
        for each in futures.as_completed(fs):
            result = each.result()
            errcode, stdout, stderr, path, rule = result
            name = path.replace("/", "")
            print("(%3d / %3d) %40s: %s" % (len(results)+1, len(paths), name,
               colorMe (errcode,
                   '[OK]' if errcode==0
                   else '[EXPECTED FAILURE] ... build log in logs/{}.err.txt'
                        .format(name) if name in xfails
                   else '[FAILED] ... build log in logs/{}.err.txt'
                   .format(name))))
            sys.stdout.flush()
            if errcode != 0:
                # Failure: save the log immediately
                with openLog(name) as f:
                    f.write("=" * 80)
                    f.write("ERROR: %s %s" % (name, rule))
                    try:
                        if stdout:
                            f.write("-- stdout " + "-" * 70)
                            f.write(stdout.decode('utf-8', 'replace'))
                        if stderr:
                            f.write("-- stderr " + "-" * 70)
                            f.write(stderr.decode('utf-8', 'replace'))
                            f.write("-" * 80)
                    except (UnicodeEncodeError, UnicodeDecodeError) as err:
                        print("Unicode error in project", name)
                        f.write(str(err))
            if errcode != 0 and name in xfails:
               # for "expected failures", set errcode to None
               result = (None, stdout, stderr, path, rule)
            results.append(result)
            # don't use the map function, because it keeps the order of
            # submission, meaning that even if a job finishes before the
            # previous one started, the log output will be delayed
#       for result in executor.map(partial(make, rule), paths):
#           print("%40s: %s" % (result[3].replace("/", ""), colorMe(result[0],
#                              '[OK]' if result[0]==0 else '[FAILED]')))
#           sys.stdout.flush()
#           results.append(result)
        executor.map(partial(make, 'clean'), paths)
    sys.stdout.write('\n')

    elapsed = time.time() - start
    return summarize(results, elapsed)


def make(rule, path):
    ''' Call a Makefile with the required rule (e.g. build or clean) '''
    proc = subprocess.Popen(
        ['make', '-C', path, rule],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    stdout, stderr = proc.communicate()
    errcode = proc.returncode
    return (errcode, stdout, stderr, path, rule)


def summarize(results, elapsed):
    ''' At the end display the errors of project that failed '''
    failed = 0
    with openLog("kazoo", "w") as f:
        f.write("kazoo test report")
        f.write("-----------------")
    for errcode, stdout, stderr, path, rule in results:
        if errcode == 0:
            continue
        if errcode is not None:
            failed += 1
    print("Finished in %.3fs" % elapsed)
    print("%s tests, %s errors" % (len(results), failed))
    return 0 if not failed else 1


if __name__ == '__main__':
    # Catch Ctrl-C to stop the app from the console
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    ret = main()
    sys.stdout.write('\033[0m\n')
    sys.stdout.flush()
    sys.exit(ret)
