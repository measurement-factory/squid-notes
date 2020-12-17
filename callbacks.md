# Job callbacks

This page is dedicated to AsyncJob communication performed via "callbacks" --
AsyncCalls that pass information from a "service" or "helper" job to the
"originating" job.


## Helper job usage sketch

```C++
MyJob::startStepN()
{
    try {
        std::unique<AsyncJob> job = new Job(conn, ...);
        job->additionalConfiguration(callback, ...);
        stepN = AsyncCall::Start(job.release());
    } catch {
        assert(!stepN); // no stepN-specific cleanup necessary
        retryOrBail();
    }
}

MyJob::handleStepNresult(...)
{
    assert(stepN); // no unepxected callbacks
    stepN = nullptr;
    ...
}
```


## Problems

* Exception safety during job creation: Most of the code starting helper jobs
  today is not fully exception-safe, while existing APIs may prevent
  developers from fixing that code.

* Cleanup code placement uncertainty: Developers do not know where to put
  AsynJob's cleanup code -- into swanSong(), destructor, or both. This
  uncertainty creates bugs, delays development, and complicates review.

* Constructing an asynchronous callback call in a half-configured helper job
  is dangerous.

* Receiving an unexpected callback from a never-started job is dangerous.
  Canceling such unwanted callbacks while catching helper configuration
  exceptions is wasteful and annoying. Developers are likely to forget it.

* Not receiving an expected callback from a started helper job leads to
  painful timeouts.


## Design principles

The following design decisions should address known problems and allow
developers to write exception-safe helper job startup code.

* AsyncJob destructors must not call any callbacks.

* AsyncJob::swanSong() is responsible for async-calling any remaining
  callbacks.

* AsyncJob::swanSong() is guaranteed _not_ to be called before a non-throwing
  AsyncJob::Start() return. Unfortunately, this may require adding a
  AsyncJob::started flag.

* AsyncJob::swanSong() is guaranteed to be called after a non-throwing
  AsyncJob::Start() return.

* AsyncJob destructing sequence should validate that no callbacks remain
  uncalled after a non-throwing AsyncJob::Start() return. This validation can
  probably be automated via asserts in helper-stored callback destructors.


## Side notes

AsyncJob::swanSong() may be called without start() because it is theoretically
possible to async-call a job-terminating method before AsyncJob::Start()
async-calls start().
