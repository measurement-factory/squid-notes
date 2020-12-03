# Connection ownership and handling

This page is dedicated to design principles guiding Comm::Connection handling.
Its current focus is on Squid code adjustments meant to address serious
systemic Connection-related problems.


## Terminology:

* An _open descriptor_ is a Comm-maintained non-negative descriptor. Bugs
  notwithstanding, Comm's isOpen() is true for (and only for) open
  descriptors.

* A _closing_ descriptor is an open descriptor after a comm_close() call;
  fde::closing() is true for (and only for) closing descriptors.

* An _open Connection_ is a Comm::Connection object with a non-negative fd
  member. Connection::isOpen() is true for (and only for) open Connections.
  Bugs notwithstanding, an open Connection has an open descriptor.

* A _closing Connection_ is an open Connection with a closing descriptor.

* _Connection owner_ is a C++ object that stores (a pointer to) an open
  Comm::Connection object as a data member. When discussion happens at a class
  level, a C++ class that may have such objects as instances at any point in
  time may also be called a Connection owner. There are about 50 Connection
  owning classes in Squid today.


## Problems

Squid has always suffered from various bugs related to connection descriptor
(and, later, Connection object) management. Here is a partial list of
(partially overlapping) problems:

* Using a closed connection: Squid requests a Comm or kernel service for a
  Connection with a negative descriptor, leading to Comm assertions and other
  forms of incorrect Squid behavior. In many cases, the code tries to avoid
  such problems by checking whether the Connection is open, but it is
  impractical to ensure such checks in all relevant contexts, and the checks
  themselves complicate the code and lead to other bugs.

* Using a closing connection: Squid requests a Comm or kernel service for an
  open Connection in a Comm "closing" state, leading to Comm assertions and
  other forms of incorrect Squid behavior. In some cases, the code tries to
  avoid such problems by checking whether the Connection is closing, but it is
  impractical to ensure such checks in all relevant contexts, and the checks
  themselves complicate the code and lead to other bugs.

* Closure surprises: When objects A and B share a Connection pointer, calling
  Connection::close() in object B, places object A in grave danger of using a
  closed connection. It is unrealistic to expect every asynchronous method in
  object A to correctly guard against such closures in object B. Moreover,
  such abrupt "external" Connection closures invalidate fundamental
  protections offered by the Comm descriptor "closing" state.

* Error detail losses: When objects A and B share a Connection pointer, owner
  A's closure handler is likely to terminate its job before important error
  details (discovered by owner B and sent to A after closing the shared
  connection) reach A. See Squid master commit 25b0ce4 for an example of (and
  fixes related to) such error propagation problems.

* Error and termination handling uncertainty: Developers often do not know for
  sure what their code should do with a Connection upon discovering an error
  or when completing connection usage. Squid offers at least three distinct
  APIs to get rid of a Connection: comm_close(), Connection::close(), and
  automatic Connection destruction via Comm::ConnectionPointer reference
  counting. On top of those APIs, there is a question of whether existing
  closure handlers should be removed before the code gets rid of a Connection.
  This uncertainty results in buggy and/or inefficient code as well as code
  review pains.

* Missing connection closure handlers: It is trivial for a developer to forget
  adding a connection closure handler in a connection-owning code. This is
  especially true for code that shares the connection with (or forwards it to)
  a different owner. The lack of closure handlers usually result in code using
  a closed connection.

* Missing connection read timeout handlers: It is trivial for a developer to
  forget adding a connection read timeout handler in a connection-reading
  code. This is especially true for code that shares the connection with (or
  forwards it to) a different owner. The lack of timeout handlers usually
  result in stuck transactions, essentially leaking valuable resources and
  eventually triggering painful triage.


## Assumption: Any function call is a potential comm_close() call.

We have to assume that virtually any code can start closing any connection at
any time. This assumption is essentially a fact in many current classes that
see their Connections getting closed by independent high- and low-level code.
Such "external" closures are difficult to handle correctly, but it is
impractical to refactor Squid code to eliminate them in the foreseeable
future:

* Historically, connection closure was used as a standard/recommended way of
  ending a "failing" transaction. There are probably over 120 comm_close() and
  Connection::close() calls in Squid, some located in fairly low-level code.
  It is prohibitively expensive to check and correct every caller to avoid all
  unexpected comm_close() calls by callers that do not own the corresponding
  Connection.

