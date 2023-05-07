const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();
const TableName = process.env.TABLE_NAME;

module.exports.handler = async (event) => {

    const params = {
        TableName,
        Key: {...event.queryStringParameters}
    }

    try {
        await docClient.delete(params).promise()
        return {
            statusCode: 200,
            body: JSON.stringify({message: "Item Deleted"}),
        };
    } catch (e) {
        return {error: "Unable to delete document!", message: e.message}
    }
}