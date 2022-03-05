import sys

IS_PY2 = sys.version_info < (3, 0)

if IS_PY2:
    from Queue import Queue
else:
    from queue import Queue
from threading import Thread

class Worker(Thread):
    """ 주어진 작업(tasks)들에 대한 대기열(큐,queue)로부터 작업을 실행할 스레드 """
    def __init__(self, tasks):
        Thread.__init__(self)
        self.tasks = tasks
        self.daemon = True
        self.start()
    def run(self):
        while True:
            func, args, kargs = self.tasks.get()
            try:
                func(*args, **kargs)
            except Exception as e:
                # exception이 이 스레드에서 발생했습니다.
                print(e)
            finally:
                # exception 발생과 상관없이 이 작업(task)을 끝냈다고 마크 합니다.
                self.tasks.task_done()

class ThreadPool:
    """ 대기열(큐,queue)로부터 작업을 소비하는 스레드 풀 """
    def __init__(self, num_threads):
        self.tasks = Queue(num_threads)
        for _ in range(num_threads):
            Worker(self.tasks)
    def add_task(self, func, *args, **kargs):
        """ 대기열(큐,queue)에 작업을 추가 """
        self.tasks.put((func, args, kargs))
    def map(self, func, args_list):
        """ 대기열(큐,queue)에 작업의 리스트를 추가 """
        for args in args_list:
            self.add_task(func, args)
    def wait_completion(self):
        """ 대기열(큐,queue)에 모든 작업의 완료를 기다림 """
        self.tasks.join()
         
if __name__ == "__main__":
    from random import randrange
    from time import sleep
    # 스레드에서 실행될 함수
    def wait_delay(d):
        print("sleeping for (%d)sec" % d)
        sleep(d)
    # 임의의 지연시간 생성
    delays = [randrange(3, 7) for i in range(50)]
    # 5개의 worker 스레드로 스레드 풀을 인스턴스화
    pool = ThreadPool(5)
    # 스레드 풀로 대량의 작업을 추가. 하나씩 작업을 추가하기 위해 `pool.add_task`
    # 사용 가능. 이 코드는 이 곳에서 막힐(block) 것이지만
    # 현재 실행하고 있는 worker의 배치작업이 완료되면
    # exception으로 스레드 풀을 취소하는 것이 가능하도록 만들 수 있습니다.
    pool.map(wait_delay, delays)
    pool.wait_completion()
