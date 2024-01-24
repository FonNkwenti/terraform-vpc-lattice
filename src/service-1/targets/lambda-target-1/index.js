

exports.handler = async (event, context) => {
    console.log("Hello World from Lambda target 1!");
    console.log("event===",JSON.stringify(event, null, 2))
    return {
        statusCode: 200,
        body: JSON.stringify({ message: "Hello from path-1" }),
    };

}