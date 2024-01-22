   // index.js
//    exports.handler = async (event) => {
//     console.log("Hello World from Lambda!");
//     console.log("event===",JSON.stringify(event, null, 2))
//     return {
//         statusCode: 200,
//         body: JSON.stringify({ message: "Hello World" }),
//     };
// };


export const handler = async (event) => {
    console.log("Hello World from Lambda!");
    console.log("event===",JSON.stringify(event, null, 2))
    return {
        statusCode: 200,
        body: JSON.stringify({ message: "Hello from path-1" }),
    };

}