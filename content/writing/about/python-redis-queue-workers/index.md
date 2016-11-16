---
title: Python Redis Queue Workers
author: Brett Langdon
date: 2014-10-14
template: article.jade
---

Learn an easy, distributed approach to processing jobs
from a Redis queue in Python.

---

Recently I started thinking about a new project. I want to write my own Continuous Integration (CI)
server. I know what you are thinking... "Why?!" and yes I agree, there are a bunch of good ones out
there now, I just want to do it. The first problem I came across was how to have distributed workers
to process the incoming builds for the CI server. I wanted something that was easy to start up on
multiple machines and that needed minimal configuration to get going.

The design is relatively simple, there is a main queue which jobs can be pulled from and a second queue
that each worker process pulls jobs into to denote processing. The main queue is meant as a list of things that
have to be processed where the processing queues is a list of pending jobs which are being processed by the
workers. For this example we will be using [Redis lists](http://redis.io/commands#list) since they support
the short feature list we require.

### worker.py
Lets start with the worker process, the job of the worker is to simply grab a job from the queue and process it.

```python
import redis


def process(job_id, job_data):
    print "Processing job id(%s) with data (%r)" % (job_id, job_data)


def main(client, processing_queue, all_queue):
    while True:
        # try to fetch a job id from "<all_queue>:jobs"
        # and push it to "<processing_queue>:jobs"
        job_id = client.brpoplpush(all_queue, processing_queue)
        if not job_id:
            continue
        # fetch the job data
        job_data = client.hgetall("job:%s" % (job_id, ))
        # process the job
        process(job_id, job_data)
        # cleanup the job information from redis
        client.delete("job:%s" % (job_id, ))
        client.lrem(process_queue, 1, job_id)


if __name__ == "__main__":
    import socket
    import os

    client = redis.StrictRedis()
    try:
        main(client, "processing:jobs", "all:jobs")
    except KeyboardInterrupt:
        pass
```

The above script does the following:
1. Try to fetch a job from the queue `all:jobs` pushing it to `processing:jobs`
2. Fetch the job data from a [hash](http://redis.io/commands#hash) key with the name `job:<job_id>`
3. Process the job information
4. Remove the hash key `job:<job_id>`
5. Remove the job id from the queue `processing:jobs`

With this design we will always be able to determine how many jobs are currently queued for process
by looking at the list `all:jobs` and we will also know exactly how many jobs are being processed
by looking at the list `processing:jobs` which contains the list of job ids that all workers are
working on.

Also we are not tied down to running just 1 worker on 1 machine. With this design we can run multiple
worker processes on as many nodes as we want. As long as they all have access to the same Redis server.
There are a few limitations which are all seeded in Redis' [limits on lists](http://redis.io/topics/data-types),
but this should be good enough to get started.

There are a few other approaches that can be taken here as well. Instead of using a single processing queue
we could use a separate queue for each worker. Then we can look at which jobs are currently being processed
by each individual worker, this approach would also give us the opportunity to have the workers try to fetch
from the worker specific queue first before looking at `all:jobs` so we can either assign jobs to specific
workers or where the worker can recover from failed processing by starting with the last job it was working
on before failing.

## qw
I have developed the library [qw](https://github.com/brettlangdon/qw) or (QueueWorker) to implement a similar
pattern to this, so if you are interested in playing around with this or to see a more developed implementation
please checkout the projects [github page](https://github.com/brettlangdon/qw) for more information.