* Shared Connection ownership hides comm_close() calls by one owner from other
  owners. An "internal" closure for one object can be external from another
  object point of view.

* Comm does not have access to the Connection object and, hence, cannot update
  its Connection::fd field directly when closing the underlying descriptor.
  Perhaps this is a Comm design bug, but since many Comm descriptors are not
  related to connections, it is not clear whether Comm should know about all
  open Connections objects. Moreover, even if Comm could keep all
  Connection::fd fields in sync, the Connection owner job would still have to
  check whether the connection it owns got closed by others -- the essence of
  the external closure surprise would remain intact.


## Solutions

Squid has too much Connection and connection-descriptor handling code for a
single PR to discover and fix all connection ownership bugs. Many bugs are
difficult for humans to detect when reviewing new code. Our best hope to cure
this chronic disease is to define sound connection handling principles,
enforce them in new code (via new APIs), and, when possible, upgrade the old
code. Since it will take time to adjust the old code, our principles should
help defend against (and assume the existence of) misbehaving code.

* Long-term ideal: Any open connection descriptor has exactly one owner at any
  given point of time. Low-level socket creation and descriptor import code
  aside, this ownership is expressed by storing Comm::OpenConnection, a smart
  Comm::Connection pointer with an std::unique_ptr ownership semantics.

* Long-term ideal: Plans to open a Connection are expressed using
  Comm::FutureConnection, a smart Comm::Connection pointer with an
  std::shared_ptr ownership semantics. Future connections focus on maintaining
  details about connection source and destination addresses, peer
  associations, as well as various connection handling flags. FutureConnection
  does not provide access to the underlying socket descriptor because the
  socket has not been opened (yet).

* Long-term ideal: After an OpenConnection is closed or the plans to open a
  FutureConnection are abandoned, the corresponding connection information is
  stored using Comm::OldConnection, a smart Comm::Connection pointer with an
  std::shared_ptr ownership semantics. Such storage is useful for logging and
  debugging. OldConnection does not provide access to the underlying socket
  descriptor because the socket has never been opened or has already been
  closed.

* Code using FutureConnection, OpenConnection, and OldConnection pointers must
  strictly follow Connection handling principles. We should scrutinize the
  legacy Comm::ConnectionPointer-using code, but trust accepted
  Future/Open/OldConnection-using code.

* Comm::ConnectionPointer use should be discouraged/deprecated. When the last
  Comm::ConnectionPointer user is gone, we will end up with trusted code.

* Comm "closing" state is an internal Comm matter: Regular high-level code
  should not worry about Connections or descriptors in this state. The whole
  idea behind that special state is to allow high-level code to function
  correctly during any closing-associated cleanup which often starts without
  the affected code direct knowledge or control and may last a few async call
  queue iterations. Closure may start at virtually any time. It is futile to
  expect every high-level Connection and descriptor user to check for the
  Connection/descriptor state before every usage, especially before every
  repeated usage in synchronous code. During cleanup, all system calls should
  continue to work normally. Asynchronous Comm calls should be ignored (by the
  low-level Comm code) as if they just did not have the time to complete
  before the approaching connection closure.

* Comm::Read(OpenConnection) API requires a read timeout/handler that gets
  automatically canceled when the reader is notified about the socket
  readiness (including error-reporting notifications).

* Comm::OpenConnection creation API requires a connection closure handler
  because a handler is required to keep Connection::fd in sync with Comm.

* Comm::OpenConnection destructor automatically closes the connection (if
  any). The destructor does not call the closure handler because the open
  connection pointer is meant to be stored as the owner data member and,
  hence, the pointer destruction only happens when the pointer owner itself is
  being destroyed. And if some special code uses a local variable to store
  OpenConnection, then that code should not care about the closure of that
  temporary connection.

* Comm::Close(OpenConnection &oc) API closes the given open Connection and
  makes its pointer nil. The OpenConnection closure handler is not called in
  this case because the caller obviously knows that they are closing the
  connection and can initiate (often context-specific!) cleanup explicitly.

* Code that does not own an open connection, should use comm_close() API to
  close it, triggering the usual cleanup sequence which includes informing the
  OpenConnection owner about the impending closure and nullifying owner's
  OpenConnetion pointer.
