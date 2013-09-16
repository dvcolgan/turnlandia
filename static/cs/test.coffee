pickle = require('pickle')
base64 = require('base64')

sessiondata = new Buffer('a7vxm3yu5qh35o9wqhv1bx6r2jsvrglo|MmU4NjQ4YjJlYmQ5MTEwYWYxOGUzYjc0ZTIxZjAzNmYyYzIzYzU3MDqAAn1xAShVEl9hdXRoX3VzZXJfYmFja2VuZHECVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHEDVQ1fYXV0aF91c2VyX2lkcQRLAXUu')
sessiondata = base64.decode(sessiondata)
sessiondata = sessiondata.toString()
console.log sessiondata

pickle.loads sessiondata, (data) ->
    console.log data
