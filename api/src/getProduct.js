const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();
const TableName = process.env.TABLE_NAME;

module.exports.handler = async (event) => {

    const params = {
        TableName,
        Key: {...event.pathParameters}
    }

    try {
        const data = await docClient.get(params).promise()
        return {
            statusCode: 200,
            body: JSON.stringify(data.Item)
        }
    } catch (e) {
        return {error: "Unable to get document!", message: e.message}
    }
}