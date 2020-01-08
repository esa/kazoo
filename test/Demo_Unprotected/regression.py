#!/usr/bin/env python
import pexpect, sys

def main():
    timeout = 10
    binary = "work/binaries/demo"
    try:
        print "Verifying", binary, " "*7,
        sys.stdout.flush()
        g_child = pexpect.spawn(binary, timeout=timeout)
        elem = 'ERROR'
        realList = [pexpect.TIMEOUT, pexpect.EOF]
        realList.append(elem)
        idx = g_child.expect(realList)
        if 0 == idx:
            # Timeout in this case is good!
            # print "\nTimed out waiting for:", realList
            pass
        elif 1 == idx:
            print "\nUnexpected EOF waiting for:", realList
            print g_child
            sys.exit(1)
        else:
            sys.stdout.write("ERROR received...\n")
            sys.stdout.flush()
            sys.exit(1)
        print "\nVerified ", binary, ": OK"
    except:
	print "Test failed..."
	return 1
    return 0

if __name__ == "__main__":
    main()
