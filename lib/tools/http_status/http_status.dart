class HttpStatusCode {
  final int code;
  final String name;
  final String description;

  const HttpStatusCode(this.code, this.name, this.description);

  bool matches(String query) {
    final q = query.toLowerCase();
    return code.toString().contains(q) || name.toLowerCase().contains(q) || description.toLowerCase().contains(q);
  }
}

const List<HttpStatusCode> httpStatusCodes = [
  // 1xx Informational
  HttpStatusCode(100, 'Continue', 'The server has received the request headers and the client should proceed to send the request body.'),
  HttpStatusCode(101, 'Switching Protocols', 'The requester has asked the server to switch protocols and the server has agreed to do so.'),
  HttpStatusCode(102, 'Processing', 'The server has received and is processing the request, but no response is available yet.'),
  HttpStatusCode(103, 'Early Hints', 'Used to return some response headers before the final HTTP message.'),
  // 2xx Success
  HttpStatusCode(200, 'OK', 'The request has succeeded.'),
  HttpStatusCode(201, 'Created', 'The request has succeeded and a new resource has been created.'),
  HttpStatusCode(202, 'Accepted', 'The request has been received but not yet acted upon.'),
  HttpStatusCode(203, 'Non-Authoritative Information', 'The returned metadata is not exactly the same as is available from the origin server.'),
  HttpStatusCode(204, 'No Content', 'There is no content to send for this request, but the headers may be useful.'),
  HttpStatusCode(205, 'Reset Content', 'Tells the user agent to reset the document which sent this request.'),
  HttpStatusCode(206, 'Partial Content', 'This response code is used when the Range header is sent from the client to request only part of a resource.'),
  HttpStatusCode(207, 'Multi-Status', 'Conveys information about multiple resources, for situations where multiple status codes might be appropriate.'),
  HttpStatusCode(208, 'Already Reported', 'Used inside a <dav:propstat> response element to avoid enumerating the internal members of multiple bindings to the same collection repeatedly.'),
  HttpStatusCode(226, 'IM Used', 'The server has fulfilled a GET request for the resource, and the response is a representation of the result of one or more instance-manipulations applied to the current instance.'),
  // 3xx Redirection
  HttpStatusCode(300, 'Multiple Choices', 'The request has more than one possible response. The user agent should choose one of them.'),
  HttpStatusCode(301, 'Moved Permanently', 'The URL of the requested resource has been changed permanently.'),
  HttpStatusCode(302, 'Found', 'This response code means that the URI of the requested resource has been changed temporarily.'),
  HttpStatusCode(303, 'See Other', 'The server sent this response to direct the client to get the requested resource at another URI with a GET request.'),
  HttpStatusCode(304, 'Not Modified', 'This is used for caching purposes. It tells the client that the response has not been modified.'),
  HttpStatusCode(305, 'Use Proxy', 'The requested resource must be accessed through the proxy given by the Location field. Deprecated due to security concerns.'),
  HttpStatusCode(306, 'Unused', 'This response code is no longer used; it is reserved. It was used in a previous version of the HTTP/1.1 specification.'),
  HttpStatusCode(307, 'Temporary Redirect', 'The server sends this response to direct the client to get the requested resource at another URI with same method that was used in the prior request.'),
  HttpStatusCode(308, 'Permanent Redirect', 'This means that the resource is now permanently located at another URI, specified by the Location: HTTP Response header.'),
  // 4xx Client Errors
  HttpStatusCode(400, 'Bad Request', 'The server cannot or will not process the request due to something that is perceived to be a client error.'),
  HttpStatusCode(401, 'Unauthorized', 'The client must authenticate itself to get the requested response.'),
  HttpStatusCode(402, 'Payment Required', 'This response code is reserved for future use.'),
  HttpStatusCode(403, 'Forbidden', 'The client does not have access rights to the content.'),
  HttpStatusCode(404, 'Not Found', 'The server cannot find the requested resource.'),
  HttpStatusCode(405, 'Method Not Allowed', 'The request method is known by the server but is not supported by the target resource.'),
  HttpStatusCode(406, 'Not Acceptable', 'The server doesn\'t find any content that conforms to the criteria given by the user agent.'),
  HttpStatusCode(407, 'Proxy Authentication Required', 'This is similar to 401 but authentication is needed to be done by a proxy.'),
  HttpStatusCode(408, 'Request Timeout', 'The server did not receive a complete request message within the time that it was prepared to wait.'),
  HttpStatusCode(409, 'Conflict', 'This response is sent when a request conflicts with the current state of the server.'),
  HttpStatusCode(410, 'Gone', 'The requested content has been permanently deleted from server, with no forwarding address.'),
  HttpStatusCode(411, 'Length Required', 'The server rejected the request because the Content-Length header field is not defined and the server requires it.'),
  HttpStatusCode(412, 'Precondition Failed', 'The client has indicated preconditions in its headers which the server does not meet.'),
  HttpStatusCode(413, 'Content Too Large', 'The request body is larger than the limits defined by the server.'),
  HttpStatusCode(414, 'URI Too Long', 'The URI requested by the client is longer than the server is willing to interpret.'),
  HttpStatusCode(415, 'Unsupported Media Type', 'The media format of the requested data is not supported by the server.'),
  HttpStatusCode(416, 'Range Not Satisfiable', 'The range specified by the Range header field in the request can\'t be fulfilled.'),
  HttpStatusCode(417, 'Expectation Failed', 'The expectation indicated by the Expect request header field can\'t be met by the server.'),
  HttpStatusCode(418, "I'm a Teapot", 'The server refuses the attempt to brew coffee with a teapot.'),
  HttpStatusCode(421, 'Misdirected Request', 'The request was directed at a server that is not able to produce a response.'),
  HttpStatusCode(422, 'Unprocessable Content', 'The request was well-formed but was unable to be followed due to semantic errors.'),
  HttpStatusCode(423, 'Locked', 'The resource that is being accessed is locked.'),
  HttpStatusCode(424, 'Failed Dependency', 'The request failed due to failure of a previous request.'),
  HttpStatusCode(425, 'Too Early', 'Indicates that the server is unwilling to risk processing a request that might be replayed.'),
  HttpStatusCode(426, 'Upgrade Required', 'The server refuses to perform the request using the current protocol.'),
  HttpStatusCode(428, 'Precondition Required', 'The origin server requires the request to be conditional.'),
  HttpStatusCode(429, 'Too Many Requests', 'The user has sent too many requests in a given amount of time.'),
  HttpStatusCode(431, 'Request Header Fields Too Large', 'The server is unwilling to process the request because its header fields are too large.'),
  HttpStatusCode(451, 'Unavailable For Legal Reasons', 'The user agent requested a resource that cannot legally be provided.'),
  // 5xx Server Errors
  HttpStatusCode(500, 'Internal Server Error', 'The server has encountered a situation it does not know how to handle.'),
  HttpStatusCode(501, 'Not Implemented', 'The request method is not supported by the server and cannot be handled.'),
  HttpStatusCode(502, 'Bad Gateway', 'The server, while working as a gateway to get a response needed to handle the request, got an invalid response.'),
  HttpStatusCode(503, 'Service Unavailable', 'The server is not ready to handle the request, commonly because it is down for maintenance or overloaded.'),
  HttpStatusCode(504, 'Gateway Timeout', 'The server is acting as a gateway and cannot get a response in time.'),
  HttpStatusCode(505, 'HTTP Version Not Supported', 'The HTTP version used in the request is not supported by the server.'),
  HttpStatusCode(506, 'Variant Also Negotiates', 'The server has an internal configuration error.'),
  HttpStatusCode(507, 'Insufficient Storage', 'The method could not be performed on the resource because the server is unable to store the representation needed.'),
  HttpStatusCode(508, 'Loop Detected', 'The server detected an infinite loop while processing the request.'),
  HttpStatusCode(510, 'Not Extended', 'Further extensions to the request are required for the server to fulfill it.'),
  HttpStatusCode(511, 'Network Authentication Required', 'Indicates that the client needs to authenticate to gain network access.'),
];
