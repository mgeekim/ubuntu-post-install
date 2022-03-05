from multiprocessing import Pool
import os, time
import time

print("hi outside of main()")

def hello(x):

    print("inside hello()")
    print("Proccess id: ", os.getpid())
    while True:
        print(x*x)
        time.sleep(2)

if __name__ == "__main__":
    p = Pool(processes=5)
    p.map_async(hello, [1, 2])
    # p.map(hello, [1, 2, 3])

    while True:
        print("@@@@@")
        time.sleep(1)
