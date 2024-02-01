/*

// invoking the lattice service lambda function using the AWS SDK Lambda client
const { LambdaClient, InvokeCommand } = require( '@aws-sdk/client-lambda');

exports.handler = async (event, context) => {
    // const functionName = process.env.LAMBDA_1_TARGET_NAME
    const functionName = 'lambda_target_1'
    console.log("functionName===", functionName)
  try {
    const lambdaClient = new LambdaClient();

    const params = {
      FunctionName: functionName, // Replace with the name of the target Lambda function
      InvocationType: 'RequestResponse', // Use 'Event' for asynchronous invocation
      Payload: JSON.stringify({
        key1: 'value1',
        key2: 'value2',
        // Add any payload you want to send to the other Lambda function
      }),
    };

    const command = new InvokeCommand(params);

    const response = await lambdaClient.send(command);

    console.log('Response from other Lambda:', JSON.parse(response.Payload.toString('utf-8')));

    return {
      statusCode: 200,
      body: JSON.stringify('Lambda invocation successful'),
    };
  } catch (error) {
    console.error('Error invoking Lambda function:', error);

    return {
      statusCode: 500,
      body: JSON.stringify('Internal Server Error'),
    };
  }
};



*/




const AWS = require('aws-sdk')
const https = require('https')
const axios = require("axios")
// create a lambda function that uses axios to make and http post request with an example payload. use try catch for error handling
exports.handler = async (event, context) => {
  console.log("event===", event)
  const latticeServiceEndpoint = process.env.LATTICE_SERVICE_ENDPOINT



  const endpoint = `https://${latticeServiceEndpoint}/path-1`
  console.log("endpoint===", endpoint)
  try {
    const payload = {
      name: 'Jonathan',
      age: 25
    }
    const response = await axios.post(endpoint, payload)
    console.log("response===",response.data)
    return response.data;

  //   const request = new AWS.HttpRequest(endpoint, 'us-east-1');
  //   request.method = "POST";
  //   request.headers = {
  //     'content-type': 'application/json',
  // };

    // console.log("request===",request)
    // return request.data
    
  } catch (error) {
    console.error(error)
    
  }
}


/*
const AWS = require('aws-sdk');
const https = require('https');

const region = process.env.AWS_REGION || 'us-east-2';
const latticeEndpoint = process.env.LATTICE_SERVICE_ENDPOINT || 'undefined';
console.log("latticeEndpoint===", latticeEndpoint)

AWS.config.update({ region });

const xRay = require('aws-xray-sdk-core');
xRay.captureHTTPsGlobal(require('https'));

const buildResponse = (code, body) => {
    const headers = {
        'Content-Type': 'application/json',
    };

    const response = {
        isBase64Encoded: false,
        statusCode: code,
        headers,
        body,
    };

    return response;
};

const parseFlag = (event, flag) => {
    // return flag in event && event[flag];
};

const sendRequest = async (event, addSigV4 = false, debug = false) => {
  console.log("event:", JSON.stringify(event, null, 2))


  const latticeServiceEndpoint = process.env.LATTICE_SERVICE_ENDPOINT
  console.log("latticeServiceEndpoint===", latticeServiceEndpoint)


    const headers = {
        'content-type': 'application/json',
    };

    const endpoint = event.endpoint || `https://${latticeServiceEndpoint}/path-1`;
    const method = event.method || 'POST';
    const data = JSON.stringify(event.data || {});

    const request = new AWS.HttpRequest(endpoint, region);
    request.method = method;
    request.headers = headers;
    request.body = data;
    console.log("request===",JSON.stringify(request))

    if (addSigV4) {
        console.log(JSON.stringify({
            message: 'sigv4 signing the request',
        })) 

        const credentials = new AWS.EnvironmentCredentials('AWS');
        const signer = new AWS.Signer.V4(request, 'vpc-lattice-svcs');
        signer.addAuthorization(credentials, new Date());
    }

    const timeout = 5000;
    let output = {};

    try {
        console.log("endpoint===",JSON.stringify({
            endpoint,
        })) 

        const response = await new Promise((resolve, reject) => {
            const req = https.request(endpoint, {
                method,
                headers,
                timeout,
            }, (res) => {
                let data = '';

                res.on('data', (chunk) => {
                    data += chunk;
                });

                res.on('end', () => {
                    resolve({
                        status_code: res.statusCode,
                        reason: res.statusMessage,
                        body: data,
                    });
                });
            });

            req.on('error', (err) => {
                reject(err);
            });

            if (method === 'POST' || method === 'PUT') {
                req.write(data);
            }

            req.end();
        });

        if (response.status_code === 200) {
            output = JSON.parse(response.body);
        } else {
            output = {
                status_code: response.status_code,
                reason: response.reason,
            };
        }
    } catch (error) {
      console.error(error)
        output = {
            status_code: 504,
            reason: `request to vpc lattice backend timed out (${timeout / 1000} seconds)`,
        };
    }

    return output;
};

exports.handler = async (event) => {
    console.log("event====",JSON.stringify(event));

    const body = event.data;
    // const body = JSON.parse(event.body);
    
    const enableSigV4 = parseFlag(body, 'sigv4');
    const enableDebug = parseFlag(body, 'debug');

    console.log(JSON.stringify({
        enableSigV4,
        enableDebug,
    }));

    const output = await sendRequest(body, enableSigV4, enableDebug);

    console.log("output", JSON.stringify(output));

    const response = buildResponse(200, JSON.stringify(output));

    console.log("response===",JSON.stringify(response));

    return response;
};
*/