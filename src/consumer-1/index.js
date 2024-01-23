
//    exports.handler = async (event, context) => {
//     console.log("Hello World from Lambda!");
//     console.log("event===",JSON.stringify(event, null, 2))
//     return {
//         statusCode: 200,
//         body: JSON.stringify({ message: "Hello World" }),
//     };
// };

import { LambdaClient, InvokeCommand } from '@aws-sdk/client-lambda';



export const handler = async (event, context) => {
    const functionName = process.env.LAMBDA_1_TARGET_NAME
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
