# restify-validation
Validation for REST Services built with [node-restify](https://github.com/mcavage/node-restify) in node.js

## Requirements
* node-restify-validation requires at least restify 2.6.0 since the validation model is defined in the route-object. (https://github.com/mcavage/node-restify/pull/408)
* Currently it is required to map all parameters to the "params-scope" through the mapParams-option, since all validations will be performed agains the req.params object.

## Simple request validation with node-restify
Goal of this little project is to have the validation rules / schema as close to the route itself as possible on one hand without messing up the logic with further LOCs on the other hand.

Example:

	restifyValidation = require "restify-validation"
	Type = restifyValidation.type
	server = restify.createServer()
	server.use restify.queryParser()
	server.use restifyValidation.validationPlugin()

	server.get
	  url: "/test/:name"
	  validation:
	    name:
	      type: Type.String
	      in: [
	        "foo"
	        "bar"
	      ]
	    status:
	      required: false
	      type: Type.String
	      notIn: [
	        "closed"
	      ]
	    email: Type.Email
	    homepage: Type.Domain
	    authentication: ->
	      return _.has @.params.authentication, ["type"]
	, (req, res, next) ->
	  res.send req.params
	  return next()

	server.listen 8001, ->

## Use
Simply install it through npm

    npm install restify-validation

## Supported validations

	 type: String | Number | Boolean | Date | Array | Object | Email | Domain | Url | function() (this function should return boolean, in function `this` is bind to `req`)

    required: true (default option) | false
    
    in: [] (should be array) |  "string" (string and support regexp)
    
    notIn: (reverse of in)
    
    equal: (any type)
    
    notEqual: (reverse of equal)

## License

The MIT License (MIT)

Copyright (c) 2014 faceair

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
